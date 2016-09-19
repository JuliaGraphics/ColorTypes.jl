__precompile__()

module ColorTypes

using FixedPointNumbers
if VERSION >= v"0.5.0-dev+755"
    using Base.@pure
else
    macro pure(ex)
        esc(ex)
    end
end

typealias Fractional Union{AbstractFloat, FixedPoint}
typealias U8 UFixed8
typealias U16 UFixed16

"`U8` is an abbreviation for the UFixed8 type from FixedPointNumbers" U8

"`U16` is an abbreviation for the UFixed16 type from FixedPointNumbers" U16

import Base: ==, convert, eltype, length, show, showcompact, one, zero

## Types
export Fractional, U8, U16

export Colorant
export Color, TransparentColor, AlphaColor, ColorAlpha, AbstractRGB

export RGB, BGR, RGB1, RGB4
export HSV, HSB, HSL, HSI
export XYZ, xyY, LMS, Lab, LCHab, Luv, LCHuv
export DIN99, DIN99d, DIN99o
export YIQ, YCbCr

export Gray

export RGB24, ARGB32, Gray24, AGray32

# Note: the parametric TransparentColorColors are exported
# algorithmically, see `@make_alpha` in types.jl.


## Functions
export base_color_type, base_colorant_type, ccolor, color, color_type
export alphacolor, coloralpha
export alpha, red, green, blue, gray   # accessor functions that generalize to RGB24, etc.
export comp1, comp2, comp3
export mapc

if VERSION < v"0.5.0-dev+1946"
    const supertype = super
    export supertype
end

include("types.jl")
include("traits.jl")
include("conversions.jl")
include("show.jl")
include("operations.jl")

"""
ColorTypes summary:

Type hierarchy:
```
                          Colorant{T,N}
             Color{T,N}                    TransparentColor{C,T,N}
     AbstractRGB{T}                  AlphaColor{C,T,N}  ColorAlpha{C,T,N}
```

Concrete types:
- `RGB`, `BGR`, `RGB1`, `RGB4`, `RGB24` are all subtypes of `AbstractRGB`

- `HSV`, `HSL`, `HSI`, `XYZ`, `xyY`, `Lab`, `LCHab`, `Luv`, `LCHuv`,
  `DIN99`, `DIN99d`, `DIN99o`, `LMS`, `YIQ`, `YCbCR` are subtypes of
  `Color{T,3}`

- Alpha-channel analogs in such as `ARGB` and `RGBA` for most of those
  types (with a few exceptions like `RGB24`, which has `ARGB32`)

- Grayscale types `Gray` and `Gray24` (subtypes of `Color{T,1}`), and
  the corresponding transparent types `AGray`, `GrayA`, and `AGray32`

- Trait functions `eltype`, `length`, `alphacolor`, `coloralpha`,
  `color_type`, `base_color_type`, `base_colorant_type`, `ccolor`

- Getters `red`, `green`, `blue`, `alpha`, `gray`, `comp1`, `comp2`, `comp3`

Use `?` to get more information about specific types or functions.
""" ColorTypes

end # module
