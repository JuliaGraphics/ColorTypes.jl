# hash
hash(c::AbstractGray, hx::UInt) = hash(gray(c), hx)
hash(c::TransparentGray, hx::UInt) = hash(alpha(c), hash(gray(c), hx))
hash(c::AbstractRGB, hx::UInt) = hash(blue(c), hash(green(c), hash(red(c), hx)))
hash(c::TransparentRGB, hx::UInt) = hash(alpha(c), hash(blue(c), hash(green(c), hash(red(c), hx))))

Base.adjoint(c::Colorant) = c

# gamut{min,max}
gamutmax(::Type{T}) where {T<:HSV} = (360,1,1)
gamutmin(::Type{T}) where {T<:HSV} = (0,0,0)
gamutmax(::Type{T}) where {T<:HSL} = (360,1,1)
gamutmin(::Type{T}) where {T<:HSL} = (0,0,0)
gamutmax(::Type{T}) where {T<:Lab} = (100,128,128)
gamutmin(::Type{T}) where {T<:Lab} = (0,-127,-127)
gamutmax(::Type{T}) where {T<:LCHab} = (100,1,360)
gamutmin(::Type{T}) where {T<:LCHab} = (0,0,0)
gamutmax(::Type{T}) where {T<:YIQ} = (1,0.5226,0.5226)
gamutmin(::Type{T}) where {T<:YIQ} = (0,-0.5957,-0.5957)

gamutmax(::Type{T}) where {T<:AbstractGray} = (1,)
gamutmax(::Type{T}) where {T<:TransparentGray} = (1,1)
gamutmax(::Type{T}) where {T<:AbstractRGB} = (1,1,1)
gamutmax(::Type{T}) where {T<:TransparentRGB} = (1,1,1,1)
gamutmin(::Type{T}) where {T<:AbstractGray} = (0,)
gamutmin(::Type{T}) where {T<:TransparentGray} = (0,0)
gamutmin(::Type{T}) where {T<:AbstractRGB} = (0,0,0)
gamutmin(::Type{T}) where {T<:TransparentRGB} = (0,0,0,0)

# rand
for t in [Float16,Float32,Float64,N0f8,N0f16,N0f32]
    @eval _rand(::Type{T}) where {T<:Union{AbstractRGB{$t},AbstractGray{$t}}} =
          mapc(x->rand(eltype(T)), base_colorant_type(T)())
end

function _rand(::Type{T}) where T<:Colorant
    Gmax = gamutmax(T)
    Gmin = gamutmin(T)
    Mi = eltype(T) <: FixedPoint ? 1.0/typemax(eltype(T)) : 1.0
    A = rand(eltype(T), length(T))
    for j in eachindex(Gmax)
        A[j] = A[j] * (Mi * (Gmax[j]-Gmin[j])) + Gmin[j]
    end
    T(A...)
end

function _rand(::Type{T}, sz::Dims) where T<:Colorant
    Gmax = gamutmax(T)
    Gmin = gamutmin(T)
    Mi = eltype(T) <: FixedPoint ? 1.0/typemax(eltype(T)) : 1.0
    A = Array{T}(undef, sz)
    Tr = eltype(T) <: FixedPoint ? FixedPointNumbers.rawtype(eltype(T)) : eltype(T)
    nchannels = sizeof(T)÷sizeof(eltype(T))
    Au = Random.UnsafeView(convert(Ptr{Tr}, pointer(A)), length(A)*nchannels)
    rand!(Au)
    Ar = reshape(reinterpret(eltype(T), A), (nchannels, sz...))
    for j in eachindex(Gmax)
        s = Mi * (Gmax[j]-Gmin[j])
        for i = j:length(Gmax):length(Ar)
            Ar[i] = Ar[i] * s + Gmin[j]
        end
    end
    return A
end

rand(::Type{T}, sz::Dims...) where {T<:Colorant} = _rand(ccolor(T, base_colorant_type(T){Float64}), sz...)

rand(::Type{Gray24}) = Gray24(rand(N0f8))
rand(::Type{Gray24}, sz::Dims) = Gray24.(rand(N0f8,sz))
rand(::Type{AGray32}) = AGray32(rand(N0f8),rand(N0f8))
rand(::Type{AGray32}, sz::Dims) = AGray32.(rand(N0f8,sz),rand(N0f8,sz))

