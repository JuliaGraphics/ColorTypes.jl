"""
`Colorant{T,N}` is the abstract super-type of all types in ColorTypes,
and refers to both (opaque) colors and colors-with-transparency (alpha
channel) information.  `T` is the element type (extractable with
`eltype`) and `N` is the number of *meaningful* entries (extractable
with `length`), i.e., the number of arguments you would supply to the
constructor.
"""
abstract Colorant{T,N}

# Colors (without transparency)
"""
`Color{T,N}` is the abstract supertype for a color (or
grayscale) with no transparency.
"""
abstract Color{T, N} <: Colorant{T,N}

"""
`AbstractRGB{T}` is an abstract supertype for red/green/blue color types that
can be constructed as `C(r, g, b)` and for which the elements can be
extracted as `red(c)`, `green(c)`, `blue(c)`. You should *not* make
assumptions about internal storage order, the number of fields, or the
representation. One `AbstractRGB` color-type, `RGB24`, is not
parametric and does not have fields named `r`, `g`, `b`.
"""
abstract AbstractRGB{T}      <: Color{T,3}


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
abstract TransparentColor{C<:Color,T,N} <: Colorant{T,N}

"""
`AlphaColor` is an abstract supertype for types like `ARGB`, where the
alpha channel comes first in the internal storage order. **Note** that
the constructor order is still `(color, alpha)`.
"""
abstract AlphaColor{C,T,N} <: TransparentColor{C,T,N}

"""
`ColorAlpha` is an abstract supertype for types like `RGBA`, where the
alpha channel comes last in the internal storage order.
"""
abstract ColorAlpha{C,T,N} <: TransparentColor{C,T,N}

# These are types we'll dispatch on. Not exported.
typealias AbstractGray{T}                    Color{T,1}
typealias Color3{T}                          Color{T,3}
typealias TransparentGray{C<:AbstractGray,T} TransparentColor{C,T,2}
typealias Transparent3{C<:Color3,T}          TransparentColor{C,T,4}
typealias TransparentRGB{C<:AbstractRGB,T}   TransparentColor{C,T,4}
typealias ColorantUFixed{T<:UFixed,N}        Colorant{T,N}

"""
`RGB` is the standard Red-Green-Blue (sRGB) colorspace.  Values of the
individual color channels range from 0 (black) to 1 (saturated). If
you want "Integer" storage types (e.g., 255 for full color), use `N0f8(1)`
instead (see FixedPointNumbers).
"""
immutable RGB{T<:Fractional} <: AbstractRGB{T}
    r::T # Red [0,1]
    g::T # Green [0,1]
    b::T # Blue [0,1]

    RGB(r::T, g::T, b::T) = new(r, g, b)
    # T might be a UFixed, and so some inputs will result in an
    # error. Try to make it a nice error.
    function RGB(r::Real, g::Real, b::Real)
        checkval(T, r, g, b)
        new(_rem(r,T), _rem(g,T), _rem(b,T))
    end
end
# For types that support Fractional, we need this to avoid a
# StackOverflow. For color types that only support AbstractFloat, this
# is handled by @make_constructors.
RGB{T<:Fractional}(r::T, g::T, b::T) = RGB{T}(r, g, b)

"""
`BGR` is a variant of `RGB` with the opposite storage order.  Note
that the constructor is still called in the order `BGR(r, g, b)`.
This storage order is noteworthy because on little-endian machines,
`BGRA` (with transparency) can be `reinterpret`ed to the `UInt32`
color format used by libraries such as Cairo and OpenGL.
"""
immutable BGR{T<:Fractional} <: AbstractRGB{T}
    b::T
    g::T
    r::T

    BGR(r::T, g::T, b::T) = new(b, g, r)
    function BGR(r::Real, g::Real, b::Real)
        checkval(T, r, g, b)
        new(_rem(b,T), _rem(g,T), _rem(r,T))
    end
end
BGR{T<:Fractional}(r::T, g::T, b::T) = BGR{T}(r, g, b)

"""
`RGB1` is a variant of `RGB` which has a padding element inserted at
the beginning. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGB1(r, g, b)`.
"""
immutable RGB1{T<:Fractional} <: AbstractRGB{T}
    alphadummy::T
    r::T
    g::T
    b::T

    RGB1(r::T, g::T, b::T) = new(one(T), r, g, b)
    function RGB1(r::Real, g::Real, b::Real)
        checkval(T, r, g, b)
        new(one(T), _rem(r,T), _rem(g,T), _rem(b,T))
    end
end
RGB1{T<:Fractional}(r::T, g::T, b::T) = RGB1{T}(r, g, b)

