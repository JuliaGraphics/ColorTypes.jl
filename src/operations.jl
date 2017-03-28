# hash
hash(c::AbstractGray, hx::UInt) = hash(gray(c), hx)
hash(c::TransparentGray, hx::UInt) = hash(alpha(c), hash(gray(c), hx))
hash(c::AbstractRGB, hx::UInt) = hash(blue(c), hash(green(c), hash(red(c), hx)))
hash(c::TransparentRGB, hx::UInt) = hash(alpha(c), hash(blue(c), hash(green(c), hash(red(c), hx))))

# gamut{min,max}
gamutmax{T<:HSV}(::Type{T}) = (360,1,1)
gamutmin{T<:HSV}(::Type{T}) = (0,0,0)
gamutmax{T<:HSL}(::Type{T}) = (360,1,1)
gamutmin{T<:HSL}(::Type{T}) = (0,0,0)
gamutmax{T<:Lab}(::Type{T}) = (100,1,1)
gamutmin{T<:Lab}(::Type{T}) = (0,0,0)
gamutmax{T<:LCHab}(::Type{T}) = (100,1,360)
gamutmin{T<:LCHab}(::Type{T}) = (0,0,0)
gamutmax{T<:YIQ}(::Type{T}) = (1,0.5226,0.5226)
gamutmin{T<:YIQ}(::Type{T}) = (0,-0.5957,-0.5957)

gamutmax{T<:AbstractGray}(::Type{T}) = (1,)
gamutmax{T<:TransparentGray}(::Type{T}) = (1,1)
gamutmax{T<:AbstractRGB}(::Type{T}) = (1,1,1)
gamutmax{T<:TransparentRGB}(::Type{T}) = (1,1,1,1)
gamutmin{T<:AbstractGray}(::Type{T}) = (0,)
gamutmin{T<:TransparentGray}(::Type{T}) = (0,0)
gamutmin{T<:AbstractRGB}(::Type{T}) = (0,0,0)
gamutmin{T<:TransparentRGB}(::Type{T}) = (0,0,0,0)

# rand
for t in [Float16,Float32,Float64,N0f8,N0f16,N0f32]
    @eval _rand{T<:Union{AbstractRGB{$t},AbstractGray{$t}}}(::Type{T}) =
          mapc(x->rand(eltype(T)), base_colorant_type(T)())
end

function _rand{T<:Colorant}(::Type{T})
    Gmax = gamutmax(T)
    Gmin = gamutmin(T)
    Mi = eltype(T) <: FixedPoint ? 1.0/typemax(eltype(T)) : 1.0
    A = rand(eltype(T), length(T))
    for j in eachindex(Gmax)
        A[j] = A[j] * (Mi * (Gmax[j]-Gmin[j])) + Gmin[j]
    end
    T(A...)
end

function _rand{T<:Colorant}(::Type{T}, sz::Dims)
    Gmax = gamutmax(T)
    Gmin = gamutmin(T)
    Mi = eltype(T) <: FixedPoint ? 1.0/typemax(eltype(T)) : 1.0
    A = rand(eltype(T), (div(sizeof(T), sizeof(eltype(T))), sz...))
    for j in eachindex(Gmax)
        s = Mi * (Gmax[j]-Gmin[j])
        for i = j:length(Gmax):length(A)
            A[i] = A[i] * s + Gmin[j]
        end
    end
    reinterpret(T, A, sz)
end

rand{T<:Colorant}(::Type{T}, sz::Dims...) = _rand(ccolor(T, base_colorant_type(T){Float64}), sz...)

rand(::Type{Gray24}) = Gray24(rand(N0f8))
rand(::Type{Gray24}, sz::Dims) = Gray24.(rand(N0f8,sz))
rand(::Type{AGray32}) = AGray32(rand(N0f8),rand(N0f8))
rand(::Type{AGray32}, sz::Dims) = AGray32.(rand(N0f8,sz),rand(N0f8,sz))

# broadcast
# Without this, Gray.(a) returns an Array{Gray}, which does not have concrete eltype
Base.broadcast{C<:Colorant}(::Type{C}, A::AbstractArray) = _broadcast(C, eltype(C), A)
if VERSION < v"0.5.0-dev+4754"
    _broadcast{C<:Colorant,T<:Number}(::Type{C}, ::Type{T}, A) = broadcast!(C, Array(C, size(A)), A)
else
    _broadcast{C<:Colorant,T<:Number}(::Type{C}, ::Type{T}, A) = broadcast!(C, similar(Array{C}, indices(A)), A)
end
function _broadcast{C<:Colorant}(::Type{C}, ::Any, A)
    Cnew = ccolor(C, eltype(A))
    _broadcast(Cnew, eltype(Cnew), A)
end


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
@inline mapc{C<:AbstractGray}(f, c::C) = base_color_type(C)(f(gray(c)))
@inline mapc{C<:TransparentGray}(f, c::C) = base_colorant_type(C)(f(gray(c)), f(alpha(c)))
@inline mapc{C<:Color3}(f, c::C) = base_color_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)))
@inline mapc{C<:Transparent3}(f, c::C) = base_colorant_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)), f(alpha(c)))

@inline mapc(f, x::Number) = f(x)

mapc(f, x, y) = _mapc(_same_colorspace(x,y), f, x, y)
_mapc{C<:AbstractGray}(::Type{C}, f, x, y) = C(f(gray(x), gray(y)))
_mapc{C<:TransparentGray}(::Type{C}, f, x, y) = C(f(gray(x), gray(y)), f(alpha(x), alpha(y)))
_mapc{C<:Color3}(::Type{C}, f, x, y) = C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)))
_mapc{C<:Transparent3}(::Type{C}, f, x, y) = C(f(comp1(x), comp1(y)), f(comp2(x), comp2(y)), f(comp3(x), comp3(y)), f(alpha(x), alpha(y)))

_same_colorspace(x::Colorant, y::Colorant) = _same_colorspace(base_colorant_type(x),
                                                              base_colorant_type(y))
_same_colorspace{C<:Colorant}(::Type{C}, ::Type{C}) = C
@noinline _same_colorspace{C1<:Colorant,C2<:Colorant}(::Type{C1}, ::Type{C2}) =
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
