# iterator
struct ComponentIterator{C<:Colorant}
    c::C
end

eltype(::Type{ComponentIterator{C}}) where {T, C <: Colorant{T}} = T
length(::ComponentIterator{C}) where {N, C <: ColorantN{N}} = N

function Base.iterate(itr::ComponentIterator{C}, state::Int=0) where {N, C <: ColorantN{N}}
    state < 0 && return nothing
    state >= N && return nothing
    state += 1
    return (itr[state], state)
end

@inline function Base.getindex(itr::ComponentIterator{C}, i::Integer) where {N, C <: ColorantN{N}}
    N > 0 && i == 1 && return comp1(itr.c)
    N > 1 && i == 2 && return comp2(itr.c)
    N > 2 && i == 3 && return comp3(itr.c)
    N > 3 && i == 4 && return comp4(itr.c)
    N > 4 && i == 5 && return comp5(itr.c)
    throw(BoundsError(itr, i))
end
Base.getindex(itr::ComponentIterator, r::AbstractRange) = Tuple(itr[i] for i in r)
Base.getindex(itr::ComponentIterator, ::Colon) = itr

Base.firstindex(::ComponentIterator) = 1
Base.lastindex(itr::ComponentIterator) = length(itr)

function Base.BroadcastStyle(::Type{<:ComponentIterator{C}}) where {T, N, C <: Colorant{T, N}}
    Base.BroadcastStyle(NTuple{N, T})
end
Base.axes(::ComponentIterator{C}) where {N, C <: ColorantN{N}} = (Base.OneTo(N),)
Base.ndims(::Type{ComponentIterator{C}}) where {C} = 1
function Base.broadcastable(itr::ComponentIterator{C}) where {T, N, C <: Colorant{T, N}}
    (itr...,)::NTuple{N, T}
end

comps(c::Colorant) = ComponentIterator(c) # TODO: design public APIs


# comparison
_is_same_colorspace(a, b) = base_colorant_type(a) === base_colorant_type(b)
_is_same_colorspace(a::TransparentColor, b::TransparentColor) = base_color_type(a) === base_color_type(b)
_is_same_colorspace(a::AbstractGray, b::AbstractGray) = true
_is_same_colorspace(a::TransparentGray, b::TransparentGray) = true
_is_same_colorspace(a::AbstractRGB, b::AbstractRGB) = true
_is_same_colorspace(a::TransparentRGB, b::TransparentRGB) = true

function ==(a::ColorantN{N}, b::ColorantN{N}) where {N}
    _is_same_colorspace(a, b) || return false
    all(comps(a) .== comps(b))
end
==(x::Number, y::AbstractGray) = x == gray(y)
==(x::AbstractGray, y::Number) = ==(y, x)

function Base.isequal(a::ColorantN{N}, b::ColorantN{N}) where {N}
    _is_same_colorspace(a, b) || return false
    all(isequal.(comps(a), comps(b)))
end
Base.isequal(x::Number, y::AbstractGray) = isequal(x, gray(y))
Base.isequal(x::AbstractGray, y::Number) = isequal(y, x)


function isapprox(a::ColorantN{N}, b::ColorantN{N}; kwargs...) where {N}
    _is_same_colorspace(a, b) || return false
    componentapprox(x, y) = isapprox(x, y; kwargs...)
    all(componentapprox.(comps(a), comps(b)))
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
# the following values are based on the bounding boxes of sRGB gamut (D65).
gamutmin(::Type{<:ColorantN{N}}) where {N} = ntuple(_ -> 0, N) # fallback

gamutmax(::Type{<:AbstractGray}) = (1,)
gamutmax(::Type{<:AbstractRGB}) = (1, 1, 1)

gamutmax(::Type{<:Union{HSV, HSL, HSI}}) = (360, 1, 1)

gamutmax(::Type{<:XYZ}) = (0.9505, 1, 1.089)

gamutmax(::Type{<:xyY}) = (0.3127, 0.3290, 1)

gamutmax(::Type{<:Lab}) = (100, 98.2343, 94.4779)
gamutmin(::Type{<:Lab}) = (0, -86.1827, -107.8602)

gamutmax(::Type{<:Luv}) = (100, 175.0150, 107.3985)
gamutmin(::Type{<:Luv}) = (0, -83.077, -134.1030)

gamutmax(::Type{<:LCHab}) = (100, 133.8076, 360)

gamutmax(::Type{<:LCHuv}) = (100, 179.0414, 360)

gamutmax(::Type{<:DIN99}) = (100.0013, 36.1753, 31.1551)
gamutmin(::Type{<:DIN99}) = (0, -27.4504, -33.3955)

