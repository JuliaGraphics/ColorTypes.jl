module ColorTypes

using FixedPointNumbers

typealias Fractional Union(FloatingPoint, FixedPoint)
typealias U8 Ufixed8

import Base: convert, eltype, typemax, typemin

## Types
export Fractional, U8
export Paint
export AbstractColor, Color, AbstractRGB, AbstractGray
export Transparent, AbstractAlphaColor, AbstractColorAlpha

export RGB, BGR, RGB1, RGB4, RGB24
export HSV, HSB, HSL
export XYZ, xyY, LMS, Lab, LCHab, Luv, LCHuv
export DIN99, DIN99d, DIN99o
export YIQ, YCbCr, HSI

export Gray

export AlphaColor, ColorAlpha

export ARGB32
export GrayAlpha, AlphaGray
# Note: the rest of the transparent Paints are exported
# algorithmically, see `@eval` statements in types.jl.

## Functions
export basecolortype, basepainttype, ccolor, colortype

include("types.jl")
include("traits.jl")

end # module
