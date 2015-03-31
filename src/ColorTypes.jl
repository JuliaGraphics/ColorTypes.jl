module ColorTypes

using FixedSizeArrays
using FixedPointNumbers

include("types.jl")

#export RGBAU8       # typealias for RGBA ufixed 8 value
#export rgba         # function for creating a rgba Float32 color
#export rgbaU8       # function for creating a rgba Ufixed8 color

#export tohsva       # Convert to HSVA
#export torgba       # Converts to RGBA


export Color    
export AlphaColor
export Color3
export Gray
export Intensity
export AbstractRGB
export AbstractAlphaColorValue

# Little-endian RGB (useful for BGRA & Cairo)
export BGR
# Some readers return a byte for an alpha channel even if it's not meaningful
export RGB1
export RGB4
export Gray
export Gray24
export AGray32
# YIQ (NTSC)
export YIQ
# Y'CbCr
export YCbCr
# HSI
export HSI
# sRGB (standard Red-Green-Blue)
export RGB
export RGBA # Simple rgb alpha color

# HSV (Hue-Saturation-Value)
export HSV
# HSL (Hue-Lightness-Saturation)
export HSL
export HLS
# XYZ (CIE 1931)
export XYZ
# CIE 1931 xyY (chromaticity + luminance) space
export xyY
# Lab (CIELAB)
export Lab
typealias LAB Lab
# LCHab (Luminance-Chroma-Hue, Polar-Lab)
export LCHab
# Luv (CIELUV)
export Luv
typealias LUV Luv
# LCHuv (Luminance-Chroma-Hue, Polar-Luv)
export LCHuv
# DIN99 (L99, a99, b99) - adaptation of CIELAB
export DIN99
# DIN99d (L99d, a99d, b99d) - Improvement on DIN99
export DIN99d
# DIN99o (L99o, a99o, b99o) - adaptation of CIELAB
export DIN99o
# LMS (Long Medium Short)
export LMS
# 24 bit RGB and 32 bit ARGB (used by Cairo)
# It would be nice to make this a subtype of AbstractRGB, but it doesn't have operations like c.r defined.
export RGB24
export ARGB32


end # module


