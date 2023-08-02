"""
`Colorant{T,N}` is the abstract super-type of all types in ColorTypes,
and refers to both (opaque) colors and colors-with-transparency (alpha
channel) information.  `T` is the element type (extractable with
`eltype`) and `N` is the number of *meaningful* entries (extractable
with `length`), i.e., the number of arguments you would supply to the
constructor.
"""
abstract type Colorant{T,N} end

# Colors (without transparency)
"""
`Color{T,N}` is the abstract supertype for a color (or
grayscale) with no transparency.
"""
abstract type Color{T, N} <: Colorant{T,N} end

"""
`AbstractGray{T}` is an abstract supertype for gray types which corresponds to
real numbers, where `0` means black and `1` means white.

!!! compat "ColorTypes v0.12"
    Prior to ColorTypes v0.12, `AbstractGray{T}` was the alias for `Color{T,1}`;
    after ColorTypes v0.12, `Color{T,1}` does not necessarily correspond to the
    black-gray-white colors.
"""
abstract type AbstractGray{T} <: Color{T,1} end

"""
`AbstractRGB{T}` is an abstract supertype for red/green/blue color types that
can be constructed as `C(r, g, b)` and for which the elements can be
extracted as `red(c)`, `green(c)`, `blue(c)`. You should *not* make
assumptions about internal storage order, the number of fields, or the
representation. One `AbstractRGB` color-type, `RGB24`, is not
parametric and does not have fields named `r`, `g`, `b`.
"""
abstract type AbstractRGB{T} <: Color{T,3} end


# Types with transparency
"""
`TransparentColor{C,T,N}` is the abstract type for any
color-with-transparency.  The `C` parameter refers to the type of the
pure color (without transparency) and can be extracted with
`color_type`. `T` is the element type of both `C` and the `alpha`
channel, and `N` has the same meaning as in `Colorant` (and is 1 larger
than the corresponding color type).

All transparent types should support two modes of construction:

    P(color, alpha)
    P(component1, component2, component3, alpha) (assuming a 3-component color)

For a `Colorant` `c`, the color component can be extracted with
`color(c)`, and the alpha channel with `alpha(c)`. Note that types
such as `ARGB32` do not have a field named `alpha`.

Most concrete types, like `RGB`, have both `ARGB` and `RGBA`
transparent analogs.  These two indicate different internal storage
order (see `AlphaColor` and `ColorAlpha`, and the `alphacolor` and
`coloralpha` functions).
"""
abstract type TransparentColor{C<:Color,T,N} <: Colorant{T,N} end

"""
`AlphaColor` is an abstract supertype for types like `ARGB`, where the
alpha channel comes first in the internal storage order. **Note** that
the constructor order is still `(color, alpha)`.
"""
abstract type AlphaColor{C<:Color,T,N} <: TransparentColor{C,T,N} end

"""
`ColorAlpha` is an abstract supertype for types like `RGBA`, where the
alpha channel comes last in the internal storage order.
"""
abstract type ColorAlpha{C<:Color,T,N} <: TransparentColor{C,T,N} end

# These are types we'll dispatch on.
Color3{T}                          = Color{T,3}
TransparentGray{C<:AbstractGray,T} = TransparentColor{C,T,2}
Transparent3{C<:Color3,T}          = TransparentColor{C,T,4}
TransparentRGB{C<:AbstractRGB,T}   = TransparentColor{C,T,4}
ColorantNormed{T<:Normed,N}        = Colorant{T,N}
AbstractAGray{C<:AbstractGray,T}   = AlphaColor{C,T,2}
AbstractGrayA{C<:AbstractGray,T}   = ColorAlpha{C,T,2}
AbstractARGB{C<:AbstractRGB,T}     = AlphaColor{C,T,4}
AbstractRGBA{C<:AbstractRGB,T}     = ColorAlpha{C,T,4}

