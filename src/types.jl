@doc """
`Colorant{T,N}` is the abstract super-type of all types in ColorTypes,
and refers to both (opaque) colors and colors-with-transparency (alpha
channel) information.  `T` is the element type (extractable with
`eltype`) and `N` is the number of *meaningful* entries (extractable
with `length`), i.e., the number of arguments you would supply to the
constructor.
""" ->
abstract Colorant{T,N}

# Colors (without transparency)
@doc """
`Color{T,N}` is the abstract supertype for a color (or
grayscale) with no transparency.
""" ->
abstract Color{T, N} <: Colorant{T,N}

@doc """
`AbstractRGB{T}` is an abstract supertype for red/green/blue color types that
can be constructed as `C(r, g, b)` and for which the elements can be
extracted as `red(c)`, `green(c)`, `blue(c)`. You should *not* make
assumptions about internal storage order, the number of fields, or the
representation. One `AbstractRGB` color-type, `RGB24`, is not
parametric and does not have fields named `r`, `g`, `b`.
""" ->
abstract AbstractRGB{T}      <: Color{T,3}


# Types with transparency
@doc """
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
""" ->
abstract TransparentColor{C<:Color,T,N} <: Colorant{T,N}

@doc """
`AlphaColor` is an abstract supertype for types like `ARGB`, where the
alpha channel comes first in the internal storage order. **Note** that
the constructor order is still `(color, alpha)`.
""" ->
abstract AlphaColor{C,T,N} <: TransparentColor{C,T,N}

@doc """
`ColorAlpha` is an abstract supertype for types like `RGBA`, where the
alpha channel comes last in the internal storage order.
""" ->
abstract ColorAlpha{C,T,N} <: TransparentColor{C,T,N}

# These are types we'll dispatch on. Not exported.
typealias AbstractGray{T}                    Color{T,1}
typealias Color3{T}                          Color{T,3}
typealias TransparentGray{C<:AbstractGray,T} TransparentColor{C,T,2}
typealias Transparent3{C<:Color3,T}          TransparentColor{C,T,4}
typealias TransparentRGB{C<:AbstractRGB,T}   TransparentColor{C,T,4}
typealias ColorantUfixed{T<:Ufixed,N}        Colorant{T,N}

@doc """
`RGB` is the standard Red-Green-Blue (sRGB) colorspace.  Values of the
individual color channels range from 0 (black) to 1 (saturated). If
you want "Integer" storage types (e.g., 255 for full color), use `U8(1)`
instead (see FixedPointNumbers).
""" ->
immutable RGB{T<:Fractional} <: AbstractRGB{T}
    r::T # Red [0,1]
    g::T # Green [0,1]
    b::T # Blue [0,1]
end

@doc """
`BGR` is a variant of `RGB` with the opposite storage order.  Note
that the constructor is still called in the order `BGR(r, g, b)`.
This storage order is noteworthy because on little-endian machines,
`BGRA` (with transparency) can be `reinterpret`ed to the `UInt32`
color format used by libraries such as Cairo and OpenGL.
""" ->
immutable BGR{T<:Fractional} <: AbstractRGB{T}
    b::T
    g::T
    r::T

    BGR(r::Real, g::Real, b::Real) = new(b, g, r)
end
BGR{T}(r::T, g::T, b::T) = BGR{T}(r, g, b)

@doc """
`RGB1` is a variant of `RGB` which has a padding element inserted at
the beginning. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGB1(r, g, b)`.
""" ->
immutable RGB1{T<:Fractional} <: AbstractRGB{T}
    alphadummy::T
    r::T
    g::T
    b::T

    RGB1(r::Real, g::Real, b::Real) = new(one(T), r, g, b)
end
RGB1{T}(r::T, g::T, b::T) = RGB1{T}(r, g, b)

