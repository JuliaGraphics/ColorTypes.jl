module ColorTypes

using FixedPointNumbers
import FixedPointNumbers: floattype
using Base: @pure

const Fractional = Union{AbstractFloat, FixedPoint}

import Base: ==, <, isless, isapprox, isfinite, isinf, isnan, oneunit, zero,
             hash, eltype, length, real, convert, reinterpret, show
using Random
import Random: rand

## Types
export Fractional

export Colorant
export Color, TransparentColor, AlphaColor, ColorAlpha, AbstractRGB
export AbstractGray, Color3, TransparentGray, Transparent3, TransparentRGB, ColorantNormed
export AbstractAGray, AbstractGrayA, AbstractARGB, AbstractRGBA

export RGB, BGR, XRGB, RGBX
export HSV, HSB, HSL, HSI
export XYZ, xyY, LMS, Lab, LCHab, Luv, LCHuv
export DIN99, DIN99d, DIN99o
export YIQ, YCbCr

export Gray

export RGB24, ARGB32, Gray24, AGray32

# Note: the parametric TransparentColorColors are exported
# algorithmically, see `@make_alpha` in types.jl.


## Functions
export base_color_type, base_colorant_type, ccolor, color, color_type, parametric_colorant
export alphacolor, coloralpha
export alpha, red, green, blue, gray   # accessor functions that generalize to RGB24, etc.
export chroma, hue
export comp1, comp2, comp3, comp4, comp5
export mapc, reducec, mapreducec, gamutmax, gamutmin

include("types.jl")
include("traits.jl")
include("conversions.jl")
include("show.jl")
include("operations.jl")
include("error_hints.jl")

Base.@deprecate_binding RGB1 XRGB
Base.@deprecate_binding RGB4 RGBX

"""
ColorTypes summary:

Type hierarchy:
```
                          Colorant{T,N}
             Color{T,N}                    TransparentColor{C,T,N}
     AbstractRGB{T}                  AlphaColor{C,T,N}  ColorAlpha{C,T,N}
```

Concrete types:
- `RGB`, `BGR`, `XRGB`, `RGBX`, `RGB24` are all subtypes of `AbstractRGB`

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

if VERSION >= v"1.4.2" # work around https://github.com/JuliaLang/julia/issues/34121
    # ...and also requires https://github.com/JuliaLang/julia/pull/35378
    # Disabled for now, see https://github.com/JuliaGraphics/ColorTypes.jl/issues/269
    #include("precompile.jl")
    #_precompile_()
end

__init__() = register_hints()

end # module
