# Core traits and accessor functions

"""
`alpha(p)` extracts the alpha component of a color. For a color
without an alpha channel, it will always return 1.
"""
alpha(c::TransparentColor) = c.alpha
alpha(c::Color)   = oneunit(eltype(c))
alpha(c::RGB24)   = N0f8(1)
alpha(c::ARGB32)  = N0f8((c.color & 0xff000000)>>24, 0)
alpha(c::AGray32) = N0f8((c.color & 0xff000000)>>24, 0)

"`red(c)` returns the red component of an `AbstractRGB` opaque or transparent color."
red(c::AbstractRGB   ) = c.r
red(c::TransparentRGB) = c.r
red(c::RGB24)  = N0f8((c.color & 0x00ff0000)>>16, 0)
red(c::ARGB32) = N0f8((c.color & 0x00ff0000)>>16, 0)

"`green(c)` returns the green component of an `AbstractRGB` opaque or transparent color."
green(c::AbstractRGB   ) = c.g
green(c::TransparentRGB) = c.g
green(c::RGB24)  = N0f8((c.color & 0x0000ff00)>>8, 0)
green(c::ARGB32) = N0f8((c.color & 0x0000ff00)>>8, 0)

"`blue(c)` returns the blue component of an `AbstractRGB` opaque or transparent color."
blue(c::AbstractRGB   ) = c.b
blue(c::TransparentRGB) = c.b
blue(c::RGB24)  = N0f8(c.color & 0x000000ff, 0)
blue(c::ARGB32) = N0f8(c.color & 0x000000ff, 0)

"`gray(c)` returns the gray component of a grayscale opaque or transparent color."
gray(c::Gray)    = c.val
gray(c::TransparentGray) = c.val
gray(c::Gray24)  = N0f8(c.color & 0x000000ff, 0)
gray(c::AGray32) = N0f8(c.color & 0x000000ff, 0)
gray(x::Number)  = x

Base.real(g::Gray) = gray(g)

# Extract the first, second, and third arguments as you'd
# pass them to the constructor
"""
`comp1(c)` extracts the first component you'd pass to the constructor
of the corresponding object.  For most color types without an alpha
channel, this is just the first field, but for types like `BGR` that
reverse the internal storage order this provides the value that you'd
use to reconstruct the color.

Specifically, for any `Color{T,3}`,

    c == typeof(c)(comp1(c), comp2(c), comp3(c))

returns true.
"""
comp1(c::AbstractRGB) = red(c)
comp1(c::Union{AlphaColor{C},ColorAlpha{C}}) where {C<:AbstractRGB} = red(c)
comp1(c::Union{Color,ColorAlpha}) = getfield(c, 1)
comp1(c::AlphaColor) = getfield(c, 2)
comp1(c::AGray32) = gray(c)

"`comp2(c)` extracts the second constructor argument (see `comp1`)."
comp2(c::AbstractRGB) = green(c)
comp2(c::Union{AlphaColor{C},ColorAlpha{C}}) where {C<:AbstractRGB} = green(c)
comp2(c::Union{Color,ColorAlpha}) = getfield(c, 2)
comp2(c::AlphaColor) = getfield(c, 3)

"`comp3(c)` extracts the third constructor argument (see `comp1`)."
comp3(c::AbstractRGB) = blue(c)
comp3(c::Union{AlphaColor{C},ColorAlpha{C}}) where {C<:AbstractRGB} = blue(c)
comp3(c::Union{Color,ColorAlpha}) = getfield(c, 3)
comp3(c::AlphaColor) = getfield(c, 4)

"`color(c)` extracts the opaque color component from a Colorant (e.g., omits the alpha channel, if present)."
color(c::Color) = c
color(c::TransparentColor{C,T,4}) where {C,T} = C(comp1(c), comp2(c), comp3(c))
color(c::TransparentColor{C,T,2}) where {C,T} = C(comp1(c))

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# recurse up the type hierarchy until you get to Colorant{T,N} for
# specific T,N.
to_top(::Type{Colorant{T,N}}) where {T,N} = Colorant{T,N}
@pure to_top(::Type{C}) where {C<:Colorant} = to_top(supertype(C))

to_top(c::Colorant) = to_top(typeof(c))

# eltype(RGB{Float32}) -> Float32
eltype(::Type{Colorant{T}}) where {T          }   = T
eltype(::Type{Colorant{T,N}}) where {T,N        } = T
@pure eltype(::Type{C}) where {C<:Colorant} = eltype(supertype(C))

eltype(c::Colorant) = eltype(typeof(c))

# eltypes_supported(Colorant{T<:X}) -> T<:X (pre 0.6) or X (post 0.6)
@pure eltypes_supported(::Type{C}) where {C<:Colorant} =
    Base.parameter_upper_bound(base_colorant_type(C), 1)

eltypes_supported(c::Colorant) = eltypes_supported(typeof(c))

@pure issupported(::Type{C}, ::Type{T}) where {C<:Colorant,T} = T <: eltypes_supported(C)