# With reordered type parameters (also useful for dispatch)
ColorantN{N,T}                  = Colorant{T,N}
ColorN{N,T}                     = Color{T,N}
TransparentColorN{N,C<:Color,T} = TransparentColor{C,T,N}
AlphaColorN{N,C<:Color,T}       = AlphaColor{C,T,N}
ColorAlphaN{N,C<:Color,T}       = ColorAlpha{C,T,N}

"""
`RGB` is the standard Red-Green-Blue (sRGB) colorspace.  Values of the
individual color channels range from 0 (black) to 1 (saturated). If
you want "Integer" storage types (e.g., 255 for full color), use `N0f8(1)`
instead (see FixedPointNumbers).
"""
struct RGB{T<:Fractional} <: AbstractRGB{T}
    r::T # Red [0,1]
    g::T # Green [0,1]
    b::T # Blue [0,1]

    RGB{T}(r::T, g::T, b::T) where {T <: Fractional} = new{T}(r, g, b)
end

"""
`BGR` is a variant of `RGB` with the opposite storage order.  Note
that the constructor is still called in the order `BGR(r, g, b)`.
This storage order is noteworthy because on little-endian machines,
`BGRA` (with transparency) can be `reinterpret`ed to the `UInt32`
color format used by libraries such as Cairo and OpenGL.
"""
struct BGR{T<:Fractional} <: AbstractRGB{T}
    b::T
    g::T
    r::T

    BGR{T}(r::T, g::T, b::T) where {T <: Fractional} = new{T}(b, g, r)
end

"""
`XRGB` is a variant of `RGB` which has a padding element inserted at
the beginning. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`XRGB(r, g, b)`.
"""
struct XRGB{T<:Fractional} <: AbstractRGB{T}
    alphadummy::T
    r::T
    g::T
    b::T

    XRGB{T}(r::T, g::T, b::T) where {T <: Fractional} = new{T}(oneunit(T), r, g, b)
end

