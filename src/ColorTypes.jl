VERSION >= v"0.4.0-dev+6521" && __precompile__()

module ColorTypes

using FixedPointNumbers, Compat
if VERSION < v"0.4.0-dev"
    using Docile
end

typealias Fractional Union(FloatingPoint, FixedPoint)
typealias U8 Ufixed8

if VERSION >= v"0.4.0-dev"
    @doc "`U8` is an abbreviation for the Ufixed8 type from FixedPointNumbers" -> U8
end

import Base: ==, convert, eltype, length, show, showcompact, one, zero

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

export RGB24, ARGB32, Gray24, AGray32

# Note: the parametric transparent Paints are exported
# algorithmically, see `@make_alpha` in types.jl.


## Functions
export basecolortype, basepainttype, ccolor, color, colorfields, colortype, eltype_default
export alphacolor, coloralpha
export alpha, red, green, blue, gray   # accessor functions that generalize to RGB24, etc.

include("types.jl")
include("traits.jl")
include("conversions.jl")
include("show.jl")

end # module

if VERSION < v"0.4.0-dev"
    using Docile
end

@doc """
ColorTypes summary (see individual types and functions for more detail):

Main type hierarchy:
```
                             Paint
             AbstractColor          Transparent
          Color   AbstractGray     AlphaColor  ColorAlpha
```

Concrete types:
- `RGB`, `BGR`, `RGB1`, `RGB4`, `RGB24` are all subtypes of `AbstractRGB`

- `HSV`, `HSL`, `HSI`, `XYZ`, `xyY`, `Lab`, `LCHab`, `Luv`, `LCHuv`,
  `DIN99`, `DIN99d`, `DIN99o`, `LMS`, `YIQ`, `YCbCR`

- Alpha-channel analogs such as `ARGB` and `RGBA` for most of those
  types (exceptions `RGB24`, which has `ARGB32`)

- Grayscale types `Gray` and `Gray24`

- Trait functions `eltype`, `length`, `alphacolor`, `coloralpha`,
  `colortype`, `basecolortype`, `basepainttype`, `ccolor`

- Getters `red`, `green`, `blue`, `alpha`, `gray`, `comp1`, `comp2`, `comp3`
""" -> ColorTypes
