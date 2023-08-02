struct BoolTuple end
@inline BoolTuple(args::Bool...) = args

# comparison
_is_same_colorspace(a, b) = base_colorant_type(a) === base_colorant_type(b)
_is_same_colorspace(a::TransparentColor, b::TransparentColor) = base_color_type(a) === base_color_type(b)
_is_same_colorspace(a::AbstractGray, b::AbstractGray) = true
_is_same_colorspace(a::TransparentGray, b::TransparentGray) = true
_is_same_colorspace(a::AbstractRGB, b::AbstractRGB) = true
_is_same_colorspace(a::TransparentRGB, b::TransparentRGB) = true

function ==(a::ColorantN{N}, b::ColorantN{N}) where {N}
    _is_same_colorspace(a, b) || return false
    all(_mapc(BoolTuple, ==, a, b))
end
==(x::Number, y::AbstractGray) = x == gray(y)
==(x::AbstractGray, y::Number) = ==(y, x)

function Base.isequal(a::ColorantN{N}, b::ColorantN{N}) where {N}
    _is_same_colorspace(a, b) || return false
    all(_mapc(BoolTuple, isequal, a, b))
end
Base.isequal(x::Number, y::AbstractGray) = isequal(x, gray(y))
Base.isequal(x::AbstractGray, y::Number) = isequal(y, x)


function isapprox(a::ColorantN{N}, b::ColorantN{N}; kwargs...) where {N}
    _is_same_colorspace(a, b) || return false
    componentapprox(x, y) = isapprox(x, y; kwargs...)
    all(_mapc(BoolTuple, componentapprox, a, b))
end
isapprox(a::Colorant, b::Colorant; kwargs...) = false
isapprox(a::Number, b::AbstractGray; kwargs...) = isapprox(a, gray(b); kwargs...)
isapprox(a::AbstractGray, b::Number; kwargs...) = isapprox(b, a; kwargs...)


isless(a::AbstractGray, b::AbstractGray) = isless(gray(a), gray(b))
isless(a::AbstractGray, b::Real)         = isless(gray(a), b)
isless(a::Real,         b::AbstractGray) = isless(a,       gray(b))

<(a::AbstractGray, b::AbstractGray) = gray(a) < gray(b)
<(a::AbstractGray, b::Real)         = gray(a) < b
<(a::Real,         b::AbstractGray) = a       < gray(b)

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

gamutmax(::Type{<:Oklab}) = (1, 0.4, 0.4)
gamutmin(::Type{<:Oklab}) = (0, -0.4, -0.4)
gamutmax(::Type{<:Oklch}) = (1, 0.4, 360)

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

if Base.VERSION < v"1.6.0-DEV.1083"
    reinterpretc(::Type{T}, A::Array{C}) where {T<:Real,C<:AbstractGray} = reinterpret(T, A)
    reinterpretc(::Type{T}, A::Array{C}) where {T<:Real,C<:Colorant} = reshape(reinterpret(T, A), (sizeof(C)÷sizeof(T), size(A)...))
else
    reinterpretc(::Type{T}, A::Array{C}) where {T<:Real,C<:Colorant} = reinterpret(reshape, T, A)
end

function _rand(::Type{T}, sz::Dims) where T<:Colorant
    Mi = eltype(T) <: FixedPoint ? 1.0/typemax(eltype(T)) : 1.0
    A = Array{T}(undef, sz)
    Tr = eltype(T) <: FixedPoint ? FixedPointNumbers.rawtype(eltype(T)) : eltype(T)
    nchannels = sizeof(T)÷sizeof(eltype(T))
    Au = Random.UnsafeView(convert(Ptr{Tr}, pointer(A)), length(A)*nchannels)
    rand!(Au)

    Gmax = gamutmax(T)
    Gmin = gamutmin(T)
    s = (Gmax .- Gmin) .* Mi
    if !all(iszero, Gmin) || !all(==(1), s)
        Ar = reinterpretc(eltype(T), A)
        if T<:AbstractGray
            s1, offset1 = s[1], Gmin[1]
            for I in CartesianIndices(A)
                Ar[I] = Ar[I] * s1 + offset1
            end
        else
            for I in CartesianIndices(A)
                for j in eachindex(s)
                    Ar[j,I] = Ar[j,I] * s[j] + Gmin[j]
                end
            end
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
    mapc(f, rgb1, rgb2, rgb3) -> rgbf

`mapc` applies the function `f` to each color channel of the input
color(s), returning an output color in the same colorspace.

# Examples:

    julia> mapc(x->clamp(x,0,1), RGB(-0.2,0.3,1.2))
    RGB{Float64}(0.0,0.3,1.0)

    julia> mapc(clamp, RGB(-0.2,0.3,1.2), RGB(0, 0.4, 0.5), RGB(1, 0.8, 0.7))
    RGB{Float64}(0.0,0.4,0.7)

    julia> mapc(max, RGB(0.1,0.8,0.3), RGB(0.5,0.5,0.5))
    RGB{Float64}(0.5,0.8,0.5)

    julia> mapc(+, RGB(0.1,0.8,0.3), RGB(0.5,0.5,0.5))
    RGB{Float64}(0.6,1.3,0.8)