gamutmax(::Type{<:DIN99d}) = (100.0002, 43.6867, 43.6318)
gamutmin(::Type{<:DIN99d}) = (0, -38.1436, -45.8498)

gamutmax(::Type{<:DIN99o}) = (99.9997, 45.5242, 44.3662)
gamutmin(::Type{<:DIN99o}) = (0, -40.1101, -40.4900)

gamutmax(::Type{<:LMS}) = (0.9493, 1.0354, 1.0872)

gamutmax(::Type{<:YIQ}) = (1, 0.5957, 0.5226)
gamutmin(::Type{<:YIQ}) = (0, -0.5957, -0.5226)

gamutmax(::Type{<:YCbCr}) = (235, 240, 240)
gamutmin(::Type{<:YCbCr}) = (16, 16, 16)

gamutmax(::Type{<:Oklab}) = (1, 0.4, 0.4)
gamutmin(::Type{<:Oklab}) = (0, -0.4, -0.4)

gamutmax(::Type{<:Oklch}) = (1, 0.4, 360)

gamutmax(::Type{C}) where {C<:TransparentColor} = (gamutmax(color_type(C))..., 1)
gamutmin(::Type{C}) where {C<:TransparentColor} = (gamutmin(color_type(C))..., 0)

# rand
const Rand01Normd = Union{N0f8, N0f16, N0f32, N0f64}
const Rand01Type = Union{Bool, AbstractFloat, Rand01Normd}

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
    mapc(_ -> rand(r, T), C())
end
function rand(r::AbstractRNG, ::SamplerType{C}) where {T<:Rand01Type, C0<:AbstractRGB{T},
                                                       C<:Union{C0, TransparentRGB{C0, T}}}
    mapc(_ -> rand(r, T), C())
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
@inline mapc(f, c::C) where {C<:Colorant} = base_colorant_type(C)(f.(comps(c))...)
@inline mapc(f, x::Number) = f(x)

@inline mapc(f::F, x, y) where {F} = _same_colorspace(x, y)(f.(comps(x), comps(y))...)

_same_colorspace(x::Colorant, y::Colorant) = _same_colorspace(base_colorant_type(x),
                                                              base_colorant_type(y))
_same_colorspace(::Type{C}, ::Type{C}) where {C<:Colorant} = C
@noinline _same_colorspace(::Type{C1}, ::Type{C2}) where {C1<:Colorant,C2<:Colorant} =
    throw(ArgumentError("$C1 and $C2 are from different colorspaces"))

"""
    reducec(op, v0, c)
    reducec(op, c; [init])

Reduce across color channels of `c` with the binary operator `op`.
`v0` or `init` is the neutral element used to initiate the reduction.
For grayscale,

    reducec(op, v0, c::Gray) = op(v0, comp1(c))

whereas for RGB

    reducec(op, v0, c::RGB) = op(comp3(c), op(comp2(c), op(v0, comp1(c))))

If `c` has an alpha channel, it is always the last one to be folded into the reduction.

!!! compat "ColorTypes 0.12"
    The keyword argument `init` and its omission using the default value require
    ColorTypes v0.12 or later.
"""
@inline reducec(op, v0, c::C) where {C <: Colorant} = reduce(op, Tuple(c); init=v0)
@inline reducec(op, v0, x::Number) = op(v0, x)
@inline reducec(op, c::C; kw...) where {C <: Colorant} = reduce(op, Tuple(c); kw...)
@inline reducec(op, x::Number; kw...) = reduce(op, x; kw...)

"""
    mapreducec(f, op, v0, c)
    mapreducec(f, op, c; [init])

Reduce across color channels of `c` with the binary operator `op`,
first applying `f` to each channel.
`v0` or `init` is the neutral element used to initiate the reduction.
For grayscale,

    mapreducec(f, op, v0, c::Gray) = op(v0, f(comp1(c)))

whereas for RGB

    mapreducec(f, op, v0, c::RGB) = op(f(comp3(c)), op(f(comp2(c)), op(v0, f(comp1(c)))))

If `c` has an alpha channel, it is always the last one to be folded into the reduction.

!!! compat "ColorTypes 0.12"
    The keyword argument `init` and its omission using the default value require
    ColorTypes v0.12 or later.
"""
@inline mapreducec(f, op, v0, c::C) where {C <: Colorant} = reduce(op, f.(comps(c)); init=v0)
@inline mapreducec(f, op, v0, x::Number) = op(v0, f(x))
@inline mapreducec(f, op, c::C; kw...) where {C <: Colorant} = reduce(op, f.(comps(c)); kw...)
@inline mapreducec(f, op, x::Number; kw...) = reduce(op, f(x); kw...)