"""
`color_type(c)` or `color_type(C)` (`c` being a color instance and `C`
being the type) returns the type of the Color object (without
alpha channel).  This, and related functions like `base_color_type`,
`base_colorant_type`, and `ccolor` are useful for manipulating types for
writing generic code.

For example,

    color_type(RGB)          == RGB
    color_type(RGB{Float32}) == RGB{Float32}
    color_type(ARGB{N0f8})     == RGB{N0f8}
"""
color_type(::Type{TransparentColor})        = Color
color_type(::Type{C}) where {C<:Color} = C
color_type(c::Colorant) = color_type(typeof(c))

# Return the number of components in the color
# Note this is different from div(sizeof(c), sizeof(eltype(c))) (e.g., RGB1)
length(c::Colorant) = length(typeof(c))

length(::Type{C}) where C<:(Colorant{T,N} where T) where N = N
# This definition should be unnecessary, but julia currently incorrectly
# dispatches to the first definition below, even when the second is
# applicable.
_color_type(::Type{TC}) where TC<:(TransparentColor{C, T, N} where T where N) where C = C
color_type(::Type{TC}) where TC<:TransparentColor =
    isa(TC, UnionAll) ? Base.parameter_upper_bound(TC, 1) : _color_type(TC)
color_type(::Type{TC}) where TC<:(TransparentColor{C, T, N} where T where N) where C = C

@pure color_type(::Type{C}) where {C<:AlphaColor} = color_type(supertype(C))
@pure color_type(::Type{C}) where {C<:ColorAlpha} = color_type(supertype(C))

"""
`base_color_type` is similar to `color_type`, except it "strips off" the
element type.  For example,

    color_type(RGB{N0f8})     == RGB{N0f8}
    base_color_type(RGB{N0f8}) == RGB

This can be very handy if you want to switch element types. For example:

    c64 = base_color_type(c){Float64}(color(c))

converts `c` into a `Float64` representation (potentially discarding
any alpha-channel information).
"""
base_color_type(::Type{C}) where {C<:Colorant} = base_colorant_type(color_type(C))

base_color_type(c::Colorant) = base_color_type(typeof(c))
base_color_type(x::Number)   = Gray

@pure basetype(T) = Base.typename(T).wrapper
base_colorant_type(::Type{C}) where {C<:Colorant} = basetype(C)

"""
`base_colorant_type` is similar to `base_color_type`, but it preserves the
"alpha" portion of the type.

For example,

    base_color_type(ARGB{N0f8})  == RGB
    base_colorant_type(ARGB{N0f8})  == ARGB

If you just want to switch element types, this is the safest default
and the easiest to use:

    c64 = base_colorant_type(c){Float64}(c)
"""
base_colorant_type(c::Colorant) = base_colorant_type(typeof(c))

colorant_string(::Type{Union{}}) = "Union{}"
colorant_string(::Type{C}) where {C<:Colorant} = string(nameof(C))
function colorant_string_with_eltype(::Type{C}) where {C<:Colorant}
    io = IOBuffer()
    colorant_string_with_eltype(io, C)
    String(take!(io))
end
colorant_string_with_eltype(io::IO, ::Type{Union{}}) = show(io, Union{})
function colorant_string_with_eltype(io::IO, ::Type{C}) where {C<:Colorant}
    print(io, colorant_string(C), '{')
    showcoloranttype(io, eltype(C))
    print(io, '}')
end
# Nonparametric types
colorant_string_with_eltype(io::IO, ::Type{Gray24})  = print(io, "Gray24")
colorant_string_with_eltype(io::IO, ::Type{AGray32}) = print(io, "AGray32")
colorant_string_with_eltype(io::IO, ::Type{RGB24})   = print(io, "RGB24")
colorant_string_with_eltype(io::IO, ::Type{ARGB32})  = print(io, "ARGB32")

showcoloranttype(io, ::Type{Union{}}) = show(io, Union{})
showcoloranttype(io, ::Type{T}) where {T<:FixedPoint} = FixedPointNumbers.showtype(io, T)
showcoloranttype(io, ::Type{T}) where {T} = show(io, T)


"""
 `ccolor` ("concrete color") helps write flexible methods. The idea is
that users may write `convert(HSV, c)` or even `convert(Array{HSV},
A)` without specifying the element type explicitly (e.g.,
`convert(Array{HSV{Float32}}, A)`). `ccolor` implements the logic "choose the
user's eltype if specified, otherwise retain the eltype of the source
object." However, when the source object has FixedPoint element type,
and the destination only supports AbstractFloat, we choose Float32.

Usage:

    ccolor(desttype, srctype) -> concrete desttype

Example:

    convert{C<:Colorant}(::Type{C}, p::Colorant) = cnvt(ccolor(C,typeof(p)), p)

where `cnvt` is the function that performs explicit conversion.
"""
ccolor(::Type{Colorant   }, ::Type{Csrc}) where {   Csrc<:Colorant} = Csrc
ccolor(::Type{Colorant{T}}, ::Type{Csrc}) where {T, Csrc<:Colorant} = base_colorant_type(Csrc){T}
ccolor(::Type{Colorant{T,3}}, ::Type{Csrc}) where {T, Csrc<:Color3  } = Csrc
ccolor(::Type{Colorant{T,3}}, ::Type{Csrc}) where {T, Csrc<:Transparent3} = base_color_type(Csrc)
ccolor(::Type{Color   }, ::Type{Csrc}) where {   Csrc<:Colorant} = color_type(Csrc)
ccolor(::Type{Color{T}}, ::Type{Csrc}) where {T, Csrc<:Colorant} = base_color_type(Csrc){T}