# broadcast

# Mapping a function over color channels
"""
    mapc(f, rgb) -> rgbf
    mapc(f, rgb1, rgb2) -> rgbf

`mapc` applies the function `f` to each color channel of the input
color(s), returning an output color in the same colorspace.

# Examples:

    julia> mapc(x->clamp(x,0,1), RGB(-0.2,0.3,1.2))
    RGB{Float64}(0.0,0.3,1.0)

    julia> mapc(max, RGB(0.1,0.8,0.3), RGB(0.5,0.5,0.5))
    RGB{Float64}(0.5,0.8,0.5)

    julia> mapc(+, RGB(0.1,0.8,0.3), RGB(0.5,0.5,0.5))
    RGB{Float64}(0.6,1.3,0.8)
"""
@inline mapc(f, c::C) where {C<:AbstractGray} = base_color_type(C)(f(gray(c)))
@inline mapc(f, c::C) where {C<:TransparentGray} = base_colorant_type(C)(f(gray(c)), f(alpha(c)))
@inline mapc(f, c::C) where {C<:Color3} = base_color_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)))
@inline mapc(f, c::C) where {C<:Transparent3} = base_colorant_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)), f(alpha(c)))

@inline mapc(f, x::Number) = f(x)

mapc(f, x, y) = _mapc(_same_colorspace(x,y), f, x, y)
_mapc(::Type{C}, f, x::AbstractGray, y::AbstractGray) where C =
    C(f(gray(x), gray(y)))
_mapc(::Type{C}, f, x::TransparentGray, y::TransparentGray) where C =
    C(f(gray(x), gray(y)), f(alpha(x), alpha(y)))
_mapc(::Type{C}, f, x::Color3, y::Color3) where C =
    C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)))
_mapc(::Type{C}, f, x::Transparent3, y::Transparent3) where C =
    C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)), f(alpha(x), alpha(y)))

_same_colorspace(x::Colorant, y::Colorant) = _same_colorspace(base_colorant_type(x),
                                                              base_colorant_type(y))
_same_colorspace(::Type{C}, ::Type{C}) where {C<:Colorant} = C
@noinline _same_colorspace(::Type{C1}, ::Type{C2}) where {C1<:Colorant,C2<:Colorant} =
    throw(ArgumentError("$C1 and $C2 are from different colorspaces"))

"""
    reducec(op, v0, c)

Reduce across color channels of `c` with the binary operator
`op`. `v0` is the neutral element used to initiate the reduction. For
grayscale,

    reducec(op, v0, c::Gray) = op(v0, comp1(c))

whereas for RGB

    reducec(op, v0, c::RGB) = op(comp3(c), op(comp2(c), op(v0, comp1(c))))

If `c` has an alpha channel, it is always the last one to be folded into the reduction.
"""
@inline reducec(op, v0, c::AbstractGray) = op(v0, comp1(c))
@inline reducec(op, v0, c::TransparentGray) = op(alpha(c), op(v0, comp1(c)))
@inline reducec(op, v0, c::Color3) = op(comp3(c), op(comp2(c), op(v0, comp1(c))))
@inline reducec(op, v0, c::Transparent3) = op(alpha(c), op(comp3(c), op(comp2(c), op(v0, comp1(c)))))

@inline reducec(op, v0, x::Number) = op(v0, x)

"""
    mapreducec(f, op, v0, c)

Reduce across color channels of `c` with the binary operator `op`,
first applying `f` to each channel. `v0` is the neutral element used
to initiate the reduction. For grayscale,

    mapreducec(f, op, v0, c::Gray) = op(v0, f(comp1(c)))

whereas for RGB

    mapreducec(f, op, v0, c::RGB) = op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c)))))

If `c` has an alpha channel, it is always the last one to be folded into the reduction.
"""
@inline mapreducec(f, op, v0, c::AbstractGray) = op(v0, f(comp1(c)))
@inline mapreducec(f, op, v0, c::TransparentGray) = op(f(alpha(c)), op(v0, f(comp1(c))))
@inline mapreducec(f, op, v0, c::Color3) =
    op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c)))))
@inline mapreducec(f, op, v0, c::Transparent3) =
    op(f(alpha(c)), op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c))))))

@inline mapreducec(f, op, v0, x::Number) = op(v0, f(x))
