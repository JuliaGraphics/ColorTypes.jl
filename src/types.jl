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
`AbstractRGB{T}` is an abstract supertype for red/green/blue color types that
can be constructed as `C(r, g, b)` and for which the elements can be
extracted as `red(c)`, `green(c)`, `blue(c)`. You should *not* make
assumptions about internal storage order, the number of fields, or the
representation. One `AbstractRGB` color-type, `RGB24`, is not
parametric and does not have fields named `r`, `g`, `b`.
"""
abstract type AbstractRGB{T}      <: Color{T,3} end


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
abstract type AlphaColor{C,T,N} <: TransparentColor{C,T,N} end

"""
`ColorAlpha` is an abstract supertype for types like `RGBA`, where the
alpha channel comes last in the internal storage order.
"""
abstract type ColorAlpha{C,T,N} <: TransparentColor{C,T,N} end

# These are types we'll dispatch on.
AbstractGray{T}                    = Color{T,1}
Color3{T}                          = Color{T,3}
TransparentGray{C<:AbstractGray,T} = TransparentColor{C,T,2}
Transparent3{C<:Color3,T}          = TransparentColor{C,T,4}
TransparentRGB{C<:AbstractRGB,T}   = TransparentColor{C,T,4}
ColorantNormed{T<:Normed,N}        = Colorant{T,N}

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

    RGB{T}(r::T, g::T, b::T) where {T} = new{T}(r, g, b)
    # T might be a Normed, and so some inputs will result in an
    # error. Try to make it a nice error.
    function RGB{T}(r::Real, g::Real, b::Real) where T
        checkval(T, r, g, b)
        new{T}(_rem(r,T), _rem(g,T), _rem(b,T))
    end
end
# For types that support Fractional, we need this to avoid a
# StackOverflow. For color types that only support AbstractFloat, this
# is handled by @make_constructors.
RGB(r::T, g::T, b::T) where {T<:Fractional} = RGB{T}(r, g, b)

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

    BGR{T}(r::T, g::T, b::T) where {T} = new{T}(b, g, r)
    function BGR{T}(r::Real, g::Real, b::Real) where T
        checkval(T, r, g, b)
        new{T}(_rem(b,T), _rem(g,T), _rem(r,T))
    end
end
BGR(r::T, g::T, b::T) where {T<:Fractional} = BGR{T}(r, g, b)

"""
`RGB1` is a variant of `RGB` which has a padding element inserted at
the beginning. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGB1(r, g, b)`.
"""
struct RGB1{T<:Fractional} <: AbstractRGB{T}
    alphadummy::T
    r::T
    g::T
    b::T

    RGB1{T}(r::T, g::T, b::T) where {T} = new{T}(oneunit(T), r, g, b)
    function RGB1{T}(r::Real, g::Real, b::Real) where T
        checkval(T, r, g, b)
        new{T}(oneunit(T), _rem(r,T), _rem(g,T), _rem(b,T))
    end
end
RGB1(r::T, g::T, b::T) where {T<:Fractional} = RGB1{T}(r, g, b)

"""
`RGB4` is a variant of `RGB` which has a padding element inserted at
the end. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGB4(r, g, b)`.
"""
struct RGB4{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGB4{T}(r::T, g::T, b::T) where {T} = new{T}(r, g, b, oneunit(T))
    function RGB4{T}(r::Real, g::Real, b::Real) where T
        checkval(T, r, g, b)
        new{T}(_rem(r,T), _rem(g,T), _rem(b,T), oneunit(T))
    end
end
RGB4(r::T, g::T, b::T) where {T<:Fractional} = RGB4{T}(r, g, b)

"`HSV` is the Hue-Saturation-Value colorspace."
struct HSV{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360)
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end

"`HSB` (Hue-Saturation-Brightness) is an alias for `HSV`."
const HSB = HSV

"`HSL` is the Hue-Saturation-Lightness colorspace."
struct HSL{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360)
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end

"`HSI` is the Hue-Saturation-Intensity colorspace."
struct HSI{T<:AbstractFloat} <: Color{T,3}
    h::T
    s::T
    i::T
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
    l::T # Luminance in approximately [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end

"`LCHab` is the Luminance-Chroma-Hue, Polar-Lab colorspace"
struct LCHab{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360)
end

"`Luv` is the CIELUV colorspace"
struct Luv{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance
    u::T # Red/Green
    v::T # Blue/Yellow
end

"`LCHuv` is the Luminance-Chroma-Hue, Polar-Luv colorspace"
struct LCHuv{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance
    c::T # Chroma
    h::T # Hue
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
RGB24() = reinterpret(RGB24, UInt32(0))
_RGB24(r::UInt8, g::UInt8, b::UInt8) = reinterpret(RGB24, UInt32(r)<<16 | UInt32(g)<<8 | UInt32(b))
RGB24(r::N0f8, g::N0f8, b::N0f8) = _RGB24(reinterpret(r), reinterpret(g), reinterpret(b))
function RGB24(r::Real, g::Real, b::Real)
    checkval(N0f8, r, g, b)
    RGB24(_rem(r,N0f8), _rem(g,N0f8), _rem(b,N0f8))
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
struct ARGB32 <: AlphaColor{RGB24, N0f8, 4}
    color::UInt32

    ARGB32(col::UInt32, ::Type{Val{true}}) = new(col)
end
ARGB32() = reinterpret(ARGB32, UInt32(0xff)<<24)
_ARGB32(r::UInt8, g::UInt8, b::UInt8, alpha::UInt8) = reinterpret(ARGB32, UInt32(alpha)<<24 | UInt32(r)<<16 | UInt32(g)<<8 | UInt32(b))
ARGB32(r::N0f8, g::N0f8, b::N0f8, alpha::N0f8 = N0f8(1)) = _ARGB32(reinterpret(r), reinterpret(g), reinterpret(b), reinterpret(alpha))
ARGB32(r, g, b, alpha = 1) = ARGB32(N0f8(r), N0f8(g), N0f8(b), N0f8(alpha))
ARGB32(c::AbstractRGB{T}, alpha = alpha(c)) where {T} = ARGB32(red(c), green(c), blue(c), alpha)

"""
`Gray` is a grayscale object. You can extract its value with `gray(c)`.
"""
struct Gray{T<:Union{Fractional,Bool}} <: AbstractGray{T}
    val::T

    Gray{T}(val::T) where {T} = new{T}(val)
    function Gray{T}(val::Real) where T
        checkval(T, val)
        new{T}(_rem(val,T))
    end
end
Gray(val::T) where {T<:Union{Fractional,Bool}} = Gray{T}(val)

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
Gray24() = reinterpret(Gray24, UInt32(0))
_Gray24(val::UInt8) = (g = UInt32(val); reinterpret(Gray24, g<<16 | g<<8 | g))
Gray24(val::N0f8) = _Gray24(reinterpret(val))
function Gray24(val::Real)
    checkval(N0f8, val)
    Gray24(val%N0f8)
end

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
struct AGray32 <: AlphaColor{Gray24, N0f8, 2}
    color::UInt32

    AGray32(c::UInt32, ::Type{Val{true}}) = new(c)
end
AGray32() = reinterpret(AGray32, 0xff000000)
_AGray32(val::UInt8, alpha::UInt8 = 0xff) = (g = UInt32(val); reinterpret(AGray32, UInt32(alpha)<<24 | g<<16 | g<<8 | g))
AGray32(val::N0f8, alpha::N0f8 = N0f8(1)) = _AGray32(reinterpret(val), reinterpret(alpha))
function AGray32(val::Real, alpha = 1)
    checkval(N0f8, val, alpha)
    AGray32(val%N0f8, alpha%N0f8)
end
function AGray32(g::Gray24, alpha = 1)
    checkval(N0f8, alpha)
    reinterpret(AGray32, UInt32(reinterpret(_rem(alpha,N0f8)))<<24 | g.color)
end
AGray32(g::AbstractGray, alpha = 1) = AGray32(gray(g), alpha)

# Generated code:
#   - more constructors for colors
#   - TransparentColor definitions (e.g., ARGB), exports, and constructors
#   - coloralpha(::Color) and alphacolor(::Color) traits for corresponding types

# Note: with the exceptions of `alphacolor` and `coloralpha`, all
# traits in the rest of this file are intended just for internal use

const color3types = map(s->getfield(ColorTypes,s),
  filter(names(ColorTypes, all=false)) do s
    isdefined(ColorTypes, s) || return false
    t = getfield(ColorTypes, s)
    isa(t, Type) && t <: Colorant && !isabstracttype(t) && length(fieldnames(t))>1
  end)
# The above should have filtered out every non-DataType that's not also a
# wrapped UnionAll-wrapped DataType. By avoiding the explicit UnionAll check
# here, we remain compatible with pre-0.6 julia.
const parametric3 = filter(x->!isa(x, DataType) || !isempty(x.parameters), color3types)

# Provide the field names in the order expected by the constructor
colorfields(::Type{C}) where {C<:Color} = (fieldnames(C)...,)
colorfields(::Type{C}) where {C<:RGB1} = (:r, :g, :b)
colorfields(::Type{C}) where {C<:RGB4} = (:r, :g, :b)
colorfields(::Type{C}) where {C<:BGR } = (:r, :g, :b)
colorfields(::Type{P}) where {P<:TransparentColor} = tuple(colorfields(color_type(P))..., :alpha)
colorfields(c::Colorant) = colorfields(typeof(c))

# Generate convenience constructors for a type
macro make_constructors(C, fields, elty)
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    Tfields = Expr[:($f::T) for f in fields]
    realfields = Expr[:($f::Real) for f in fields]
    zfields = zeros(Int, length(fields))
    esc(quote
        # More constructors for the non-alpha version
        $C($(Tfields...)) where {T<:Integer} = $C{$elty}($(fields...))
        $C($(realfields...)) = $C{promote_eltype($C, $(fields...))}($(fields...))
        $C() = $C{$elty}($(zfields...))
        # Conversion constructors
        $C(x) = convert($C, x)
        $C{T}(x) where T = convert($C{T}, x)
    end)
end

# Generate transparent versions
macro make_alpha(C, acol, cola, fields, constrfields, ub, elty)
    # ub = upper-bound on T in C{T}
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    constrfields = constrfields.args
    N = length(fields)+1
    Tfields       = Expr[:($f::T)    for f in fields]
    Tconstrfields = Expr[:($f::T)    for f in constrfields]
    realfields    = Expr[:($f::Real) for f in constrfields]
    cfields       = Expr[:(c.$f)     for f in constrfields]
    cinnerfields  = Expr[:(c.$f)     for f in fields]
    remfields     = Expr[:(_rem($f,T)) for f in fields]
    zfields       = zeros(Int, length(fields))
    Tconstr = Expr(:<:, :T, ub)
    exportexpr = Expr(:export, acol, cola)
    convqualifier = C == :Gray ? :(x::Colorant) : :x
    esc(quote
        struct $acol{$Tconstr} <: AlphaColor{$C{T}, T, $N}
            alpha::T
            $(Tfields...)

            $acol{T}($(Tconstrfields...), alpha::T=oneunit(T)) where {T} = new{T}(alpha, $(fields...))
            function $acol{T}($(realfields...), alpha::Real=oneunit(T)) where T
                checkval(T, $(fields...), alpha)
                new{T}(_rem(alpha,T), $(remfields...))
            end
            $acol{T}(c::$C, alpha::Real=oneunit(T)) where {T} = $acol{T}($(cfields...), alpha)
        end
        struct $cola{$Tconstr} <: ColorAlpha{$C{T}, T, $N}
            $(Tfields...)
            alpha::T

            $cola{T}($(Tconstrfields...), alpha::T=oneunit(T)) where {T} = new{T}($(fields...), alpha)
            function $cola{T}($(realfields...), alpha::Real=oneunit(T)) where T
                checkval(T, $(fields...), alpha)
                new{T}($(remfields...), _rem(alpha,T))
            end
            $cola{T}(c::$C, alpha::Real=oneunit(T)) where {T} = $cola{T}($(cfields...), alpha)
        end
        $exportexpr
        alphacolor(::Type{C}) where {C<:$C} = $acol
        coloralpha(::Type{C}) where {C<:$C} = $cola

        # More constructors for the alpha versions
        $acol($(Tconstrfields...), alpha::T=1) where {T<:Integer} = $acol{$elty}($(fields...), alpha)
        $acol(c::$C, alpha::Real=oneunit(eltype(c))) = $acol{eltype(c)}(c, alpha)
        function $acol($(constrfields...))
            p = promote($(constrfields...))
            T = typeof(p[1])
            $acol{T}(p...)
        end
        function $acol($(constrfields...), alpha::Real)
            p = promote($(constrfields...), alpha)
            T = typeof(p[1])
            $acol{T}(p...)
        end
        $acol(c::Color, alpha::Real) = $acol($C(c), alpha)
        $acol() = $acol{$elty}($(zfields...))
        $acol($convqualifier) = convert($acol, x)
        $acol{T}(x) where T = convert($acol{T}, x)

        $cola($(Tconstrfields...), alpha::T=1) where {T<:Integer} = $cola{$elty}($(fields...), alpha)
        $cola(c::$C, alpha::Real=oneunit(eltype(c))) = $cola{eltype(c)}(c, alpha)
        function $cola($(constrfields...))
            p = promote($(constrfields...))
            T = typeof(p[1])
            $cola{T}(p...)
        end
        function $cola($(constrfields...), alpha::Real)
            p = promote($(constrfields...), alpha)
            T = typeof(p[1])
            $cola{T}(p...)
        end
        $cola(c::Color, alpha::Real) = $cola($C(c), alpha)
        $cola() = $cola{$elty}($(zfields...))
        $cola($convqualifier) = convert($cola, x)
        $cola{T}(x) where T = convert($cola{T}, x)
end)
end

eltype_default(::Type{C}) where {C<:AbstractRGB  } = N0f8
eltype_default(::Type{C}) where {C<:AbstractGray } = N0f8
eltype_default(::Type{C}) where {C<:Color  } = Float32
eltype_default(::Type{P}) where {P<:Colorant        } = eltype_default(color_type(P))

# Upper bound on element type for each color type
eltype_ub(::Type{P}) where {P<:Colorant        } = eltype_ub(eltype_default(P))
eltype_ub(::Type{T}) where {T<:FixedPoint   } = Fractional
eltype_ub(::Type{T}) where {T<:AbstractFloat} = AbstractFloat

@inline promote_eltype(::Type{C}, vals...) where {C<:Colorant} = _promote_eltype(eltype_ub(C), eltype_default(C), promote_type(map(typeof, vals)...))
_promote_eltype(::Type{AbstractFloat}, ::Type{Tdef}, ::Type{T}) where {Tdef,T<:AbstractFloat} = T
_promote_eltype(::Type{AbstractFloat}, ::Type{Tdef}, ::Type{T}) where {Tdef,T<:Real} = Tdef
_promote_eltype(::Type{Fractional}, ::Type{Tdef}, ::Type{T}) where {Tdef,T<:Fractional} = T
_promote_eltype(::Type{Fractional}, ::Type{Tdef}, ::Type{T}) where {Tdef,T<:Real} = Tdef

ctypes = union(setdiff(parametric3, [RGB1,RGB4]), [Gray])

# the arg list for C below should be identical to ctypes above.
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
                        (Gray, :AGray, :GrayA)]
    fn  = Expr(:tuple, fieldnames(C)...)
    cfn = Expr(:tuple, colorfields(C)...)
    elty = eltype_default(C)
    ub   = eltype_ub(C)
    Csym = nameof(Base.unwrap_unionall(C))
    @eval @make_constructors $Csym $fn $elty
    @eval @make_alpha $Csym $acol $cola $fn $cfn $ub $elty
end

# RGB1 and RGB4 require special handling because of the alphadummy field
@eval @make_constructors RGB1 (r,g,b) $N0f8
@eval @make_constructors RGB4 (r,g,b) $N0f8

const GrayLike = Union{Real,AbstractGray}

for C in (RGB, BGR, RGB1, RGB4, RGB24)
    @eval (::Type{$C})(r::GrayLike, g::GrayLike, b::GrayLike) = $C(gray(r), gray(g), gray(b))
end
for C in (RGB, BGR, RGB1, RGB4)
    @eval (::Type{$C{T}})(r::GrayLike, g::GrayLike, b::GrayLike) where T = $C{T}(gray(r), gray(g), gray(b))
end

alphacolor(::Type{C}) where {C<:Gray24} = AGray32
alphacolor(::Type{C}) where {C<:RGB24} = ARGB32
alphacolor(::Type{C}) where {C<:RGB1} = ARGB
alphacolor(::Type{C}) where {C<:RGB4} = ARGB
coloralpha(::Type{C}) where {C<:RGB1} = RGBA
coloralpha(::Type{C}) where {C<:RGB4} = RGBA

"""
`alphacolor(RGB)` returns `ARGB`, i.e., the corresponding transparent
color type with storage order (alpha, color).
""" alphacolor

"""
`coloralpha(RGB)` returns `RGBA`, i.e., the corresponding transparent
color type with storage order (color, alpha).
""" coloralpha

### Validating the inputs for Normed constructors

# Throw helpful errors in case of trouble. The inlining here is
# carefully designed to reduce the impact on runtime performance, and
# we also avoid splatting.

@inline function isok(::Type{T}, x) where T<:Normed
    Δ = eps(T)/2 # as long as the number rounds to a valid number, that's OK
    (-Δ <= x) & (x < typemax(T)+Δ)
end

@inline checkval(::Type{T}, a) where {T<:Normed} = isok(T, a) || throw_colorerror(T, a)

@inline function checkval(::Type{T}, a, b) where T<:Normed
    isok(T, a) & isok(T, b) || throw_colorerror(T, a, b)
end
@inline function checkval(::Type{T}, a, b, c) where T<:Normed
    isok(T, a) & isok(T, b) & isok(T, c) || throw_colorerror(T, a, b, c)
end
@inline function checkval(::Type{T}, a, b, c, d) where T<:Normed
    isok(T, a) & isok(T, b) & isok(T, c) & isok(T, d) || throw_colorerror(T, a, b, c, d)
end

checkval(::Type{T}, a::T) where {T<:Normed} = nothing
checkval(::Type{T}, a::T, b::T) where {T<:Normed} = nothing
checkval(::Type{T}, a::T, b::T, c::T) where {T<:Normed} = nothing
checkval(::Type{T}, a::T, b::T, c::T, d::T) where {T<:Normed} = nothing

checkval(::Type{T}, a) where {T} = nothing
checkval(::Type{T}, a, b) where {T} = nothing
checkval(::Type{T}, a, b, c) where {T} = nothing
checkval(::Type{T}, a, b, c, d) where {T} = nothing

@noinline throw_colorerror(::Type{T}, g) where {T} = throw_colorerror(T, (g,))
@noinline throw_colorerror(::Type{T}, g, a) where {T} = throw_colorerror(T, (g,a))
@noinline throw_colorerror(::Type{T}, r, g, b) where {T} = throw_colorerror(T, (r, g, b))
@noinline throw_colorerror(::Type{T}, r, g, b, a) where {T} = throw_colorerror(T, (r, g, b, a))

function throw_colorerror_(::Type{T}, values) where T<:Normed
    io = IOBuffer()
    show(IOContext(io, :compact=>true), typemin(T)); Tmin = String(take!(io))
    show(IOContext(io, :compact=>true), typemax(T)); Tmax = String(take!(io))
    bitstring = sizeof(T) == 1 ? "an 8-bit" : "a $(8*sizeof(T))-bit"
    throw(ArgumentError("""
