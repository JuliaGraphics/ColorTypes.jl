module ColorTypes

using FixedPointNumbers, Compat

typealias Fractional Union(FloatingPoint, FixedPoint)
typealias U8 Ufixed8

import Base: ==, convert, eltype, typemax, typemin

## Types
export Fractional, U8
export Paint
export AbstractColor, Color, AbstractRGB, AbstractGray
export Transparent, AlphaColor, ColorAlpha

export RGB, BGR, RGB1, RGB4
export HSV, HSB, HSL, HSI
export XYZ, xyY, LMS, Lab, LCHab, Luv, LCHuv
export DIN99, DIN99d, DIN99o
export YIQ, YCbCr

export Gray

export RGB24, ARGB32

# Note: the parametric transparent Paints are exported
# algorithmically, see `@make_alpha` in types.jl.


## Functions
export basecolortype, basepainttype, ccolor, color, colorfields, colortype, eltype_default
export alphacolor, coloralpha
export alpha, blue, green, red

include("types.jl")
include("traits.jl")
include("show.jl")

end # module