"""
`RGB4` is a variant of `RGB` which has a padding element inserted at
the end. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGB4(r, g, b)`.
"""
immutable RGB4{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGB4(r::T, g::T, b::T) = new(r, g, b, one(T))
    function RGB4(r::Real, g::Real, b::Real)
        checkval(T, r, g, b)
        new(_rem(r,T), _rem(g,T), _rem(b,T), one(T))
    end
end
RGB4{T<:Fractional}(r::T, g::T, b::T) = RGB4{T}(r, g, b)

"`HSV` is the Hue-Saturation-Value colorspace."
immutable HSV{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360)
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end

"`HSB` (Hue-Saturation-Brightness) is an alias for `HSV`."
typealias HSB HSV

"`HSL` is the Hue-Saturation-Lightness colorspace."
immutable HSL{T<:AbstractFloat} <: Color{T,3}
    h::T # Hue in [0,360)
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end

"`HSI` is the Hue-Saturation-Intensity colorspace."
immutable HSI{T<:AbstractFloat} <: Color{T,3}
    h::T
    s::T
    i::T
end

"""
`XYZ` is the CIE 1931 XYZ colorspace. It is a linear colorspace,
meaning that mathematical operations such as addition, subtraction,
and scaling make "colorimetric sense" in this colorspace.
"""
immutable XYZ{T<:AbstractFloat} <: Color{T,3}
    x::T
    y::T
    z::T
end

"`xyY` is the CIE 1931 xyY (chromaticity + luminance) space"
immutable xyY{T<:AbstractFloat} <: Color{T,3}
    x::T
    y::T
    Y::T
end

"`Lab` is the CIELAB colorspace."
immutable Lab{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance in approximately [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end

"`LCHab` is the Luminance-Chroma-Hue, Polar-Lab colorspace"
immutable LCHab{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360)
end

"`Luv` is the CIELUV colorspace"
immutable Luv{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance
    u::T # Red/Green
    v::T # Blue/Yellow
end

"`LCHuv` is the Luminance-Chroma-Hue, Polar-Luv colorspace"
immutable LCHuv{T<:AbstractFloat} <: Color{T,3}
    l::T # Luminance
    c::T # Chroma
    h::T # Hue
end

"`DIN99` is the (L99, a99, b99) adaptation of CIELAB"
immutable DIN99{T<:AbstractFloat} <: Color{T,3}
    l::T # L99
    a::T # a99
    b::T # b99
end

"`DIN99d` is the (L99d, a99d, b99d) improvement on DIN99"
immutable DIN99d{T<:AbstractFloat} <: Color{T,3}
    l::T # L99d
    a::T # a99d
    b::T # b99d
end

"`DIN99o` is the (L99o, a99o, b99o) adaptation of CIELAB"
immutable DIN99o{T<:AbstractFloat} <: Color{T,3}
    l::T # L99o
    a::T # a99o
    b::T # b99o
end

"""
`LMS` is the Long-Medium-Short colorspace based on activation of the
three cone photoreceptors.  Like `XYZ`, this is a linear color space.
"""
immutable LMS{T<:AbstractFloat} <: Color{T,3}
    l::T # Long
    m::T # Medium
    s::T # Short
end

"`YIQ` is a color encoding, for example used in NTSC transmission."
immutable YIQ{T<:AbstractFloat} <: Color{T,3}
    y::T
    i::T
    q::T
end

"`YCbCr` is the Y'CbCr color encoding often used in digital photography or video"
immutable YCbCr{T<:AbstractFloat} <: Color{T,3}
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
immutable RGB24 <: AbstractRGB{N0f8}
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
function RGB24(r, g, b)
    checkval(N0f8, r, g, b)
    RGB24(_rem(r,N0f8), _rem(g,N0f8), _rem(b,N0f8))
end
@deprecate RGB24(x::UInt32) reinterpret(RGB24, x)

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
immutable ARGB32 <: AlphaColor{RGB24, N0f8, 4}
    color::UInt32

    ARGB32(col::UInt32, ::Type{Val{true}}) = new(col)
end
ARGB32() = reinterpret(ARGB32, UInt32(0xff)<<24)
_ARGB32(r::UInt8, g::UInt8, b::UInt8, alpha::UInt8) = reinterpret(ARGB32, UInt32(alpha)<<24 | UInt32(r)<<16 | UInt32(g)<<8 | UInt32(b))
ARGB32(r::N0f8, g::N0f8, b::N0f8, alpha::N0f8 = N0f8(1)) = _ARGB32(reinterpret(r), reinterpret(g), reinterpret(b), reinterpret(alpha))
ARGB32(r, g, b, alpha = 1) = ARGB32(N0f8(r), N0f8(g), N0f8(b), N0f8(alpha))
ARGB32{T}(c::AbstractRGB{T}, alpha = alpha(c)) = ARGB32(red(c), green(c), blue(c), alpha)
@deprecate ARGB32(x::UInt32) reinterpret(ARGB32, x)

"""
`Gray` is a grayscale object. You can extract its value with `gray(c)`.
"""
immutable Gray{T<:Union{Fractional,Bool}} <: AbstractGray{T}
    val::T

    Gray(val::T) = new(val)
    function Gray(val::Real)
        checkval(T, val)
        new(_rem(val,T))
    end
end
Gray{T<:Union{Fractional,Bool}}(val::T) = Gray{T}(val)

"""
`Gray24` uses a `UInt32` representation of color, 0xAAIIIIII, where
I=intensity (grayscale value) and A is irrelevant. Each II pair is
assumed to be the same.  This format is often used by external
libraries such as Cairo.

You can extract the single gray value with `gray(c)`.  You can
construct them directly from a `UInt32`, or as `Gray24(i)`. Note that
`i` is interpreted on a scale from 0 (black) to 1 (white).
"""
immutable Gray24 <: AbstractGray{N0f8}
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
@deprecate Gray24(x::UInt32) reinterpret(Gray24, x)

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
immutable AGray32 <: AlphaColor{Gray24, N0f8, 2}
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
@deprecate AGray32(x::UInt32) reinterpret(AGray32, x)

# Generated code:
#   - more constructors for colors
#   - TransparentColor definitions (e.g., ARGB), exports, and constructors
#   - coloralpha(::Color) and alphacolor(::Color) traits for corresponding types

# Note: with the exceptions of `alphacolor` and `coloralpha`, all
# traits in the rest of this file are intended just for internal use

const color3types = filter(x->(!x.abstract && length(fieldnames(x))>1), union(subtypes(Color), subtypes(AbstractRGB)))
const parametric3 = filter(x->!isempty(x.parameters), color3types)

# Provide the field names in the order expected by the constructor
colorfields{C<:Color}(::Type{C}) = (fieldnames(C)...)
colorfields{C<:RGB1}(::Type{C}) = (:r, :g, :b)
colorfields{C<:RGB4}(::Type{C}) = (:r, :g, :b)
colorfields{C<:BGR }(::Type{C}) = (:r, :g, :b)
colorfields{P<:TransparentColor}(::Type{P}) = tuple(colorfields(color_type(P))..., :alpha)
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
        $C{T<:Integer}($(Tfields...)) = $C{$elty}($(fields...))
        $C($(realfields...)) = $C(promote($(fields...))...)
        $C() = $C{$elty}($(zfields...))
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
    esc(quote
        immutable $acol{$Tconstr} <: AlphaColor{$C{T}, T, $N}
            alpha::T
            $(Tfields...)

            $acol($(Tconstrfields...), alpha::T=one(T)) = new(alpha, $(fields...))
            function $acol($(realfields...), alpha::Real=one(T))
                checkval(T, $(fields...), alpha)
                new(_rem(alpha,T), $(remfields...))
            end
            $acol(c::$C, alpha::Real=one(T)) = $acol{T}($(cfields...), alpha)
        end
        immutable $cola{$Tconstr} <: ColorAlpha{$C{T}, T, $N}
            $(Tfields...)
            alpha::T

            $cola($(Tconstrfields...), alpha::T=one(T)) = new($(fields...), alpha)
            function $cola($(realfields...), alpha::Real=one(T))
                checkval(T, $(fields...), alpha)
                new($(remfields...), _rem(alpha,T))
            end
            $cola(c::$C, alpha::Real=one(T)) = $cola{T}($(cfields...), alpha)
        end
        $exportexpr
        alphacolor{C<:$C}(::Type{C}) = $acol
        coloralpha{C<:$C}(::Type{C}) = $cola

        # More constructors for the alpha versions
        $acol{T<:Integer}($(Tconstrfields...), alpha::T=1) = $acol{$elty}($(fields...), alpha)
        $acol(c::$C, alpha=one(eltype(c))) = $acol{eltype(c)}(c, alpha)
        function $acol($(constrfields...))
            p = promote($(constrfields...))
            T = typeof(p[1])
            $acol{T}(p...)
        end
        function $acol($(constrfields...), alpha)
            p = promote($(constrfields...), alpha)
            T = typeof(p[1])
            $acol{T}(p...)
        end
        $acol(c::Color, alpha::Real) = $acol($C(c), alpha)
        $acol() = $acol{$elty}($(zfields...))

        $cola{T<:Integer}($(Tconstrfields...), alpha::T=1) = $cola{$elty}($(fields...), alpha)
        $cola(c::$C, alpha=one(eltype(c))) = $cola{eltype(c)}(c, alpha)
        function $cola($(constrfields...))
            p = promote($(constrfields...))
            T = typeof(p[1])
            $cola{T}(p...)
        end
        function $cola($(constrfields...), alpha)
            p = promote($(constrfields...), alpha)
            T = typeof(p[1])
            $cola{T}(p...)
        end
        $cola(c::Color, alpha::Real) = $cola($C(c), alpha)
        $cola() = $cola{$elty}($(zfields...))
    end)
end

eltype_default{C<:AbstractRGB  }(::Type{C}) = N0f8
eltype_default{C<:AbstractGray }(::Type{C}) = N0f8
eltype_default{C<:Color  }(::Type{C}) = Float32
eltype_default{P<:Colorant        }(::Type{P}) = eltype_default(color_type(P))

# Upper bound on element type for each color type
eltype_ub{P<:Colorant        }(::Type{P}) = eltype_ub(eltype_default(P))
eltype_ub{T<:FixedPoint   }(::Type{T}) = Fractional
eltype_ub{T<:AbstractFloat}(::Type{T}) = AbstractFloat

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
    Csym = C.name.name
    @eval @make_constructors $Csym $fn $elty
    @eval @make_alpha $Csym $acol $cola $fn $cfn $ub $elty
end

# RGB1 and RGB4 require special handling because of the alphadummy field
@eval @make_constructors RGB1 (r,g,b) $N0f8
@eval @make_constructors RGB4 (r,g,b) $N0f8
alphacolor{C<:Gray24}(::Type{C}) = AGray32
alphacolor{C<:RGB24}(::Type{C}) = ARGB32
alphacolor{C<:RGB1}(::Type{C}) = ARGB
alphacolor{C<:RGB4}(::Type{C}) = ARGB
coloralpha{C<:RGB1}(::Type{C}) = RGBA
coloralpha{C<:RGB4}(::Type{C}) = RGBA

"""
`alphacolor(RGB)` returns `ARGB`, i.e., the corresponding transparent
color type with storage order (alpha, color).
""" alphacolor

"""
`coloralpha(RGB)` returns `RGBA`, i.e., the corresponding transparent
color type with storage order (color, alpha).
""" coloralpha

### Validating the inputs for UFixed constructors

# Throw helpful errors in case of trouble. The inlining here is
# carefully designed to reduce the impact on runtime performance, and
# we also avoid splatting.

@inline function isok{T<:UFixed}(::Type{T}, x)
    Δ = eps(T)/2 # as long as the number rounds to a valid number, that's OK
    (-Δ <= x) & (x < typemax(T)+Δ)
end

@inline checkval{T<:UFixed}(::Type{T}, a) = isok(T, a) || throw_colorerror(T, a)

@inline function checkval{T<:UFixed}(::Type{T}, a, b)
    isok(T, a) & isok(T, b) || throw_colorerror(T, a, b)
end
@inline function checkval{T<:UFixed}(::Type{T}, a, b, c)
    isok(T, a) & isok(T, b) & isok(T, c) || throw_colorerror(T, a, b, c)
end
@inline function checkval{T<:UFixed}(::Type{T}, a, b, c, d)
    isok(T, a) & isok(T, b) & isok(T, c) & isok(T, d) || throw_colorerror(T, a, b, c, d)
end
checkval{T}(::Type{T}, a) = nothing
checkval{T}(::Type{T}, a, b) = nothing
checkval{T}(::Type{T}, a, b, c) = nothing
checkval{T}(::Type{T}, a, b, c, d) = nothing

@noinline throw_colorerror{T}(::Type{T}, g) = throw_colorerror(T, (g,))
@noinline throw_colorerror{T}(::Type{T}, g, a) = throw_colorerror(T, (g,a))
@noinline throw_colorerror{T}(::Type{T}, r, g, b) = throw_colorerror(T, (r, g, b))
@noinline throw_colorerror{T}(::Type{T}, r, g, b, a) = throw_colorerror(T, (r, g, b, a))

function throw_colorerror_{T<:UFixed}(::Type{T}, values)
    io = IOBuffer()
    showcompact(io, typemin(T)); Tmin = takebuf_string(io)
    showcompact(io, typemax(T)); Tmax = takebuf_string(io)
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

function throw_colorerror{T<:UFixed}(::Type{T}, values::Tuple)
    throw_colorerror_(T, values)
end

_rem{T<:UFixed}(x,::Type{T}) = x % T
_rem{T}(x, ::Type{T})        = x