"""
`RGBX` is a variant of `RGB` which has a padding element inserted at
the end. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGBX(r, g, b)`.
"""
struct RGBX{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGBX{T}(r::T, g::T, b::T) where {T <: Fractional} = new{T}(r, g, b, oneunit(T))
end

"`HSV` is the Hue-Saturation-Value colorspace."
struct HSV{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end

"`HSB` (Hue-Saturation-Brightness) is an alias for `HSV`."
const HSB = HSV

"`HSL` is the Hue-Saturation-Lightness colorspace."
struct HSL{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end

"`HSI` is the Hue-Saturation-Intensity colorspace."
struct HSI{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    i::T # Intensity in [0,1]
end

"""
`XYZ` is the CIE 1931 XYZ colorspace. It is a linear colorspace,
meaning that mathematical operations such as addition, subtraction,
and scaling make "colorimetric sense" in this colorspace.
"""
struct XYZ{T<:AbstractFloat} <: Color{T,3}
    x::T
    y::T
    z::T
end

"`xyY` is the CIE 1931 xyY (chromaticity + luminance) space"
struct xyY{T<:AbstractFloat} <: Color{T,3}
    x::T
    y::T
    Y::T
end

"`Lab` is the CIELAB colorspace."
struct Lab{T<:AbstractFloat} <: Color{T,3}
    l::T # Lightness in [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end

"`LCHab` is the Luminance-Chroma-Hue, Polar-Lab colorspace"
struct LCHab{T<:AbstractFloat} <: Color{T,3}
    l::T # Lightness in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end

"`Luv` is the CIELUV colorspace"
struct Luv{T<:AbstractFloat} <: Color{T,3}
    l::T # Lightness in [0,100]
    u::T # Red/Green
    v::T # Blue/Yellow
end

"`LCHuv` is the Luminance-Chroma-Hue, Polar-Luv colorspace"
struct LCHuv{T<:AbstractFloat} <: Color{T,3}
    l::T # Lightness in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end

"`DIN99` is the (L99, a99, b99) adaptation of CIELAB"
struct DIN99{T<:AbstractFloat} <: Color{T,3}
    l::T # L99
    a::T # a99
    b::T # b99
end

"`DIN99d` is the (L99d, a99d, b99d) improvement on DIN99"
struct DIN99d{T<:AbstractFloat} <: Color{T,3}
    l::T # L99d
    a::T # a99d
    b::T # b99d
end

"`DIN99o` is the (L99o, a99o, b99o) adaptation of CIELAB"
struct DIN99o{T<:AbstractFloat} <: Color{T,3}
    l::T # L99o
    a::T # a99o
    b::T # b99o
end

"""
`LMS` is the Long-Medium-Short colorspace based on activation of the
three cone photoreceptors.  Like `XYZ`, this is a linear color space.
"""
struct LMS{T<:AbstractFloat} <: Color{T,3}
    l::T # Long
    m::T # Medium
    s::T # Short
end

"`YIQ` is a color encoding, for example used in NTSC transmission."
struct YIQ{T<:AbstractFloat} <: Color{T,3}
    y::T
    i::T
    q::T
end

"`YCbCr` is the Y'CbCr color encoding often used in digital photography or video"
struct YCbCr{T<:AbstractFloat} <: Color{T,3}
    y::T
    cb::T
    cr::T
end

"`Oklab` is the Oklab colorspace."
struct Oklab{T<:AbstractFloat} <: Color{T,3}
    l::T # Lightness in [0,1]
    a::T # Red/Green
    b::T # Blue/Yellow
end

"`Oklch` is the Luminance-Chroma-Hue, Polar-Oklab colorspace."
struct Oklch{T<:AbstractFloat} <: Color{T,3}
    l::T # Lightness in [0,1]
    c::T # Chroma
    h::T # Hue in [0,360]
end

"""
`RGB24` uses a `UInt32` representation of color, 0xAARRGGBB, where
R=red, G=green, B=blue and A is irrelevant. This format is often used
by external libraries such as Cairo.

`RGB24` colors do not have fields named `r`, `g`, `b`, but you can
still extract the individual components with `red(c)`, `green(c)`,
`blue(c)`.  You can construct them directly from a `UInt32`, or as
`RGB(r, g, b)`.
"""
struct RGB24 <: AbstractRGB{N0f8}
    color::UInt32

    RGB24(col::UInt32, ::Type{Val{true}}) = new(col)
end
# The Val{true} constructor solves a consistency problem, one that's
# most obvious for Gray24: Gray24(x) interprets x as a value between 0
# and 1; since a UInt32 can have value 0 or 1 (among other
# possibilities), having Gray24(x::UInt32) mean something entirely
# different (interpreting the UInt32 as a bit pattern rather than a
# value) would be inconsistent, confusing, and error-prone. Because we
# can construct an RGB24 from a grayscale value (just repeating the
# value for all 3 color channels), the same problem extends to all the
# "24/32" color types.

# However, some constructors "build" RGB24s as a UInt32 bit pattern,
# so we need some way of turning a UInt32 directly into an RGB24.
# This is the role of the Val{true} constructor. This is an internal
# implementation detail, and user code should not use it directly:
# use reinterpret(RGB24, x::UInt32) instead. (The Val{true}
# constructor is used to implement reinterpret, see traits.jl.)
function RGB24(r::N0f8, g::N0f8, b::N0f8)
    r32 = UInt32(reinterpret(r)) << 16
    g32 = UInt32(reinterpret(g)) << 8
    b32 = UInt32(reinterpret(b))
    reinterpret(RGB24, r32 | g32 | b32)
end

"""
`ARGB32` uses a `UInt32` representation of color, 0xAARRGGBB, where
R=red, G=green, B=blue and A is the alpha channel. This format is
often used by external libraries such as Cairo.  On a little-endian
machine, this type has the exact same storage format as `BGRA{N0f8}`.

`ARGB32` colors do not have fields named `alpha`, `r`, `g`, `b`, but
you can still extract the individual components with `alpha(c)`,
`red(c)`, `green(c)`, `blue(c)`.  You can construct them directly from
a `UInt32`, or as `ARGB32(r, g, b, alpha)`.
"""
struct ARGB32 <: AbstractARGB{RGB24, N0f8}
    color::UInt32

