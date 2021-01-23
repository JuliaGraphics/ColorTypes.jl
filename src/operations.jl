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
gamutmax(::Type{T}) where {T<:LCHab} = (100,1,360) # FIXME
gamutmin(::Type{T}) where {T<:LCHab} = (0,0,0)
gamutmax(::Type{T}) where {T<:YIQ} = (1,0.5226,0.5226) # FIXME
gamutmin(::Type{T}) where {T<:YIQ} = (0,-0.5957,-0.5957) # FIXME

gamutmax(::Type{T}) where {T<:AbstractGray} = (1,)
gamutmin(::Type{T}) where {T<:AbstractGray} = (0,)
gamutmax(::Type{T}) where {T<:AbstractRGB} = (1,1,1)
gamutmin(::Type{T}) where {T<:AbstractRGB} = (0,0,0)

gamutmax(::Type{C}) where {C<:TransparentColor} = (gamutmax(color_type(C))..., 1)
gamutmin(::Type{C}) where {C<:TransparentColor} = (gamutmin(color_type(C))..., 0)

# rand
const Rand01Normd = Union{N0f8, N0f16, N0f32, N0f64}
const Rand01Type = Union{AbstractFloat, Rand01Normd}

# TODO: Remove the following once it is guaranteed to be implemented in FixedPointNumbers.
if which(rand, Tuple{AbstractRNG, SamplerType{<:FixedPoint}}).module === Random
    function rand(r::AbstractRNG, ::SamplerType{X}) where X <: FixedPoint
        reinterpret(X, rand(r, FixedPointNumbers.rawtype(X)))
    end
end

function rand(r::AbstractRNG, ::SamplerType{C}) where {C<:Colorant}
    rand(r, base_colorant_type(C){Float64})
end
function rand(r::AbstractRNG, ::SamplerType{C}) where {T, C<:Colorant{T}}
    Cmax = C(gamutmax(C)...)
    Cmin = C(gamutmin(C)...)
    mapc((m, n) -> T((m - n) * rand(r, floattype(T)) + n), Cmax, Cmin)
end
function rand(r::AbstractRNG, ::SamplerType{C}) where {T<:Rand01Type, C0<:AbstractGray{T},
                                                       C<:Union{C0, TransparentGray{C0, T}}}
    mapc(_ -> rand(r, T), base_colorant_type(C)())
end
function rand(r::AbstractRNG, ::SamplerType{C}) where {T<:Rand01Type, C0<:AbstractRGB{T},
                                                       C<:Union{C0, TransparentRGB{C0, T}}}
    mapc(_ -> rand(r, T), base_colorant_type(C)())
end
function rand(r::AbstractRNG, ::SamplerType{AGray32}) # Gray24 has little benefit of specialization.
    reinterpret(AGray32, (rand(r, UInt32) & 0xff0000ff) * 0x010101)
end
rand(r::AbstractRNG, ::SamplerType{RGB24}) = reinterpret(RGB24, rand(r, UInt32) & 0xffffff)
rand(r::AbstractRNG, ::SamplerType{ARGB32}) = reinterpret(ARGB32, rand(r, UInt32))

function rand(r::AbstractRNG, ::Type{C}, dims::Dims) where {C <: Colorant}
    CC = isconcretetype(C) ? C : base_colorant_type(C){Float64}
    rand!(r, Array{CC}(undef, dims), CC)
end

# rand!
function rand!(r::AbstractRNG, A::Array{C}, ::SamplerType{C}) where {C<:Colorant}
    rand!(r, A, SamplerType{base_colorant_type(C){Float64}}())
end
function rand!(r::AbstractRNG, A::Array{C}, ::SamplerType{C}) where {T, C<:Colorant{T}}
    A .= rand.((r,), C)
end
function _rand01!(r::AbstractRNG, A::Array{C},
               ::SamplerType{C}) where {T<:Rand01Type, C<:Colorant{T}}
    N = sizeof(C) ÷ sizeof(T)
    T0 = T <: FixedPoint ? FixedPointNumbers.rawtype(T) : T
    At = unsafe_wrap(Array, reinterpret(Ptr{T0}, pointer(A)), (N, size(A)...))
    rand!(r, At, T0)
    A
end
function rand!(r::AbstractRNG, A::Array{C},
               s::SamplerType{C}) where {T<:AbstractFloat, C<:Colorant{T}}
    _rand01!(r, A, s)
    Cmin = C(gamutmin(C)...)
    Cs = C((gamutmax(C) .- gamutmin(C))...)
    f(c) = mapc((a, b) -> T(a + b), mapc(*, c, Cs), Cmin)
    A .= f.(A)
end
function rand!(r::AbstractRNG, A::Array{C},
               s::SamplerType{C}) where {T<:Rand01Type, C<:Union{Gray{T}, AGray{T}, GrayA{T}}}
    _rand01!(r, A, s)
end
function rand!(r::AbstractRNG, A::Array{C},
               s::SamplerType{C}) where {T<:Rand01Type,
                                         C<:Union{RGB{T}, ARGB{T}, RGBA{T}, XRGB{T}, RGBX{T},
                                                  BGR{T}, ABGR{T}, BGRA{T}}}
    _rand01!(r, A, s)
end
function rand!(r::AbstractRNG, A::Array{C},
               ::SamplerType{C}) where {C<:Union{Gray24, AGray32, RGB24, ARGB32}}
    At = unsafe_wrap(Array, reinterpret(Ptr{UInt32}, pointer(A)), size(A))
    rand!(r, At, UInt32)
    if C === Gray24
        At .= At .& 0xff .* 0x010101
    elseif C === AGray32
        At .= At .& 0xff0000ff .* 0x010101
    elseif C === RGB24
        At .&= 0xffffff
    end
    A
end

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
