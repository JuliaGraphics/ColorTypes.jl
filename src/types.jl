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
abstract AbstractAlphaColor{C,T,N} <: Transparent{C,T,N}
abstract AbstractColorAlpha{C,T,N} <: Transparent{C,T,N}

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
end

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

# HSI
immutable HSI{T<:FloatingPoint} <: Color{T}
    h::T
    s::T
    i::T
end

# 24 bit RGB and 32 bit ARGB (used by Cairo)
# It would be nice to make this a subtype of AbstractRGB, but it doesn't have operations like c.r defined.
immutable RGB24 <: Color{U8}
    color::UInt32
end
RGB24() = RGB24(0)
RGB24(r::Uint8, g::Uint8, b::Uint8) = RGB24(uint32(r)<<16 | uint32(g)<<8 | uint32(b))
RGB24(r::Ufixed8, g::Ufixed8, b::Ufixed8) = RGB24(reinterpret(r), reinterpret(g), reinterpret(b))

immutable ARGB32 <: AbstractAlphaColor{RGB24, U8}
    color::UInt32
end
ARGB32() = ARGB32(0)
ARGB32(r::Uint8, g::Uint8, b::Uint8, alpha::Uint8) = ARGB32(uint32(alpha)<<24 | uint32(r)<<16 | uint32(g)<<8 | uint32(b))
ARGB32(r::Ufixed8, g::Ufixed8, b::Ufixed8, alpha::Ufixed8) = ARGB32(reinterpret(r), reinterpret(g), reinterpret(b), reinterpret(alpha))

# Grayscale
immutable Gray{T<:Fractional} <: AbstractGray{T}
    val::T
end

immutable Gray24 <: AbstractGray{Uint8}
    color::UInt32
end

immutable AGray32 <: AbstractAlphaColor{Gray24, UInt8}
    color::UInt32
end

# Generated code:
#   - more constructors for colors
#   - transparent paint typealiases (e.g., ARGB), exports, and constructors
#   - coloralpha(::Color) and alphacolor(::Color) traits for corresponding types

const colortypes = filter(x->!x.abstract, union(subtypes(Color), subtypes(AbstractRGB)))
const parametric = filter(x->!isempty(x.parameters), colortypes)

# Generate convenience constructors for a type
macro make_constructors(C, fields, elty)
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    Cstr = string(C)
    Cesc = esc(C)
    intfields  = Expr[:($f::Int)  for f in fields]
    fieldsz    = zeros(Int, length(fields))
    esc(quote
        # More constructors for the non-alpha version
        $C($(intfields...)) = $C{$elty}($(fields...))
        $C($(fields...)) = $C(promote($(fields...))...)
        $C() = $C{$elty}($(fieldsz...))
    end)
end

# Generate transparent versions
macro make_alpha(C, fields, ub, elty)
    # ub = upper-bound on T in C{T}
    # elty = default element type when supplied with Integer arguments
    fields = fields.args
    N = length(fields)+1
    Cstr = string(C)
    Cesc = esc(C)
    Tfields    = Expr[:($f::T)    for f in fields]
    realfields = Expr[:($f::Real) for f in fields]
    intfields  = Expr[:($f::Int)  for f in fields]
    fieldsz    = zeros(Int, length(fields))
    acol = symbol(string("A",Cstr))
    cola = symbol(string(Cstr,"A"))
    Tconstr = Expr(:<:, :T, ub)
    esc(quote
        immutable $acol{$Tconstr} <: AbstractAlphaColor{$C{T}, T, $N}
            alpha::T
            $(Tfields...)

            $acol($(realfields...), alpha::Real=one(T)) = new(alpha, $(fields...))
        end
        immutable $cola{$Tconstr} <: AbstractColorAlpha{$C{T}, T, $N}
            $(Tfields...)
            alpha::T

            $cola($(realfields...), alpha::Real=one(T)) = new($(fields...), alpha)
        end
        export $acol, $cola
        alphacolor{C<:$C}(::Type{C}) = $acol
        coloralpha{C<:$C}(::Type{C}) = $cola

        # More constructors for the alpha versions
        $acol($(intfields...), alpha::Integer=1) = $acol{$elty}($(fields...), alpha)
        function $acol($(fields...))
            p = promote($(fields...))
            T = typeof(p[1])
            $acol{T}(p...)
        end
        function $acol($(fields...), alpha)
            p = promote($(fields...), alpha)
            T = typeof(p[1])
            $acol{T}(p...)
        end
        $acol() = $acol{$elty}($(fieldsz...))

        $cola($(intfields...), alpha::Integer=1) = $cola{$elty}($(fields...), alpha)
        function $cola($(fields...))
            p = promote($(fields...))
            T = typeof(p[1])
            $cola{T}(p...)
        end
        function $cola($(fields...), alpha)
            p = promote($(fields...), alpha)
            T = typeof(p[1])
            $cola{T}(p...)
        end
        $cola() = $cola{$elty}($(fieldsz...))
    end)
end

for C in union(setdiff(parametric, [RGB1,RGB4]), [Gray])
    fn = Expr(:tuple, fieldnames(C)...)
    use_fractional = C <: AbstractRGB || C == Gray
    ub   = use_fractional ? Fractional : FloatingPoint
    elty = use_fractional ? U8 : Float32
    Csym = C.name.name
    @eval @make_constructors $Csym $fn $elty
    @eval @make_alpha $Csym $fn $ub $elty
end

# RGB1 and RGB4 require special handling because of the alphadummy field
@make_constructors RGB1 (r,g,b) U8
@make_constructors RGB4 (r,g,b) U8
alphacolor{C<:RGB1}(::Type{C}) = ARGB
alphacolor{C<:RGB4}(::Type{C}) = ARGB
coloralpha{C<:RGB1}(::Type{C}) = RGBA
coloralpha{C<:RGB4}(::Type{C}) = RGBA
