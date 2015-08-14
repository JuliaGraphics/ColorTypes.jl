# Paint means either Color or Color+Transparency
# N is the number of _meaningful_ entries. For the number of T elements,
# use length().  (See RGB1 and RGB4 below.)
abstract Paint{T, N}

# AbstractColor means just color, no transparency
abstract AbstractColor{T, N} <: Paint{T, N}
abstract Color{T}            <: AbstractColor{T, 3}
abstract AbstractGray{T}     <: AbstractColor{T, 1}
abstract AbstractRGB{T}      <: Color{T}

# Types with transparency
abstract Transparent{C<:AbstractColor,T,N} <: Paint{T,N}
# The storage order can be (alpha,color) or (color,alpha)
abstract AlphaColor{C,T,N} <: Transparent{C,T,N}
abstract ColorAlpha{C,T,N} <: Transparent{C,T,N}

# sRGB (standard Red-Green-Blue)
immutable RGB{T<:Fractional} <: AbstractRGB{T}
    r::T # Red [0,1]
    g::T # Green [0,1]
    b::T # Blue [0,1]
end

# Little-endian RGB (useful for BGRA & Cairo)
immutable BGR{T<:Fractional} <: AbstractRGB{T}
    b::T
    g::T
    r::T

    BGR(r::Real, g::Real, b::Real) = new(b, g, r)
end
BGR{T}(r::T, g::T, b::T) = BGR{T}(r, g, b)

# 4-byte RGB values (with meaningless alpha channel)
# These have nice memory-alignment properties and are returned by some readers
immutable RGB1{T<:Fractional} <: AbstractRGB{T}
    alphadummy::T
    r::T
    g::T
    b::T

    RGB1(r::Real, g::Real, b::Real) = new(one(T), r, g, b)
end
RGB1{T}(r::T, g::T, b::T) = RGB1{T}(r, g, b)