element type $T is $bitstring type representing $(2^(8*sizeof(T))) values from $Tmin to $Tmax,
  but the values $values do not lie within this range.
  See the READMEs for FixedPointNumbers and ColorTypes for more information."""))
end

function throw_colorerror(::Type{N0f8}, values::Tuple{Vararg{Integer}})
    # Let's try to read the user's mind
    if all(x->0<=x<=255, values)
        if length(values) == 1
            vstr = "$(values[1]) is an integer"
            Tstr = "Gray"
        else
            vstr = "$values are integers"
            if length(values) == 2
                Tstr = "AGray"
            elseif length(values) == 3
                Tstr = "RGB"
            else
                Tstr = "RGBA"
            end
        end
        args = join(map(v->"$v/255", values), ',')
        throw(ArgumentError("""
$vstr in the range 0-255, but integer inputs are encoded with the N0f8
  type, an 8-bit type representing 256 discrete values between 0 and 1.
  Consider dividing your input values by 255, for example: $Tstr{N0f8}($args)
  See the READMEs for FixedPointNumbers and ColorTypes for more information."""))
    end
    throw_colorerror_(N0f8, values)
end

function throw_colorerror(::Type{T}, values::Tuple) where T<:Normed
    throw_colorerror_(T, values)
end

_rem(x,::Type{T}) where {T<:Normed} = x % T
_rem(x, ::Type{T}) where {T}        = x