    ARGB32(col::UInt32, ::Type{Val{true}}) = new(col)
end
function ARGB32(r::N0f8, g::N0f8, b::N0f8, alpha::N0f8 = N0f8(1))
    a32 = UInt32(reinterpret(alpha)) << 24
    r32 = UInt32(reinterpret(r)) << 16
    g32 = UInt32(reinterpret(g)) << 8
    b32 = UInt32(reinterpret(b))
    reinterpret(ARGB32, a32 | r32 | g32 | b32)
end
function ARGB32(c::RGB24, alpha::Real = N0f8(1))
    checkval(ARGB32, alpha)
    a32 = UInt32(reinterpret(_rem(alpha, N0f8))) << 24
    reinterpret(ARGB32, a32 | (c.color & 0xFFFFFF))
end

"""
`Gray` is a grayscale object. You can extract its value with `gray(c)`.
"""
struct Gray{T<:Union{Fractional,Bool}} <: AbstractGray{T}
    val::T
end

"""
`Gray24` uses a `UInt32` representation of color, 0xAAIIIIII, where
I=intensity (grayscale value) and A is irrelevant. Each II pair is
assumed to be the same.  This format is often used by external
libraries such as Cairo.

You can extract the single gray value with `gray(c)`.  You can
construct them directly from a `UInt32`, or as `Gray24(i)`. Note that
`i` is interpreted on a scale from 0 (black) to 1 (white).
"""
struct Gray24 <: AbstractGray{N0f8}
    color::UInt32

    Gray24(c::UInt32, ::Type{Val{true}}) = new(c)
end
Gray24(val::N0f8) = reinterpret(Gray24, reinterpret(val) * 0x010101)

"""
`AGray32` uses a `UInt32` representation of color, 0xAAIIIIII, where
I=intensity (grayscale value) and A=alpha. Each II pair is
assumed to be the same.  This format is often used by external
libraries such as Cairo.

You can extract the single gray value with `gray(c)` and the alpha as
`alpha(c)`.  You can construct them directly from a `UInt32`, or as
`AGray32(i,alpha)`. Note that `i` and `alpha` are interpreted on a
scale from 0 (black) to 1 (white).
"""
struct AGray32 <: AbstractAGray{Gray24, N0f8}
    color::UInt32