@doc """
`RGB4` is a variant of `RGB` which has a padding element inserted at
the end. In some applications it may have useful
memory-alignment properties.

Like all other AbstractRGB objects, the constructor is still called
`RGB4(r, g, b)`.
""" ->
immutable RGB4{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGB4(r::Real, g::Real, b::Real) = new(r, g, b, one(T))
end
RGB4{T}(r::T, g::T, b::T) = RGB4{T}(r, g, b)

@doc "`HSV` is the Hue-Saturation-Value colorspace." ->
immutable HSV{T<:FloatingPoint} <: Color{T,3}
    h::T # Hue in [0,360)
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end

@doc "`HSB` (Hue-Saturation-Brightness) is an alias for `HSV`." ->
HSB(h, s, b) = HSV(h, s, b)

@doc "`HSL` is the Hue-Saturation-Lightness colorspace." ->
immutable HSL{T<:FloatingPoint} <: Color{T,3}
    h::T # Hue in [0,360)
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end

@doc "`HSI` is the Hue-Saturation-Intensity colorspace." ->
immutable HSI{T<:FloatingPoint} <: Color{T,3}
    h::T
    s::T
    i::T
end

@doc """
`XYZ` is the CIE 1931 XYZ colorspace. It is a linear colorspace,
meaning that mathematical operations such as addition, subtraction,
and scaling make "colorimetric sense" in this colorspace.
""" ->
immutable XYZ{T<:FloatingPoint} <: Color{T,3}
    x::T
    y::T
    z::T
end

@doc "`xyY` is the CIE 1931 xyY (chromaticity + luminance) space" ->
immutable xyY{T<:FloatingPoint} <: Color{T,3}
    x::T
    y::T
    Y::T
end

@doc "`Lab` is the CIELAB colorspace." ->
immutable Lab{T<:FloatingPoint} <: Color{T,3}
    l::T # Luminance in approximately [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end

@doc "`LCHab` is the Luminance-Chroma-Hue, Polar-Lab colorspace" ->
immutable LCHab{T<:FloatingPoint} <: Color{T,3}
    l::T # Luminance in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360)
end

@doc "`Luv` is the CIELUV colorspace" ->
immutable Luv{T<:FloatingPoint} <: Color{T,3}
    l::T # Luminance
    u::T # Red/Green
    v::T # Blue/Yellow
end

@doc "`LCHuv` is the Luminance-Chroma-Hue, Polar-Luv colorspace" ->
immutable LCHuv{T<:FloatingPoint} <: Color{T,3}
    l::T # Luminance
    c::T # Chroma
    h::T # Hue
end

@doc "`DIN99` is the (L99, a99, b99) adaptation of CIELAB" ->
immutable DIN99{T<:FloatingPoint} <: Color{T,3}
    l::T # L99
    a::T # a99
    b::T # b99
end

@doc "`DIN99d` is the (L99d, a99d, b99d) improvement on DIN99" ->
immutable DIN99d{T<:FloatingPoint} <: Color{T,3}
    l::T # L99d
    a::T # a99d
    b::T # b99d
end

@doc "`DIN99o` is the (L99o, a99o, b99o) adaptation of CIELAB" ->
immutable DIN99o{T<:FloatingPoint} <: Color{T,3}
    l::T # L99o
    a::T # a99o
    b::T # b99o
end

@doc """
`LMS` is the Long-Medium-Short colorspace based on activation of the
three cone photoreceptors.  Like `XYZ`, this is a linear color space.
""" ->
immutable LMS{T<:FloatingPoint} <: Color{T,3}
    l::T # Long
    m::T # Medium
    s::T # Short
end

@doc "`YIQ` is a color encoding, for example used in NTSC transmission." ->
immutable YIQ{T<:FloatingPoint} <: Color{T,3}
    y::T
    i::T
    q::T
end

@doc "`YCbCr` is the Y'CbCr color encoding often used in digital photography or video" ->
immutable YCbCr{T<:FloatingPoint} <: Color{T,3}
    y::T
    cb::T
    cr::T
end

@doc """
`RGB24` uses a `UInt32` representation of color, 0xAARRGGBB, where
R=red, G=green, B=blue and A is irrelevant. This format is often used
by external libraries such as Cairo.

`RGB24` colors do not have fields named `r`, `g`, `b`, but you can
still extract the individual components with `red(c)`, `green(c)`,
`blue(c)`.  You can construct them directly from a `UInt32`, or as
`RGB(r, g, b)`.
""" ->
immutable RGB24 <: AbstractRGB{U8}
    color::UInt32
end
RGB24() = RGB24(0)
_RGB24(r::UInt8, g::UInt8, b::UInt8) = RGB24(@compat(UInt32(r))<<16 | @compat(UInt32(g))<<8 | @compat(UInt32(b)))
RGB24(r::Ufixed8, g::Ufixed8, b::Ufixed8) = _RGB24(reinterpret(r), reinterpret(g), reinterpret(b))
RGB24(r, g, b) = RGB24(@compat(U8(r)), @compat(U8(g)), @compat(U8(b)))

@doc """
`ARGB32` uses a `UInt32` representation of color, 0xAARRGGBB, where
R=red, G=green, B=blue and A is the alpha channel. This format is
often used by external libraries such as Cairo.  On a little-endian
machine, this type has the exact same storage format as `BGRA{U8}`.

`ARGB32` colors do not have fields named `alpha`, `r`, `g`, `b`, but
you can still extract the individual components with `alpha(c)`,
`red(c)`, `green(c)`, `blue(c)`.  You can construct them directly from
a `UInt32`, or as `ARGB32(r, g, b, alpha)`.
""" ->
immutable ARGB32 <: AlphaColor{RGB24, U8, 4}
    color::UInt32
end
ARGB32() = ARGB32(@compat(UInt32(0xff))<<24)
_ARGB32(r::UInt8, g::UInt8, b::UInt8, alpha::UInt8) = ARGB32(@compat(UInt32(alpha))<<24 | @compat(UInt32(r))<<16 | @compat(UInt32(g))<<8 | @compat(UInt32(b)))
ARGB32(r::Ufixed8, g::Ufixed8, b::Ufixed8, alpha::Ufixed8 = U8(1)) = _ARGB32(reinterpret(r), reinterpret(g), reinterpret(b), reinterpret(alpha))
ARGB32(r, g, b, alpha = 1) = ARGB32(@compat(U8(r)), @compat(U8(g)), @compat(U8(b)), @compat(U8(alpha)))

@doc """
`Gray` is a grayscale object. You can extract its value with `gray(c)`.
""" ->
immutable Gray{T<:Fractional} <: AbstractGray{T}
    val::T
end

@doc """
`Gray24` uses a `UInt32` representation of color, 0xAAIIIIII, where
I=intensity (grayscale value) and A is irrelevant. Each II pair is
assumed to be the same.  This format is often used by external
libraries such as Cairo.

You can extract the single gray value with `gray(c)`.  You can
construct them directly from a `UInt32`, or as `Gray24(i)`. Note that
`i` is interpreted on a scale from 0 (black) to 1 (white).
""" ->
immutable Gray24 <: AbstractGray{U8}
    color::UInt32
end
Gray24() = Gray24(0)
_Gray24(val::UInt8) = (g = @compat(UInt32(val)); Gray24(g<<16 | g<<8 | g))
Gray24(val::Ufixed8) = _Gray24(reinterpret(val))
Gray24(val) = Gray24(@compat(U8(val)))

@doc """
`AGray32` uses a `UInt32` representation of color, 0xAAIIIIII, where
I=intensity (grayscale value) and A=alpha. Each II pair is
assumed to be the same.  This format is often used by external
libraries such as Cairo.

You can extract the single gray value with `gray(c)` and the alpha as
`alpha(c)`.  You can construct them directly from a `UInt32`, or as
`AGray32(i,alpha)`. Note that `i` and `alpha` are interpreted on a
scale from 0 (black) to 1 (white).
""" ->
immutable AGray32 <: AlphaColor{Gray24, U8}
    color::UInt32
end
AGray32() = AGray32(0)
_AGray32(val::UInt8, alpha::UInt8 = 0xff) = (g = @compat(UInt32(val)); AGray32(@compat(UInt32(alpha))<<24 | g<<16 | g<<8 | g))
AGray32(val::Ufixed8, alpha::Ufixed8 = Ufixed8(1)) = _AGray32(reinterpret(val), reinterpret(alpha))
AGray32(val, alpha = 1) = AGray32(@compat(U8(val)), @compat(U8(alpha)))

# Generated code:
#   - more constructors for colors
#   - TransparentColor definitions (e.g., ARGB), exports, and constructors
#   - coloralpha(::Color) and alphacolor(::Color) traits for corresponding types

# Note: with the exceptions of `alphacolor` and `coloralpha`, all
# traits in the rest of this file are intended just for internal use

const color3types = filter(x->(!x.abstract && length(fieldnames(x))>1), union(subtypes(Color), subtypes(AbstractRGB)))
const parametric3 = filter(x->!isempty(x.parameters), color3types)

# Provide the field names in the order expected by the constructor
colorfields{C<:Color}(::Type{C}) = fieldnames(C)
colorfields{C<:RGB1}(::Type{C}) = (:r, :g, :b)
colorfields{C<:RGB4}(::Type{C}) = (:r, :g, :b)
colorfields{C<:BGR }(::Type{C}) = (:r, :g, :b)
colorfields{P<:TransparentColor}(::Type{P}) = tuple(colorfields(color_type(P))..., :alpha)
colorfields(c::Colorant) = colorfields(typeof(c))

# Generate convenience constructors for a type
macro make_constructors(C, fields, elty)
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    Cstr = string(C)
    Cesc = esc(C)
    Tfields = Expr[:($f::T) for f in fields]
    zfields = zeros(Int, length(fields))
    esc(quote
        # More constructors for the non-alpha version
        $C{T<:Integer}($(Tfields...)) = $C{$elty}($(fields...))
        $C($(fields...)) = $C(promote($(fields...))...)
        $C() = $C{$elty}($(zfields...))
    end)
end

# Generate transparent versions
macro make_alpha(C, fields, constrfields, ub, elty)
    # ub = upper-bound on T in C{T}
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    constrfields = constrfields.args
    N = length(fields)+1
    Cstr = string(C)
    Cesc = esc(C)
    Tfields       = Expr[:($f::T)    for f in fields]
    Tconstrfields = Expr[:($f::T)    for f in constrfields]
    realfields    = Expr[:($f::Real) for f in constrfields]
    cfields       = Expr[:(c.$f)     for f in constrfields]
    cinnerfields  = Expr[:(c.$f)     for f in fields]
    zfields       = zeros(Int, length(fields))
    acol = symbol(string("A",Cstr))
    cola = symbol(string(Cstr,"A"))
    Tconstr = Expr(:<:, :T, ub)
    # Handling limitations of 0.3
    exportexpr = Expr(:export, acol, cola)
    Tcfields = Expr[:(convert(T, c.$f)) for f in constrfields]
    extradefs = VERSION >= v"0.4.0-dev" ? nothing : quote
        $acol(c::$C) = $acol($(cfields...))
        $acol(c::$C, alpha) = $acol($(cfields...), convert(eltype(c), alpha))
        $cola(c::$C) = $cola($(cfields...))
        $cola(c::$C, alpha) = $cola($(cfields...), convert(eltype(c), alpha))
    end
    esc(quote
        immutable $acol{$Tconstr} <: AlphaColor{$C{T}, T, $N}
            alpha::T
            $(Tfields...)

            $acol($(realfields...), alpha::Real=one(T)) = new(alpha, $(fields...))
            $acol(c::$C, alpha::Real=one(T)) = new(alpha, $(cinnerfields...))
        end
        immutable $cola{$Tconstr} <: ColorAlpha{$C{T}, T, $N}
            $(Tfields...)
            alpha::T

            $cola($(realfields...), alpha::Real=one(T)) = new($(fields...), alpha)
            $cola(c::$C, alpha::Real=one(T)) = new($(cinnerfields...), alpha)
        end
        $exportexpr
        alphacolor{C<:$C}(::Type{C}) = $acol
        coloralpha{C<:$C}(::Type{C}) = $cola

        # More constructors for the alpha versions
        $acol{T<:Integer}($(Tconstrfields...), alpha::T=1) = $acol{$elty}($(fields...), alpha)
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
        $acol() = $acol{$elty}($(zfields...))

        $cola{T<:Integer}($(Tconstrfields...), alpha::T=1) = $cola{$elty}($(fields...), alpha)
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
        $cola() = $cola{$elty}($(zfields...))
        $extradefs
    end)
end

eltype_default{C<:AbstractRGB  }(::Type{C}) = U8
eltype_default{C<:AbstractGray }(::Type{C}) = U8
eltype_default{C<:Color  }(::Type{C}) = Float32
eltype_default{P<:Colorant        }(::Type{P}) = eltype_default(color_type(P))

# Upper bound on element type for each color type
eltype_ub{P<:Colorant        }(::Type{P}) = eltype_ub(eltype_default(P))
eltype_ub{T<:FixedPoint   }(::Type{T}) = Fractional
eltype_ub{T<:FloatingPoint}(::Type{T}) = FloatingPoint

for C in union(setdiff(parametric3, [RGB1,RGB4]), [Gray])
    fn  = Expr(:tuple, fieldnames(C)...)
    cfn = Expr(:tuple, colorfields(C)...)
    elty = eltype_default(C)
    ub   = eltype_ub(C)
    Csym = C.name.name
    @eval @make_constructors $Csym $fn $elty
    @eval @make_alpha $Csym $fn $cfn $ub $elty
end

# RGB1 and RGB4 require special handling because of the alphadummy field
@make_constructors RGB1 (r,g,b) U8
@make_constructors RGB4 (r,g,b) U8
alphacolor{C<:RGB1}(::Type{C}) = ARGB
alphacolor{C<:RGB4}(::Type{C}) = ARGB
coloralpha{C<:RGB1}(::Type{C}) = RGBA
coloralpha{C<:RGB4}(::Type{C}) = RGBA

@doc """
`alphacolor(RGB)` returns `ARGB`, i.e., the corresponding transparent
color type with storage order (alpha, color).
""" -> alphacolor

@doc """
`coloralpha(RGB)` returns `RGBA`, i.e., the corresponding transparent
color type with storage order (color, alpha).
""" -> coloralpha
