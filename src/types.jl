typealias Fractional Union(FloatingPoint, FixedPoint)

abstract Color{T, N}                <: FixedVector{T, N}
abstract AlphaColor{T}              <: Color{T, 4}
abstract Color3{T}                  <: Color{T, 3}
abstract AbstractGray{T}            <: Color{T, 1}
abstract Intensity{T}               <: Color{T, 1}
abstract AbstractRGB{T}             <: Color3{T}
abstract AbstractAlphaColor{ColorType, T} <: AlphaColor{T}




# sRGB (standard Red-Green-Blue)
immutable RGB{T<:Fractional} <: AbstractRGB{T}
    r::T # Red [0,1]
    g::T # Green [0,1]
    b::T # Blue [0,1]
end


typemin{T}(::Type{RGB{T}}) = RGB{T}(zero(T), zero(T), zero(T))
typemax{T}(::Type{RGB{T}}) = RGB{T}(one(T),  one(T),  one(T))


# Little-endian RGB (useful for BGRA & Cairo)
immutable BGR{T<:Fractional} <: AbstractRGB{T}
    b::T
    g::T
    r::T
end

immutable BGRA{T} <: AbstractAlphaColor{BGR{T}, T}
    b::T
    g::T
    r::T
    a::T
end
# Little-endian RGB (useful for BGRA & Cairo)
immutable RGBA{T<:Fractional} <: AbstractAlphaColor{RGB{T}, T}
    r::T
    g::T
    b::T
    a::T
end



# Some readers return a byte for an alpha channel even if it's not meaningful
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

immutable Gray{T<:Fractional} <: AbstractGray{T}
    val::T
end

immutable GrayAlpha{T<:Fractional} <: Color{T, 2}
    val::T
    alpha::T
end

immutable Gray24 <: AbstractGray{Uint8}
    color::Uint32
end

immutable AGray32 <: AbstractAlphaColor{Gray24, Uint8}
    color::Uint32
end


# YIQ (NTSC)
immutable YIQ{T<:FloatingPoint} <: Color3{T}
    y::T
    i::T
    q::T
end


# Y'CbCr
immutable YCbCr{T<:FloatingPoint} <: Color3{T}
    y::T
    cb::T
    cr::T
end


# HSI
immutable HSI{T<:FloatingPoint} <: Color3{T}
    h::T
    s::T
    i::T
end




# HSV (Hue-Saturation-Value)
immutable HSV{T<:FloatingPoint} <: Color3{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end
HSV{T<:FloatingPoint}(h::T, s::T, v::T) = HSV{T}(h, s, v)
HSV(h, s, v) = HSV{Float64}(h, s, v)
HSV() = HSV(0.0, 0.0, 0.0)


HSB(h, s, b) = HSV(h, s, b)


# HSL (Hue-Lightness-Saturation)
immutable HSL{T<:FloatingPoint} <: Color3{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end
HLS(h, l, s) = HSL(h, s, l)


# XYZ (CIE 1931)
immutable XYZ{T<:Fractional} <: Color3{T}
    x::T
    y::T
    z::T
end

# CIE 1931 xyY (chromaticity + luminance) space
immutable xyY{T<:FloatingPoint} <: Color3{T}
    x::T
    y::T
    Y::T
end
xyY{T<:FloatingPoint}(x::T, y::T, Y::T) = xyY{T}(x, y, Y)
xyY(x, y, Y) = xyY{Float64}(x, y, Y)
xyY() = xyY(0.0,0.0,0.0)

# Lab (CIELAB)
immutable Lab{T<:FloatingPoint} <: Color3{T}
    l::T # Luminance in approximately [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end

# LCHab (Luminance-Chroma-Hue, Polar-Lab)
immutable LCHab{T<:FloatingPoint} <: Color3{T}
    l::T # Luminance in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end


# Luv (CIELUV)
immutable Luv{T<:FloatingPoint} <: Color3{T}
    l::T # Luminance
    u::T # Red/Green
    v::T # Blue/Yellow
end


# LCHuv (Luminance-Chroma-Hue, Polar-Luv)
immutable LCHuv{T<:FloatingPoint} <: Color3{T}
    l::T # Luminance
    c::T # Chroma
    h::T # Hue
end


# DIN99 (L99, a99, b99) - adaptation of CIELAB
immutable DIN99{T<:FloatingPoint} <: Color3{T}
    l::T # L99
    a::T # a99
    b::T # b99
end

# DIN99d (L99d, a99d, b99d) - Improvement on DIN99
immutable DIN99d{T<:FloatingPoint} <: Color3{T}
    l::T # L99d
    a::T # a99d
    b::T # b99d
end

# DIN99o (L99o, a99o, b99o) - adaptation of CIELAB
immutable DIN99o{T<:FloatingPoint} <: Color3{T}
    l::T # L99o
    a::T # a99o
    b::T # b99o
end

# LMS (Long Medium Short)
immutable LMS{T<:FloatingPoint} <: Color3{T}
    l::T # Long
    m::T # Medium
    s::T # Short
end

# 24 bit RGB and 32 bit ARGB (used by Cairo)
# It would be nice to make this a subtype of AbstractRGB, but it doesn't have operations like c.r defined.
immutable RGB24 <: AbstractRGB{Uint8}
    color::Uint32
end
RGB24() = RGB24(0)
RGB24(r::Uint8, g::Uint8, b::Uint8) = RGB24(uint32(r)<<16 | uint32(g)<<8 | uint32(b))
RGB24(r::Ufixed8, g::Ufixed8, b::Ufixed8) = RGB24(reinterpret(r), reinterpret(g), reinterpret(b))

immutable ARGB32 <: AbstractAlphaColor{RGB24, Uint8}
    color::Uint32
end
ARGB32() = ARGB32(0)
ARGB32(r::Uint8, g::Uint8, b::Uint8, alpha::Uint8) = ARGB32(uint32(alpha)<<24 | uint32(r)<<16 | uint32(g)<<8 | uint32(b))
ARGB32(r::Ufixed8, g::Ufixed8, b::Ufixed8, alpha::Ufixed8) = ARGB32(reinterpret(r), reinterpret(g), reinterpret(b), reinterpret(alpha))

AlphaColorValue(c::RGB24, alpha::Uint8 = 0xff) = AlphaColorValue{typeof(c),Uint8}(c, alpha)
