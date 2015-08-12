# Paint means either Color or Color+Transparency
# N is the number of _meaningful_ entries. For the number of T elements,
# use length().  (See RGB1 and RGB4 below.)
abstract Paint{T, N}

# AbstractColor means just color, no transparency
abstract AbstractColor{T, N} <: Paint{T, N}
abstract Color{T}            <: AbstractColor{T, 3}
abstract AbstractRGB{T}      <: Color{T}
abstract AbstractGray{T}     <: AbstractColor{T, 1}

# Types with transparency
abstract Transparent{C<:AbstractColor,T,N} <: Paint{T,N}
# The storage order can be (alpha,color) or (color,alpha)
abstract AbstractAlphaColor{C,T,N} <: Transparent{C,T,N}
abstract AbstractColorAlpha{C,T,N} <: Transparent{C,T,N}

# Containers
immutable AlphaColor{C<:Color,T} <: AbstractAlphaColor{C,T,4}
    alpha::T
    c::C

    function AlphaColor(x1::Real, x2::Real, x3::Real, alpha::Real = 1.0)
        new(C(x1, x2, x3), alpha)
    end
    AlphaColor(c::Color, alpha::Real) = new(c, alpha)
end

immutable ColorAlpha{C<:Color,T} <: AbstractColorAlpha{C,T,4}
    c::C
    alpha::T

    function ColorAlpha(x1::T, x2::T, x3::T, alpha::T = one(T))
        new(C(x1, x2, x3), alpha)
    end
    ColorAlpha(c::Color{T}, alpha::T) = new(c, alpha)
end

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

immutable RGB4{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGB4(r::Real, g::Real, b::Real) = new(r, g, b, one(T))
end

# HSV (Hue-Saturation-Value)
immutable HSV{T<:FloatingPoint} <: Color{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end
HSV{T<:FloatingPoint}(h::T, s::T, v::T) = HSV{T}(h, s, v)
HSV(h, s, v) = HSV{Float64}(h, s, v)
HSV() = HSV(0.0, 0.0, 0.0)


HSB(h, s, b) = HSV(h, s, b)


# HSL (Hue-Lightness-Saturation)
immutable HSL{T<:FloatingPoint} <: Color{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end
HLS(h, l, s) = HSL(h, s, l)


# XYZ (CIE 1931)
immutable XYZ{T<:Fractional} <: Color{T}
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
xyY{T<:FloatingPoint}(x::T, y::T, Y::T) = xyY{T}(x, y, Y)
xyY(x, y, Y) = xyY{Float64}(x, y, Y)
xyY() = xyY(0.0,0.0,0.0)

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

immutable AlphaGray{T<:Fractional} <: Transparent{Gray{T},T,2}
    alpha::T
    c::Gray{T}
end

immutable GrayAlpha{T<:Fractional} <: Transparent{Gray{T},T,2}
    c::Gray{T}
    alpha::T
end

immutable Gray24 <: AbstractGray{Uint8}
    color::UInt32
end

immutable AGray32 <: AbstractAlphaColor{Gray24, UInt8}
    color::UInt32
end

# Add typealiases here
typealias RGBA{T} ColorAlpha{RGB{T},T}
typealias ARGB{T} AlphaColor{RGB{T},T}
typealias BGRA{T} ColorAlpha{BGR{T},T}
