# hash
hash(c::AbstractGray, hx::UInt) = hash(gray(c), hx)
hash(c::TransparentGray, hx::UInt) = hash(alpha(c), hash(gray(c), hx))
hash(c::AbstractRGB, hx::UInt) = hash(blue(c), hash(green(c), hash(red(c), hx)))
hash(c::TransparentRGB, hx::UInt) = hash(alpha(c), hash(blue(c), hash(green(c), hash(red(c), hx))))

# rand
typealias RandTypes{T,C} Union{AbstractRGB{T},
                               TransparentRGB{C,T},
                               AbstractGray{T},
                               TransparentGray{C,T}}
typealias RandTypesFloat{C,T<:AbstractFloat} RandTypes{T,C}

rand{G<:AbstractGray}(::Type{G}) = G(rand())
rand{G<:TransparentGray}(::Type{G}) = G(rand(), rand())
rand{C<:AbstractRGB}(::Type{C}) = C(rand(), rand(), rand())
rand{C<:TransparentRGB}(::Type{C}) = C(rand(), rand(), rand(), rand())
function rand{C<:RandTypesFloat}(::Type{C}, sz::Dims)
    reinterpret(C, rand(eltype(C), (sizeof(C)÷sizeof(eltype(C)), sz...)), sz)
end
function rand{C<:RandTypes{N0f8}}(::Type{C}, sz::Dims)
    reinterpret(C, rand(UInt8, (sizeof(C), sz...)), sz)
end
function rand{C<:RandTypes{N0f16}}(::Type{C}, sz::Dims)
    reinterpret(C, rand(UInt16, (sizeof(C)>>1, sz...)), sz)
end

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
mapc{C<:AbstractGray}(f, c::C) = base_color_type(C)(f(gray(c)))
mapc{C<:TransparentGray}(f, c::C) = base_colorant_type(C)(f(gray(c)), f(alpha(c)))
mapc{C<:Color3}(f, c::C) = base_color_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)))
mapc{C<:Transparent3}(f, c::C) = base_colorant_type(C)(f(comp1(c)), f(comp2(c)), f(comp3(c)), f(alpha(c)))

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