"""
@inline mapc(f, c::C) where {C<:ColorantN{1}} =
    base_colorant_type(C)(f(comp1(c)))
@inline mapc(f, c::C) where {C<:ColorantN{2}} =
    base_colorant_type(C)(f(comp1(c)), f(comp2(c)))
@inline mapc(f, c::C) where {C<:ColorantN{3}} =
    base_colorant_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)))
@inline mapc(f, c::C) where {C<:ColorantN{4}} =
    base_colorant_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)), f(comp4(c)))
@inline mapc(f, c::C) where {C<:ColorantN{5}} =
    base_colorant_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)), f(comp4(c)), f(comp5(c)))

@inline mapc(f, x::Number) = f(x)

# 2-arg mapc
mapc(f::F, x, y) where F = _mapc(_same_colorspace(x,y), f, x, y)
_mapc(::Type{C}, f, x::ColorantN{1}, y::ColorantN{1}) where C =
    C(f(comp1(x), comp1(y)))
_mapc(::Type{C}, f, x::ColorantN{2}, y::ColorantN{2}) where C =
    C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)))
_mapc(::Type{C}, f, x::ColorantN{3}, y::ColorantN{3}) where C =
    C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)))
_mapc(::Type{C}, f, x::ColorantN{4}, y::ColorantN{4}) where C =
    C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)), f(comp4(x), comp4(y)))
_mapc(::Type{C}, f, x::ColorantN{5}, y::ColorantN{5}) where C =
    C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)), f(comp4(x), comp4(y)), f(comp5(x), comp5(y)))

_same_colorspace(x::Colorant, y::Colorant) = _same_colorspace(base_colorant_type(x),
                                                              base_colorant_type(y))
_same_colorspace(::Type{C}, ::Type{C}) where {C<:Colorant} = C
@noinline _same_colorspace(::Type{C1}, ::Type{C2}) where {C1<:Colorant,C2<:Colorant} =
    throw(ArgumentError("$C1 and $C2 are from different colorspaces"))

# 3-arg mapc (useful for clamp)
mapc(f::F, x, y, z) where F = _mapc(_same_colorspace(x,y,z), f, x, y, z)
_mapc(::Type{C}, f, x::ColorantN{1}, y::ColorantN{1}, z::ColorantN{1}) where C =
    C(f(comp1(x), comp1(y), comp1(z)))
_mapc(::Type{C}, f, x::ColorantN{2}, y::ColorantN{2}, z::ColorantN{2}) where C =
    C(f(comp1(x), comp1(y), comp1(z)), f(comp2(x), comp2(y), comp2(z)))
_mapc(::Type{C}, f, x::ColorantN{3}, y::ColorantN{3}, z::ColorantN{3}) where C =
    C(f(comp1(x), comp1(y), comp1(z)), f(comp2(x), comp2(y), comp2(z)), f(comp3(x), comp3(y), comp3(z)))
_mapc(::Type{C}, f, x::ColorantN{4}, y::ColorantN{4}, z::ColorantN{4}) where C =
    C(f(comp1(x), comp1(y), comp1(z)), f(comp2(x), comp2(y), comp2(z)), f(comp3(x), comp3(y), comp3(z)),
      f(comp4(x), comp4(y), comp4(z)))
_mapc(::Type{C}, f, x::ColorantN{5}, y::ColorantN{5}, z::ColorantN{5}) where C =
    C(f(comp1(x), comp1(y), comp1(z)), f(comp2(x), comp2(y), comp2(z)), f(comp3(x), comp3(y), comp3(z)),
      f(comp4(x), comp4(y), comp4(z)), f(comp5(x), comp5(y), comp5(z)))

_same_colorspace(x::Colorant, y::Colorant, z::Colorant) =
    _same_colorspace(base_colorant_type(x), _same_colorspace(y, z))

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
@inline reducec(op, v0, c::ColorantN{1}) = op(v0, comp1(c))
@inline reducec(op, v0, c::ColorantN{2}) = op(comp2(c), op(v0, comp1(c)))
@inline reducec(op, v0, c::ColorantN{3}) = op(comp3(c), op(comp2(c), op(v0, comp1(c))))
@inline reducec(op, v0, c::ColorantN{4}) = op(comp4(c), op(comp3(c), op(comp2(c), op(v0, comp1(c)))))
@inline reducec(op, v0, c::ColorantN{5}) = op(comp5(c), op(comp4(c), op(comp3(c), op(comp2(c), op(v0, comp1(c))))))

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
@inline mapreducec(f, op, v0, c::ColorantN{1}) = op(v0, f(comp1(c)))
@inline mapreducec(f, op, v0, c::ColorantN{2}) = op(f(comp2(c)), op(v0, f(comp1(c))))
@inline mapreducec(f, op, v0, c::ColorantN{3}) =
    op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c)))))
@inline mapreducec(f, op, v0, c::ColorantN{4}) =
    op(f(comp4(c)), op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c))))))
@inline mapreducec(f, op, v0, c::ColorantN{5}) =
    op(f(comp5(c)), op(f(comp4(c)), op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c)))))))

@inline mapreducec(f, op, v0, x::Number) = op(v0, f(x))
