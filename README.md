# ColorTypes

[![Build Status](https://travis-ci.org/SimonDanisch/ColorTypes.jl.svg?branch=master)](https://travis-ci.org/SimonDanisch/ColorTypes.jl)
[![Coverage Status](https://coveralls.io/repos/SimonDanisch/ColorTypes.jl/badge.svg)](https://coveralls.io/r/SimonDanisch/ColorTypes.jl)

This "minimalistic" package serves as the foundation for working with
colors in Julia.  It defines basic color types and their constructors,
and sets up traits and `show` methods to make them easier to work
with.

Of related interest is the [Colors.jl]() package, which provides
"colorimetry" and conversion functions for working with colors.  You
may also be interested in the [ColorVectorSpace.jl]() package, which
defines mathematical operations for certain color types.  Both of
these packages are based on ColorTypes, which ensures that any color
objects will be broadly usable.

# Types available in ColorTypes

## The type hierarchy and abstract types

Here is the type hierarchy used in ColorTypes:

![Types](images/types.png "Types")

- `Transparent` indicates an object with alpha-channel information;
  `AbstractColor` means that it has no alpha-channel.  `Paint` is the
  general term used for any object exported by this package.

- `Color` is a 3-component color (like RGB = red, green, blue);
  `AbstractGray` is a 1-component "color" (e.g., grayscale).

- Most colors have both `AlphaColor` and `ColorAlpha` variants; for
  example, `RGB` has both `ARGB` and `RGBA`.  These indicate different
  underlying storage in memory: `AlphaColor` stores the alpha-channel
  first, then the color, whereas `ColorAlpha` stores the color first,
  then the alpha-channel.  Storage order can be particularly important
  for interfacing with certain external libraries (e.g., OpenGL and
  Cairo).

## Colors

### RGB (plus BGR, RGB1, and RGB4)

The [sRGB colorspace](https://en.wikipedia.org/wiki/SRGB).

```jl
immutable RGB{T} <: AbstractRGB{T}
    r::T # Red in [0,1]
    g::T # Green in [0,1]
    b::T # Blue in [0,1]
end
```

RGBs may be defined with two broad number types: `FloatingPoint` and
`FixedPoint`.  `FixedPoint` come from the
[`FixedPointNumbers`](https://github.com/JeffBezanson/FixedPointNumbers.jl)
package, and represent fractional numbers (between 0 and 1, inclusive)
internally using integers.  For example, `0xffuf8` creates a `Ufixed8`
(`U8` for short) number with value equal to `1.0` but which internally
is represented as `0xff`.  This strategy ensures that `1` always means
"saturated color", regardless of how that value is represented.
Ordinary integers should not be used, although the convenience
constructor `RGB(1,0,0)` will create a value `RGB{U8}(1.0, 0.0, 0.0)`.

The `BGR` type is defined as

```jl
immutable BGR{T} <: AbstractRGB{T}
    b::T
    g::T
    r::T
end
```

i.e., identical to `RGB` except in the opposite storage order.  One
crucial point: **for all `AbstractRGB` types, the constructor
accepts values in the order `(r,g,b)` regardless of how they
are arranged internally in memory**.

`RGB1` and `RGB4` seem exactly like `RGB`, but internally they insert
one extra ("invisible") padding element; when the element type is
`U8`, these have favorable memory alignment for interfacing with
libraries like OpenGL.


### HSV

[Hue-Saturation-Value](https://en.wikipedia.org/wiki/HSL_and_HSV). A
common projection of RGB to cylindrical coordinates.  This is also
sometimes called "HSB" for Hue-Saturation-Brightness.

```julia
immutable HSV{T} <: Color{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end
```

For HSV (and all remaining color types), `T` must be of
`FloatingPoint` type, since the values range beyond what can be
represented with most `FixedPoint` types.

### HSL

[Hue-Saturation-Lightness](https://en.wikipedia.org/wiki/HSL_and_HSV). Another
common projection of RGB to cylindrical coordinates.

```julia
immutable HSL{T} <: Color{T}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end
```

### HSI

Hue, saturation, intensity, a variation of HSL and HSV commonly used
in computer vision.

```jl
immutable HSI{T} <: Color{T}
    h::T
    s::T
    i::T
end
```

### XYZ

The [XYZ colorspace](https://en.wikipedia.org/wiki/CIE_1931_color_space)
standardized by the CIE in 1931, based on experimental measurements of
color perception culminating in the CIE standard observer (see
`Colors.jl`'s `cie_color_match` function).

```julia
immutable XYZ{T} <: Color{T}
    x::T
    y::T
    z::T
end
```

This colorspace is noteworthy because it is linear---values may be
added or scaled as if they form a vector space.  See further
discussion in the ColorVectorSpace.jl package.

### xyY

The xyY colorspace is another CIE standardized color space, based
directly off of a transformation from XYZ. It was developed
specifically because the xy chromaticity space is invariant to the
lightness of the patch.

```julia
immutable xyY{T} <: Color{T}
    x::T
    y::T
    Y::T
end
```

### LAB

A perceptually uniform colorpsace standardized by the CIE in 1976. See
also LUV, the associated colorspace standardized the same year.

```julia
immutable LAB{T} <: Color{T}
    l::T # Luminance in approximately [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end
```

### LUV

A perceptually uniform colorpsace standardized by the CIE in 1976. See
also LAB, a similar colorspace standardized the same year.

```julia
immutable LUV{T} <: Color{T}
    l::T # Luminance
    u::T # Red/Green
    v::T # Blue/Yellow
end
```


### LCHab

The LAB colorspace reparameterized using cylindrical coordinates.

```julia
immutable LCHab{T} <: Color{T}
    l::T # Luminance in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end
```


### LCHuv

The LUV colorspace reparameterized using cylindrical coordinates.

```julia
immutable LCHuv{T} <: Color{T}
    l::T # Luminance
    c::T # Chroma
    h::T # Hue
end
```


### DIN99

The DIN99 uniform colorspace as described in the DIN 6176 specification.

```julia
immutable DIN99{T} <: Color{T}
    l::T # L99 (Lightness)
    a::T # a99 (Red/Green)
    b::T # b99 (Blue/Yellow)
end
```


### DIN99d

The DIN99d uniform colorspace is an improvement on the DIN99 color
space that adds a correction to the X tristimulus value in order to
emulate the rotation term present in the DeltaE2000 equation.

```julia
immutable DIN99d{T} <: Color{T}
    l::T # L99d (Lightness)
    a::T # a99d (Reddish/Greenish)
    b::T # b99d (Bluish/Yellowish)
end
```


### DIN99o

Revised version of the DIN99 uniform colorspace with modified
coefficients for an improved metric.  Similar to DIN99d X correction
and the DeltaE2000 rotation term, DIN99o achieves comparable results
by optimized `a*/b*` rotation and chroma compression terms.

```julia
immutable DIN99o{T} <: Color{T}
    l::T # L99o (Lightness)
    a::T # a99o (Red/Green)
    b::T # b99o (Blue/Yellow)
end
```


### LMS

Long-Medium-Short cone response values. Multiple methods of converting
to LMS space have been defined. Here the
[CAT02](https://en.wikipedia.org/wiki/CIECAM02#CAT02) chromatic
adaptation matrix is used.

```
immutable LMS{T} <: Color{T}
    l::T # Long
    m::T # Medium
    s::T # Short
end
```

### RGB24

An RGB color represented as 8-bit values packed into a 32-bit integer.

```julia
immutable RGB24 <: Color{U8}
    color::UInt32
end
```

### YIQ (NTSC)

A color-encoding format used by the NTSC broadcast standard.

```julia
immutable YIQ{T} <: Color{T}
    y::T
    i::T
    q::T
end
```

### Y'CbCr

A color-encoding format common in video and digital photography.

```jl
immutable YCbCr{T} <: Color{T}
    y::T
    cb::T
    cr::T
end
```
