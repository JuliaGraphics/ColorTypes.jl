### Equality
function ==(c1::AbstractRGB, c2::AbstractRGB)
    red(c1) == red(c2) && green(c1) == green(c2) && blue(c1) == blue(c2)
end
==(c1::HSV, c2::HSV) = c1.h == c2.h && c1.s == c2.s && c1.v == c2.v
==(c1::HSI, c2::HSI) = c1.h == c2.h && c1.s == c2.s && c1.i == c2.i
==(c1::HSL, c2::HSL) = c1.h == c2.h && c1.s == c2.s && c1.l == c2.l
==(c1::XYZ, c2::XYZ) = c1.x == c2.x && c1.y == c2.y && c1.z == c2.z
==(c1::xyY, c2::xyY) = c1.x == c2.x && c1.y == c2.y && c1.Y == c2.Y
==(c1::Lab, c2::Lab) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::Luv, c2::Luv) = c1.l == c2.l && c1.u == c2.u && c1.v == c2.v
==(c1::LCHab, c2::LCHab) = c1.l == c2.l && c1.c == c2.c && c1.h == c2.h
==(c1::LCHuv, c2::LCHuv) = c1.l == c2.l && c1.c == c2.c && c1.h == c2.h
==(c1::DIN99, c2::DIN99) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::DIN99d, c2::DIN99d) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::DIN99o, c2::DIN99o) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::LMS, c2::LMS) = c1.l == c2.l && c1.m == c2.m && c1.s == c2.s
==(c1::YIQ, c2::YIQ) = c1.y == c2.y && c1.i == c2.i && c1.q == c2.q
==(c1::YCbCr, c2::YCbCr) = c1.y == c2.y && c1.cb == c2.cb && c1.cr == c2.cr

==(x::AbstractGray, y::AbstractGray) = gray(x) == gray(y)
==(x::Number, y::AbstractGray) = x == gray(y)
==(x::AbstractGray, y::Number) = ==(y, x)

function ==(x::TransparentColor, y::TransparentColor)
    color(x) == color(y) && alpha(x) == alpha(y)
end


struct BoolTuple end
@inline BoolTuple(args::Bool...) = (args...,)

function _isapprox(a::Colorant, b::Colorant; kwargs...)
    componentapprox(x, y) = isapprox(x, y; kwargs...)
    all(ColorTypes._mapc(BoolTuple, componentapprox, a, b))
end
isapprox(a::C, b::C; kwargs...) where {C<:Colorant} =
    _isapprox(a, b; kwargs...)
isapprox(a::Colorant, b::Colorant; kwargs...) =
    _isapprox(base_colorant_type(a), base_colorant_type(b), a, b; kwargs...)
_isapprox(::Type{C}, ::Type{C}, a, b; kwargs...) where {C<:Colorant} =
    _isapprox(a, b; kwargs...)
_isapprox(::Type{<:AbstractRGB}, ::Type{<:AbstractRGB}, a, b; kwargs...) =
    _isapprox(RGB(a), RGB(b); kwargs...)
_isapprox(::Type{<:AbstractGray}, ::Type{<:AbstractGray}, a, b; kwargs...) =
    isapprox(gray(a), gray(b); kwargs...)
_isapprox(TA::Type, TB::Type, a, b; kwargs...) = false
isapprox(x::Number, y::AbstractGray; kwargs...) =
    isapprox(x, gray(y); kwargs...)
isapprox(x::AbstractGray, y::Number; kwargs...) =
    isapprox(y, x; kwargs...)


zero(::Type{C}) where {C<:Gray} = C(0)
oneunit(::Type{C}) where {C<:Gray} = C(1)

function Base.one(::Type{C}) where {C<:Gray}
    Base.depwarn("one($C) will soon switch to returning 1; you might need to switch to `oneunit`", :one)
    C(1)
end

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

mapc(f::F, x, y) where F = _mapc(_same_colorspace(x,y), f, x, y)
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