immutable RGB4{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGB4(r::Real, g::Real, b::Real) = new(r, g, b, one(T))
end
RGB4{T}(r::T, g::T, b::T) = RGB4{T}(r, g, b)

# HSV (Hue-Saturation-Value)
immutable HSV{T<:FloatingPoint} <: Color{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end

HSB(h, s, b) = HSV(h, s, b)

# HSL (Hue-Lightness-Saturation)
immutable HSL{T<:FloatingPoint} <: Color{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end

# HSI (Hue-Saturation-Intensity)
immutable HSI{T<:FloatingPoint} <: Color{T}
    h::T
    s::T
    i::T
end

# XYZ (CIE 1931)
immutable XYZ{T<:FloatingPoint} <: Color{T}
    x::T
    y::T
    z::T
end

# CIE 1931 xyY (chromaticity + luminance) space
immutable xyY{T<:FloatingPoint} <: Color{T}
    x::T
    y::T
    Y::T
end

# Lab (CIELAB)
immutable Lab{T<:FloatingPoint} <: Color{T}
    l::T # Luminance in approximately [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end

# LCHab (Luminance-Chroma-Hue, Polar-Lab)
immutable LCHab{T<:FloatingPoint} <: Color{T}
    l::T # Luminance in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end

# Luv (CIELUV)
immutable Luv{T<:FloatingPoint} <: Color{T}
    l::T # Luminance
    u::T # Red/Green
    v::T # Blue/Yellow
end

# LCHuv (Luminance-Chroma-Hue, Polar-Luv)
immutable LCHuv{T<:FloatingPoint} <: Color{T}
    l::T # Luminance
    c::T # Chroma
    h::T # Hue
end

# DIN99 (L99, a99, b99) - adaptation of CIELAB
immutable DIN99{T<:FloatingPoint} <: Color{T}
    l::T # L99
    a::T # a99
    b::T # b99
end

# DIN99d (L99d, a99d, b99d) - Improvement on DIN99
immutable DIN99d{T<:FloatingPoint} <: Color{T}
    l::T # L99d
    a::T # a99d
    b::T # b99d
end

# DIN99o (L99o, a99o, b99o) - adaptation of CIELAB
immutable DIN99o{T<:FloatingPoint} <: Color{T}
    l::T # L99o
    a::T # a99o
    b::T # b99o
end

# LMS (Long Medium Short)
immutable LMS{T<:FloatingPoint} <: Color{T}
    l::T # Long
    m::T # Medium
    s::T # Short
end

# YIQ (NTSC)
immutable YIQ{T<:FloatingPoint} <: Color{T}
    y::T
    i::T
    q::T
end

# Y'CbCr
immutable YCbCr{T<:FloatingPoint} <: Color{T}
    y::T
    cb::T
    cr::T
end

# 24 bit RGB and 32 bit ARGB (used by Cairo)
# It would be nice to make this a subtype of AbstractRGB, but it
# doesn't have operations like c.r defined.

immutable RGB24 <: Color{U8}
    color::UInt32
end
RGB24() = RGB24(0)
RGB24(r::UInt8, g::UInt8, b::UInt8) = RGB24(@compat(UInt32(r))<<16 | @compat(UInt32(g))<<8 | @compat(UInt32(b)))
RGB24(r::Ufixed8, g::Ufixed8, b::Ufixed8) = RGB24(reinterpret(r), reinterpret(g), reinterpret(b))

immutable ARGB32 <: AlphaColor{RGB24, U8}
    color::UInt32
end
ARGB32() = ARGB32(@compat(UInt32(0xff))<<24)
ARGB32(r::UInt8, g::UInt8, b::UInt8, alpha::UInt8) = ARGB32(@compat(UInt32(alpha))<<24 | @compat(UInt32(r))<<16 | @compat(UInt32(g))<<8 | @compat(UInt32(b)))
ARGB32(r::Ufixed8, g::Ufixed8, b::Ufixed8, alpha::Ufixed8) = ARGB32(reinterpret(r), reinterpret(g), reinterpret(b), reinterpret(alpha))

# Grayscale
immutable Gray{T<:Fractional} <: AbstractGray{T}
    val::T
end

immutable Gray24 <: AbstractGray{U8}
    color::UInt32
end
Gray24() = Gray24(0)
Gray24(val::UInt8) = (g = uint32(val); g<<16 | g<<8 | g)
Gray24(val::Ufixed8) = Gray24(reinterpret(val))

immutable AGray32 <: AlphaColor{Gray24, U8}
    color::UInt32
end
AGray32() = AGray32(0)
AGray32(val::UInt8, alpha::UInt8) = (g = uint32(val); uint32(alpha)<<24 | g<<16 | g<<8 | g)
AGray32(val::Ufixed8, alpha::Ufixed8) = AGray32(reinterpret(val), reinterpret(alpha))

# Generated code:
#   - more constructors for colors
#   - transparent paint typealiases (e.g., ARGB), exports, and constructors
#   - coloralpha(::Color) and alphacolor(::Color) traits for corresponding types

const colortypes = filter(x->!x.abstract, union(subtypes(Color), subtypes(AbstractRGB)))
const parametric = filter(x->!isempty(x.parameters), colortypes)

# Provide the field names in the order expected by the constructor
colorfields{C<:AbstractColor}(::Type{C}) = fieldnames(C)
colorfields{C<:RGB1}(::Type{C}) = (:r, :g, :b)
colorfields{C<:RGB4}(::Type{C}) = (:r, :g, :b)
colorfields{C<:BGR }(::Type{C}) = (:r, :g, :b)
colorfields{P<:Transparent}(::Type{P}) = tuple(colorfields(colortype(P))..., :alpha)
colorfields(c::Paint) = colorfields(typeof(c))

# Generate convenience constructors for a type
macro make_constructors(C, fields, elty)
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    Cstr = string(C)
    Cesc = esc(C)
    Tfields  = Expr[:($f::T)  for f in fields]
    zfields    = zeros(Int, length(fields))
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
eltype_default{C<:AbstractColor}(::Type{C}) = Float32
eltype_default{P<:Paint        }(::Type{P}) = eltype_default(colortype(P))

# Upper bound on element type for each color type
eltype_ub{P<:Paint        }(::Type{P}) = eltype_ub(eltype_default(P))
eltype_ub{T<:FixedPoint   }(::Type{T}) = Fractional
eltype_ub{T<:FloatingPoint}(::Type{T}) = FloatingPoint

for C in union(setdiff(parametric, [RGB1,RGB4]), [Gray])
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

Gray24() = Gray24(0)
Gray24(val::UInt8) = (g = uint32(val); g<<16 | g<<8 | g)
Gray24(val::Ufixed8) = Gray24(reinterpret(val))

convert(::Type{UInt32}, g::Gray24) = g.color


# no-op and element-type conversions, plus conversion to and from transparency
for C in union(ColorTypes.parametric, [Gray])
    AC, CA = alphacolor(C), coloralpha(C)
    fn  = colorfields(C)
    fnc = Expr[:(c.$f) for f in fn]
    fnT = Expr[:(convert(T, c.$f)) for f in fn]
    @eval begin
        convert{T}(::Type{$C{T}},  c::$C{T}) = c
           convert(::Type{$C},     c::$C   ) = c
        convert{T}(::Type{$C{T}},  c::$C   ) = $C{T}($(fnc...))
        convert{T}(::Type{$C{T}},  c::$AC  ) = $C{T}($(fnc...))
           convert(::Type{$C},     c::$AC  ) = $C{eltype(c)}($(fnc...))
        convert{T}(::Type{$C{T}},  c::$CA  ) = $C{T}($(fnc...))
           convert(::Type{$C},     c::$CA  ) = $C{eltype(c)}($(fnc...))
           convert(::Type{$AC},    c::$C   ) = $AC($(fnc...))
        convert{T}(::Type{$AC{T}}, c::$C   ) = $AC($(fnT...))
           convert(::Type{$CA},    c::$C   ) = $CA($(fnc...))
        convert{T}(::Type{$CA{T}}, c::$C   ) = $CA($(fnT...))
           convert(::Type{$AC},    c::$C, alpha) = $AC($(fnc...), alpha)
        convert{T}(::Type{$AC{T}}, c::$C, alpha) = $AC($(fnT...), convert(T, alpha))
           convert(::Type{$CA},    c::$C, alpha) = $CA($(fnc...), alpha)
        convert{T}(::Type{$CA{T}}, c::$C, alpha) = $CA($(fnT...), convert(T, alpha))
    end
    if C <: AbstractRGB
        @eval begin
               convert(::Type{$C},     c::RGB24)  = $C(red(c), green(c), blue(c))
               convert(::Type{$AC},    c::ARGB32) = $AC(red(c), green(c), blue(c), alpha(c))
            convert{T}(::Type{$AC{T}}, c::ARGB32) = $AC{T}(red(c), green(c), blue(c), alpha(c))
               convert(::Type{$CA},    c::ARGB32) = $CA(red(c), green(c), blue(c), alpha(c))
            convert{T}(::Type{$CA{T}}, c::ARGB32) = $CA{T}(red(c), green(c), blue(c), alpha(c))
        end
    end
end
convert(::Type{RGB24},  c::RGB24)  = c
convert(::Type{ARGB32}, c::ARGB32) = c
convert(::Type{RGB24},  c::ARGB32) = RGB24(c.color)
convert(::Type{ARGB32}, c::RGB24)  = ARGB32(c.color | 0xff000000)

convert(::Type{Gray24}, g::Gray{U8}) = Gray24(g.val)
convert(::Type{Gray24}, g::Gray)     = Gray24(convert(Gray{U8}, g))
convert(::Type{Gray},   g::Gray24)   = Gray(Ufixed8(g.color & 0x000000ff,0))
convert{T}(::Type{Gray{T}}, g::Gray24) = Gray{T}(Gray(g))

convert(::Type{UInt32}, c::RGB24)   = c.color
convert(::Type{UInt32}, c::ARGB32)  = c.color
convert(::Type{UInt32}, g::Gray24)  = g.color
convert(::Type{UInt32}, g::AGray32) = g.color