    AGray32(c::UInt32, ::Type{Val{true}}) = new(c)
end
function AGray32(val::N0f8, alpha::N0f8 = N0f8(1))
    a32 = UInt32(reinterpret(alpha)) << 24
    reinterpret(AGray32, a32 | reinterpret(val) * 0x010101)
end
function AGray32(g::Gray24, alpha::Real= N0f8(1))
    checkval(AGray32, alpha)
    a32 = UInt32(reinterpret(_rem(alpha, N0f8))) << 24
    reinterpret(AGray32, a32 | (g.color & 0xffffff))
end

# Generated code:
#   - TransparentColor definitions (e.g., ARGB and RGBA) with inner constructors
#   - `export`s
#   - `coloralpha(::Color)` and `alphacolor(::Color)` traits for corresponding types

# Note: with the exceptions of `alphacolor` and `coloralpha`, all
# traits in the rest of this file are intended just for internal use

# Provide the field names in the order expected by the constructor
colorfields(::Type{C}) where {C<:Color} = (fieldnames(C)...,)
colorfields(::Type{C}) where {C<:XRGB} = (:r, :g, :b)
colorfields(::Type{C}) where {C<:RGBX} = (:r, :g, :b)
colorfields(::Type{C}) where {C<:BGR } = (:r, :g, :b)
colorfields(::Type{P}) where {P<:TransparentColor} = tuple(colorfields(color_type(P))..., :alpha)
colorfields(c::Colorant) = colorfields(typeof(c))

eltype_default(::Type) = Float32
eltype_default(::Type{C}) where {C<:AbstractRGB } = N0f8
eltype_default(::Type{C}) where {C<:AbstractGray} = N0f8
eltype_default(::Type{C}) where {C<:TransparentColor} = eltype_default(color_type(C))

# TODO: Generalize the promotion rules so that they are reasonable even for custom types.
@inline function promote_args_type(::Type{C}, args...) where C <: Color
    T = promote_type(map(typeof, args)...)
    _promote_args_type(eltype_default(C), T)
end
@inline function promote_args_type(::Type{C}, args...) where {C <: TransparentColor}
    Ta = typeof(last(args)) # alpha
    T = _promote_wol(map(typeof, args)...)
    if T <: Union{Integer, FixedPoint} && Ta <: Integer
        _promote_args_type(eltype_default(C), T)
    else
        _promote_args_type(eltype_default(C), promote_type(T, Ta))
    end
end
# a variant of `promote_type` that ignores the last (i.e. alpha) element
@inline _promote_wol(t, tail...) = length(tail) == 1 ? t : promote_type(t, _promote_wol(tail...))

_promote_args_type(::Type{Tdef}, ::Type{T}) where {Tdef<:AbstractFloat, T<:AbstractFloat} = T
_promote_args_type(::Type{Tdef}, ::Type{T}) where {Tdef<:AbstractFloat, T<:Real} = Tdef
_promote_args_type(::Type{Tdef}, ::Type{T}) where {Tdef<:FixedPoint, T<:Fractional} = T
_promote_args_type(::Type{Tdef}, ::Type{T}) where {Tdef<:FixedPoint, T<:Real} = Tdef
_promote_args_type(::Type{Tdef}, ::Type{T}) where {Tdef, T} = promote_type(Tdef, T)

# Generate transparent versions
macro make_alpha(C, acol, cola, fields, constrfields, ub, elty)
    # ub = upper-bound on T in C{T}
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    constrfields = constrfields.args
    N = length(fields) + 1
    Tfields = Expr[:($f::T) for f in fields]
    Targs   = Expr[:($f::T) for f in constrfields]
    Tconstr = Expr(:<:, :T, ub)
    esc(quote
        struct $acol{$Tconstr} <: AlphaColor{$C{T}, T, $N}
            alpha::T
            $(Tfields...)

            $acol{T}($(Targs...), alpha::T=oneunit(T)) where {$Tconstr} = new{T}(alpha, $(fields...))
        end
        struct $cola{$Tconstr} <: ColorAlpha{$C{T}, T, $N}
            $(Tfields...)
            alpha::T

            $cola{T}($(Targs...), alpha::T=oneunit(T)) where {$Tconstr} = new{T}($(fields...), alpha)
        end
        export $acol, $cola
        alphacolor(::Type{C}) where {C<:$C} = $acol
        coloralpha(::Type{C}) where {C<:$C} = $cola
    end)
end

const color3types = map(s->getfield(ColorTypes,s),
                        filter(names(ColorTypes, all=false)) do s
                            isdefined(ColorTypes, s) || return false
                            t = getfield(ColorTypes, s)
                            isa(t, Type{<:Color3}) && !isabstracttype(t)
                        end |> unique
                        )

# The above should have filtered out every non-DataType that's not also a
# wrapped UnionAll-wrapped DataType.
const parametric3 = filter(x->!isa(x, DataType) || !isempty(x.parameters), color3types)

# For searchability, explicitly enumerate the type names. (issue #16)
for (C, acol, cola) in [(DIN99d, :ADIN99d, :DIN99dA),
                        (DIN99o, :ADIN99o, :DIN99oA),
                        (DIN99, :ADIN99, :DIN99A),
                        (HSI, :AHSI, :HSIA),
                        (HSL, :AHSL, :HSLA),
                        (HSV, :AHSV, :HSVA),
                        (LCHab, :ALCHab, :LCHabA),
                        (LCHuv, :ALCHuv, :LCHuvA),
                        (LMS, :ALMS, :LMSA),
                        (Lab, :ALab, :LabA),
                        (Luv, :ALuv, :LuvA),
                        (XYZ, :AXYZ, :XYZA),
                        (YCbCr, :AYCbCr, :YCbCrA),
                        (YIQ, :AYIQ, :YIQA),
                        (xyY, :AxyY, :xyYA),
                        (BGR, :ABGR, :BGRA),
                        (RGB, :ARGB, :RGBA),
                        (Gray, :AGray, :GrayA),
                        (Oklab, :AOklab, :OklabA),
                        (Oklch, :AOklch, :OklchA)]
    fn  = Expr(:tuple, fieldnames(C)...)
    cfn = Expr(:tuple, colorfields(C)...)
    elty = eltype_default(C)
    ub   = elty <: FixedPoint ? Fractional : AbstractFloat
    Csym = nameof(C)
    @eval @make_alpha $Csym $acol $cola $fn $cfn $ub $elty
end

const GrayLike = Union{Number, AbstractGray}

_real(x) = real(x)
@noinline function _real(@nospecialize(x::Colorant))
    throw(ArgumentError("""
        Color objects other than `AbstractGray` cannot be used as if they were `Real` arguments."""))
end
_real(x::AbstractGray) = real(x)

function (::Type{C})() where {N, C <: ColorantN{N}}
    d0 = zero(eltype_default(C))
    dx = C <: TransparentColor ? oneunit(eltype_default(C)) : d0
    C(ntuple(_ -> d0, Val(N - 1))..., dx)
end

Gray{T}(c::Colorant) where {T<:Union{Fractional,Bool}} = _new_colorant(Gray{T}, c)
(::Type{C})(x         ) where {C <: Color    } = _new_colorant(C, x)
(::Type{C})(x, y      ) where {C <: ColorN{2}} = _new_colorant(C, x, y)
(::Type{C})(x, y, z   ) where {C <: ColorN{3}} = _new_colorant(C, x, y, z)
(::Type{C})(x, y, z, w) where {C <: ColorN{4}} = _new_colorant(C, x, y, z, w)

(::Type{C})(x                  ) where {C <: TransparentColor    } = _new_colorant(C, x)
(::Type{C})(x,          alpha  ) where {C <: TransparentColor    } = _new_colorant(C, x, alpha)
(::Type{C})(x, y,       alpha=1) where {C <: TransparentColorN{3}} = _new_colorant(C, x, y, alpha)
(::Type{C})(x, y, z,    alpha=1) where {C <: TransparentColorN{4}} = _new_colorant(C, x, y, z, alpha)
(::Type{C})(x, y, z, w, alpha=1) where {C <: TransparentColorN{5}} = _new_colorant(C, x, y, z, w, alpha)

(::Type{C})(g::GrayLike) where {C <: TransparentColorN{2}} = _new_colorant(C, g, 1)
(::Type{C})(g::GrayLike) where {C <: AbstractRGB} = _new_colorant(C, g, g, g)
(::Type{C})(g::GrayLike) where {C <: TransparentRGB} = _new_colorant(C, g, g, g, oneunit(g))
(::Type{C})(g::GrayLike, alpha) where {C <: TransparentRGB} = _new_colorant(C, g, g, g, alpha)


function _new_colorant(::Type{C}, args::Vararg{Any,N}) where {N, C <: ColorantN{N}}
    rargs = _real.(args)
    base_colorant_type(C){promote_args_type(C, rargs...)}(rargs...)
end

function _new_colorant(::Type{C}, c::Colorant) where {N, C <: ColorantN{N}}
    convert(C, c)
end

function _new_colorant(::Type{C}, c::Colorant, alpha) where {N, C <: TransparentColorN{N}}
    # TODO: Make the following a single `convert` call
    cc = convert(base_color_type(C), color(c))
    convert(C, cc, alpha)
end

function (::Type{C})(x::UInt32) where C <: Union{RGB24, Gray24, ARGB32, AGray32}
    x <= UInt32(1) || throw_bit_pattern_error(C, x)
    reinterpret(C, C <: Color ? (-x) & 0xffffff : (-x) | 0xff000000)
end
function (::Type{C})(x::GrayLike) where C <: Union{RGB24, Gray24, ARGB32, AGray32}
    checkval(C, real(x))
    v = _rem(real(x), N0f8)
    return C <: Union{RGB24, ARGB32} ? C(v, v, v) : C(v)
end

# T might be a Normed, and so some inputs will result in an error.
# Try to make it a nice error.
function _new_colorant(::Type{C}, args::Vararg{GrayLike,N}) where {N, T, C <: Color{T,N}}
    isconcretetype(C) || throw(MethodError(C, args))
    r = real.(args)
    checkval(C, r...)
    C(_rem.(r, T)...)
end
function _new_colorant(::Type{TC}, args::Vararg{GrayLike,N}) where {N, T, C, TC <: TransparentColor{C,T,N}}
    r = real.(args)
    checkval(TC, r...)
    TC(_rem.(r, T)...)
end
function _new_colorant(::Type{TC}, args::Vararg{GrayLike,2}) where {T, C, TC <: TransparentColor{C,T,2}}
    r = real.(args)
    checkval(TC, r...)
    TC(_rem.(r, T)...)
end

"""
    alphacolor(::Type{<:Colorant})
    alphacolor(::Colorant)

Return the corresponding transparent color type/instance with storage order
(alpha, color).

# Examples
```jldocest; setup = :(using ColorTypes)
julia> alphacolor(RGB)
ARGB

julia> alphacolor(RGBA{Float32})
ARGB

julia> alphacolor(Gray(0.8)) === AGray(0.8, 1.0)
true
```
"""
alphacolor(::Type{C}) where {C<:AlphaColor} = base_colorant_type(C)
alphacolor(::Type{C}) where {C<:ColorAlpha} = alphacolor(base_color_type(C))

"""
    coloralpha(::Type{<:Colorant})
    coloralpha(::Colorant)

Return the corresponding transparent color type/instance with storage order
(color, alpha).

# Examples
```jldocest; setup = :(using ColorTypes)
julia> coloralpha(RGB)
RGBA

julia> coloralpha(ARGB{Float32})
RGBA

julia> coloralpha(Gray(0.8)) === GrayA(0.8, 1.0)
true
```
"""
coloralpha(::Type{C}) where {C<:ColorAlpha} = base_colorant_type(C)
coloralpha(::Type{C}) where {C<:AlphaColor} = coloralpha(base_color_type(C))

alphacolor(::Type{C}) where {C<:Gray24} = AGray32
alphacolor(::Type{C}) where {C<:RGB24} = ARGB32
alphacolor(::Type{C}) where {C<:XRGB} = ARGB
alphacolor(::Type{C}) where {C<:RGBX} = ARGB
coloralpha(::Type{C}) where {C<:XRGB} = RGBA
coloralpha(::Type{C}) where {C<:RGBX} = RGBA

### Validating the inputs for Normed constructors

# Throw helpful errors in case of trouble. The inlining here is
# carefully designed to reduce the impact on runtime performance, and
# we also avoid splatting.

@inline function isok(::Type{T}, x) where T<:Normed
    Δ = eps(T)/2 # as long as the number rounds to a valid number, that's OK
    (-Δ <= x) & (x < typemax(T)+Δ)
end
@inline function isok(::Type{T}, x, y) where T<:Normed
    Δ = eps(T)/2
    @fastmath n, m = minmax(x, y)
    (-Δ <= n) & (m < typemax(T)+Δ)
end

@inline function checkval(::Type{C}, a) where {T<:Normed, C<:Colorant{T}}
    isok(T, a) || throw_colorerror(C, (a,))
end
@inline function checkval(::Type{C}, a, b) where {T<:Normed, C<:Colorant{T}}
    isok(T, a, b) || throw_colorerror(C, (a, b))
end
@inline function checkval(::Type{C}, a, b, c) where {T<:Normed, C<:Colorant{T}}
    isok(T, a, b) & isok(T, b, c) || throw_colorerror(C, (a, b, c))
end
@inline function checkval(::Type{C}, a, b, c, d) where {T<:Normed, C<:Colorant{T}}
    Δ = eps(T)/2
    @fastmath min_ab, max_ab = minmax(a, b)
    @fastmath min_cd, max_cd = minmax(c, d)
    @fastmath n = min(min_ab, min_cd)
    @fastmath m = max(max_ab, max_cd)
    (-Δ <= n) & (m < typemax(T)+Δ) || throw_colorerror(C, (a, b, c, d))
end
@inline function checkval(::Type{C}, a, b, c, d, e) where {T<:Normed, C<:Colorant{T}}
    isok(T, a, b) & isok(T, c, d) & isok(T, e) || throw_colorerror(C, (a, b, c, d, e))
end

checkval(::Type{C}, args::Vararg{T}) where {T<:Normed, C<:Colorant{T}} = nothing
checkval(::Type{C}, args...) where {C<:Colorant} = nothing


function throw_colorerror_(::Type{T}, values) where T<:Normed
    Tmin = repr(typemin(T), context=:compact=>true)
    Tmax = repr(typemax(T), context=:compact=>true)
    bitstring = sizeof(T) == 1 ? "an 8-bit" : "a $(8*sizeof(T))-bit"
    throw(ArgumentError("""
component type $T is $bitstring type representing $(2^(8*sizeof(T))) values from $Tmin to $Tmax,
  but the values $values do not lie within this range.
  See the READMEs for FixedPointNumbers and ColorTypes for more information."""))
end

function throw_colorerror(::Type{C}, values::Tuple{Vararg{Integer}}) where C<:Colorant{N0f8}
    # Let's try to read the user's mind
    all(x->0<=x<=255, values) || throw_colorerror_(N0f8, values)
    if length(values) == 1
        vstr = "$(values[1]) is an integer"
    else
        vstr = "$values are integers"
    end
    Cstr = colorant_string_with_eltype(C)
    args = join(map(v -> "$v/255", values), ", ")
    throw(ArgumentError("""
The components of $(nameof(C)) are normalized to the range 0-1,
  but $vstr in the range 0-255.
  Consider dividing your input values by 255, for example: $Cstr($args)
  The component type N0f8 is an 8-bit type representing 256 values from 0 to 1.
  You can also use `reinterpret(N0f8, x % UInt8)` to encode the input into N0f8.
  See the READMEs for FixedPointNumbers and ColorTypes for more information."""))
end
function throw_colorerror(::Type{C}, values::Tuple) where {T<:Normed, C<:Colorant{T}}
    throw_colorerror_(T, values)
end

function throw_bit_pattern_error(@nospecialize(C), value)
    hex = string(value, base=16, pad=8)
    throw(ArgumentError("""
$C cannot be constructed or converted directly from a UInt32 input as a bit pattern.
  Use `reinterpret($C, 0x$hex)` instead."""))
end

_rem(x, ::Type{T}) where {T<:Normed} = x % T
_rem(x, ::Type{T}) where {T}         = convert(T, x)

struct ColorTypeResolutionError <: Exception
    func::Symbol
    msg::String
    C1
    C2
end

function Base.showerror(io::IO, ex::ColorTypeResolutionError)
    print(io, "in ", ex.func, ", ", ex.msg, ' ', ex.C1, " and ", ex.C2)
end