ccolor(::Type{TransparentColor}, ::Type{Csrc}) where {Csrc<:Color} =
          error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor(
::Type{TransparentColor{C    }}, ::Type{Csrc}) where {C<:Color,    Csrc<:Color} =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor(
::Type{TransparentColor{C,T  }}, ::Type{Csrc}) where {C<:Color,T,  Csrc<:Color} =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor(
::Type{TransparentColor{C,T,N}}, ::Type{Csrc}) where {C<:Color,T,N,Csrc<:Color} =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")

ccolor(::Type{TransparentColor}, ::Type{Csrc}) where {Csrc<:TransparentColor} = Csrc

ccolor(::Type{AlphaColor}, ::Type{Csrc}) where {Csrc<:Colorant} = alphacolor(Csrc)
ccolor(
::Type{AlphaColor{C    }}, ::Type{Csrc}) where {C<:Color,    Csrc<:Colorant} = ccolor(alphacolor(C), Csrc)
ccolor(
::Type{AlphaColor{C,T  }}, ::Type{Csrc}) where {C<:Color,T,  Csrc<:Colorant} = ccolor(alphacolor(C){T}, Csrc)
ccolor(
::Type{AlphaColor{C,T,N}}, ::Type{Csrc}) where {C<:Color,T,N,Csrc<:Colorant} = ccolor(alphacolor(C){T}, Csrc)

ccolor(::Type{ColorAlpha}, ::Type{Csrc}) where {Csrc<:Colorant} = coloralpha(Csrc)
ccolor(
::Type{ColorAlpha{C    }}, ::Type{Csrc}) where {C<:Color,    Csrc<:Colorant} = ccolor(coloralpha(C), Csrc)
ccolor(
::Type{ColorAlpha{C,T  }}, ::Type{Csrc}) where {C<:Color,T,  Csrc<:Colorant} = ccolor(coloralpha(C){T}, Csrc)
ccolor(
::Type{ColorAlpha{C,T,N}}, ::Type{Csrc}) where {C<:Color,T,N,Csrc<:Colorant} = ccolor(coloralpha(C){T}, Csrc)

ccolor(::Type{AbstractRGB},    ::Type{Csrc}) where {  Csrc<:AbstractRGB} = Csrc
ccolor(::Type{AbstractRGB{T}}, ::Type{Csrc}) where {T,Csrc<:AbstractRGB} = base_colorant_type(Csrc){T}

# Generic concrete types
ccolor(::Type{Cdest}, ::Type{Csrc}) where {Cdest<:Colorant,Csrc<:Colorant} = _ccolor(Cdest, Csrc, pick_eltype(Cdest, eltype(Cdest), eltype(Csrc)))
ccolor(::Type{Cdest}, ::Type{T}) where {Cdest<:AbstractGray,T<:Number} = _ccolor(Cdest, Gray, pick_eltype(Cdest, eltype(Cdest), T))

_ccolor(::Type{Cdest}, ::Type{Csrc}, ::Type{T}) where {Cdest,Csrc,T<:Number} =
    isconcretetype(T) ? base_colorant_type(Cdest){T} :
                    base_colorant_type(Cdest){S} where S<:T

_ccolor(          ::Type{Cdest}, ::Type{Csrc}, ::Any) where {Cdest,Csrc}     = Cdest

# Specific concrete types
ccolor(::Type{RGB24},   ::Type{Csrc}) where {Csrc<:Colorant} = RGB24
ccolor(::Type{ARGB32},  ::Type{Csrc}) where {Csrc<:Colorant} = ARGB32
ccolor(::Type{Gray24},  ::Type{Csrc}) where {Csrc<:Colorant} = Gray24
ccolor(::Type{AGray32}, ::Type{Csrc}) where {Csrc<:Colorant} = AGray32

pick_eltype(::Type{C}, ::Type{T1}, ::Type{T2}) where {C,T1<:Number,T2<:Number} = T1
pick_eltype(::Type{C}, ::Any, ::Any) where {C} = eltypes_supported(C)
pick_eltype(::Type{C}, ::Any, ::Type{T2}) where {C,T2<:Number} = issupported(C, T2) ? T2 : eltype_default(C)

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

for T in (RGB24, ARGB32, Gray24, AGray32)
    @eval begin
        reinterpret(::Type{UInt32}, x::$T) = x.color
        reinterpret(::Type{$T}, x::UInt32) = $T(x, Val{true})
    end
end
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

Base.broadcastable(x::Colorant) = Ref(x)
