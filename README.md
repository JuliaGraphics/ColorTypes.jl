# ColorTypes

[![Build Status](https://github.com/JuliaGraphics/ColorTypes.jl/workflows/Unit%20test/badge.svg)](https://github.com/JuliaGraphics/ColorTypes.jl/actions)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/C/ColorTypes.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
[![codecov.io](http://codecov.io/github/JuliaGraphics/ColorTypes.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphics/ColorTypes.jl?branch=master)

This "minimalistic" package serves as the foundation for working with
colors in Julia.  It defines basic color types and their constructors,
and sets up traits and `show` methods to make them easier to work
with.

Of related interest is the [Colors.jl](https://github.com/JuliaGraphics/Colors.jl) package, which provides
"colorimetry" and conversion functions for working with colors.  You
may also be interested in the [ColorVectorSpace.jl](https://github.com/JuliaGraphics/ColorVectorSpace.jl) package, which
defines mathematical operations for certain color types.  Both of
these packages are based on ColorTypes, which ensures that any color
objects will be broadly usable.

# Types available in ColorTypes

## The type hierarchy and abstract types

Here is the type hierarchy used in ColorTypes:
**TODO: Update figure**
![Types](images/types.svg?sanitize=true "Types")

- `Colorant` is the general term used for any object exported by this
  package.  True colors are called `Color`; `TransparentColor`
  indicates an object that also has alpha-channel information.

- `Color{T,3}` is a 3-component color (like RGB = red, green, blue).

- `AbstractGray{T}` is a typical subtype of `Color{T,1}`.
  In fact, it was a typealias for `Color{T,1}` in v0.11 or earlier.

- Most colors have both `AlphaColor` and `ColorAlpha` variants;
  for example, `RGB` has both `ARGB` and `RGBA`.  These indicate
  different underlying storage in memory: `AlphaColor` stores the
  alpha-channel first, then the color, whereas `ColorAlpha` stores the
  color first, then the alpha-channel.  Storage order can be
  particularly important for interfacing with certain external
  libraries (e.g., OpenGL and Cairo).

- To support generic programming, `TransparentColor` constructors
  always take the alpha channel last, independent of their internal
  storage order. That is, one uses
  ```julia
  RGBA(red, green, blue, alpha)
  ARGB(red, green, blue, alpha) # note alpha is last
  RGBA(RGB(red, green, blue), alpha)
  ARGB(RGB(red, green, blue), alpha)
  ```
  This way you can write code with a generic `C<:Colorant` type and
  not worry about the proper order for supplying arguments to the
  constructor.  See the [traits section](#traits) for some useful
  utilities.

## Colors

### RGB plus BGR, XRGB, RGBX, and RGB24: the AbstractRGB group

The [RGB (Red-Green-Blue) colorspace](https://en.wikipedia.org/wiki/RGB_color_model).
By default, it is interpreted as the [sRGB colorspace](https://en.wikipedia.org/wiki/SRGB).

```julia
struct RGB{T} <: AbstractRGB{T}
    r::T # Red in [0,1]
    g::T # Green in [0,1]
    b::T # Blue in [0,1]
end
```

RGBs may be defined with two broad number types: `AbstractFloat` and
`FixedPoint`.  `FixedPoint` types come from the
[`FixedPointNumbers`](https://github.com/JuliaMath/FixedPointNumbers.jl)
package, and essentially reinterpret "integers" (meaning, the bit-sequences used to represent
machine integers) as fractional numbers.
For example, `N0f8(1)` creates a `Normed{UInt8,8}`
(`N0f8` for short) number with value equal to `1.0` but which
is represented internally with the same bit sequence as `0xff` (which is numerically equal to 255).
This strategy ensures that `1` always means
"saturated color", regardless of whether that value is represented as a `Float64` or with just 8 bits.
(In the context of image-processing, this unifies "integer images" and
"floating-point images" in a common scale.)
A bright red color is created with `RGB(1, 0, 0)`, a pale pink with `RGB(1, 0.7, 0.7)`
or its 24-bit variant `RGB{N0f8}(1, 0.7, 0.7)`,
and `RGB(255, 0, 0)` throws an error.

The analogous `BGR` type is defined as

```julia
struct BGR{T} <: AbstractRGB{T}
    b::T
    g::T
    r::T
end
```

i.e., identical to `RGB` except in the opposite storage order.  One
crucial point: **for all `AbstractRGB` types, the constructor
accepts values in the order `(r,g,b)` regardless of how they
are arranged internally in memory**.

`XRGB` and `RGBX` seem exactly like `RGB`, but internally they insert
one extra ("invisible") padding element; when the element type is
`N0f8`, these have favorable memory alignment for interfacing with
libraries like OpenGL.

Finally, one may encode an RGB or ARGB color as 8-bit values packed into a
32-bit integer:

```julia
struct RGB24 <: AbstractRGB{N0f8}
    color::UInt32
end

struct ARGB32 <: AbstractARGB{N0f8}
    color::UInt32
end
```

The storage order is `0xAARRGGBB`, where `RR` means the red channel, `GG` means
the green, and `BB` means the blue.
`AA` means the alpha and is ignored for `RGB24`.
Note that on little-endian machines, contrary to the names, they are stored in
memory in BGRA order.

These types can be constructed as `RGB24(1.0, 0.5, 0.0)`, not as
`RGB24(0xff, 0x80, 0x00)` (for an orange `#ff8000`).
However, since these types have no fields named `r`, `g`, `b`, it is better to
extract values from an `AbstractRGB`/`TransparentRGB` object `c` using `red(c)`,
`green(c)`, `blue(c)`.


### HSV

[Hue-Saturation-Value](https://en.wikipedia.org/wiki/HSL_and_HSV).
A common projection of RGB to cylindrical coordinates.
This is also sometimes called "HSB" for Hue-Saturation-Brightness.

```julia
struct HSV{T} <: Color{T,3}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    v::T # Value in [0,1]
end
```

For HSV (and all remaining color types), `T` must be of `AbstractFloat` type.
Due to [rounding errors](https://docs.julialang.org/en/v1/base/math/#Base.mod)
in floating point arithmetic, `360` should also be handled as a valid hue.

### HSL

[Hue-Saturation-Lightness](https://en.wikipedia.org/wiki/HSL_and_HSV).
Another common projection of RGB to cylindrical coordinates.

```julia
struct HSL{T} <: Color{T,3}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    l::T # Lightness in [0,1]
end
```

### HSI

Hue-Saturation-Intensity. A variation of HSL and HSV commonly used in computer
vision.

```julia
struct HSI{T} <: Color{T,3}
    h::T # Hue in [0,360]
    s::T # Saturation in [0,1]
    i::T # Intensity in [0,1]
end
```

### XYZ

The [XYZ colorspace](https://en.wikipedia.org/wiki/CIE_1931_color_space)
standardized by the CIE in 1931, based on experimental measurements of
color perception culminating in the CIE standard observer (see
`Colors.jl`'s `cie_color_match` function).

```julia
struct XYZ{T} <: Color{T,3}
    x::T
    y::T
    z::T
end
```

The scale normalized by the maximum value of Y to `1` is used by default;
the white in the illuminant E is represented by `XYZ(1, 1, 1)`.
Note that some tools may use the component values multiplied by `100`.
Also, `XYZ` may be used to describe absolute luminance (e.g. in cd/m^2).
Be careful not to confuse different units.

This colorspace is noteworthy because it is linear---values may be
added or scaled as if they form a vector space.  See further
discussion in the ColorVectorSpace.jl package.

### xyY

The xyY colorspace is another CIE standardized color space, based
directly off of a transformation from XYZ. It was developed
specifically because the xy chromaticity space is invariant to the
lightness of the patch.

```julia
struct xyY{T} <: Color{T,3}
    x::T
    y::T
    Y::T
end
```

### Lab

The Lab perceptually uniform colorspace.
By default, it is interpreted as the [L\*a\*b\*](https://en.wikipedia.org/wiki/CIELAB_color_space),
standardized by the CIE in 1976.

```julia
struct Lab{T} <: Color{T,3}
    l::T # Lightness in [0,100]
    a::T # Red/Green
    b::T # Blue/Yellow
end
```

Note that some tools may use the component values divided by `100`.

L\*a\*b\* is calculated relative to a reference white point.
By default, the illuminant D65, which is also used in sRGB, is applied.
On the other hand, D50 is often used for printed materials and color management.

### Luv

The [L\*u\*v\*](https://en.wikipedia.org/wiki/CIELUV), which is a perceptually
uniform colorspace standardized by the CIE in 1976.
See also Lab (L\*a\*b\*), a similar colorspace standardized the same year.

```julia
struct Luv{T} <: Color{T,3}
    l::T # Lightness in [0,100]
    u::T # Red/Green
    v::T # Blue/Yellow
end
```

L\*u\*v\* is calculated relative to a reference white point.
By default, the illuminant D65 is applied.

### LCHab and LCHuv

The Lab/Luv colorspace reparameterized using cylindrical coordinates.

```julia
struct LCHab{T} <: Color{T,3}
    l::T # Lightness in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end

struct LCHuv{T} <: Color{T,3}
    l::T # Lightness in [0,100]
    c::T # Chroma
    h::T # Hue in [0,360]
end
```


### DIN99

The DIN99 uniform colorspace as described in the DIN 6176 specification.

```julia
struct DIN99{T} <: Color{T,3}
    l::T # L99 (Lightness)
    a::T # a99 (Red/Green)
    b::T # b99 (Blue/Yellow)
end
```


### DIN99d and DIN99o

The DIN99d and DIN99o are revised version of the DIN99.
These colorspaces are mainly used to calculate color differences.

```julia
struct DIN99d{T} <: Color{T,3}
    l::T # L99d (Lightness)
    a::T # a99d (Red/Green)
    b::T # b99d (Blue/Yellow)
end

struct DIN99o{T} <: Color{T,3}
    l::T # L99o (Lightness)
    a::T # a99o (Red/Green)
    b::T # b99o (Blue/Yellow)
end
```


### LMS

Long-Medium-Short cone response values.
Multiple methods of converting to LMS space have been defined.
By default, the [CAT02](https://en.wikipedia.org/wiki/CIECAM02#CAT02) chromatic
adaptation matrix is used in Colors.jl.

```julia
struct LMS{T} <: Color{T,3}
    l::T # Long
    m::T # Medium
    s::T # Short
end
```

Like `XYZ`, `LMS` is a linear color space.

### YIQ

The colorspace derived from the transform matrix used by the
[NTSC](https://en.wikipedia.org/wiki/NTSC) color TV system.
This [YIQ](https://en.wikipedia.org/wiki/YIQ) colorspace is used for convenience
in image processing and is not compatible with the NTSC 1953 specification or
the SMPTE 170M specification.

```julia
struct YIQ{T} <: Color{T,3}
    y::T # Luma in [0,1]
    i::T # Chroma (Orange/Blue) in [-0.5959,0.5959]
    q::T # Chroma (Purple/Green) in [-0.5227,0.5227]
end
```

### Y'CbCr **TODO: describe the default colorspace and scaling**

A color-encoding format common in video and digital photography.

```julia
struct YCbCr{T} <: Color{T,3}
    y::T
    cb::T
    cr::T
end
```

## Grayscale "colors"

### Gray

`Gray` is a simple wrapper around a real number, where `0` means black and `1`
means white.

```julia
struct Gray{T} <: AbstractGray{T}
    val::T
end
```

By default, this colorspace is defined by the relationship to RGB:
`RGB(Gray(g)) == RGB(g, g, g)`.
That is, it has the same tone response curve (gamma) as sRGB by default.
Also, for sRGB to grayscale conversion, the coefficients of the
[ITU-R BT.601 (Rec.601)](https://en.wikipedia.org/wiki/Rec._601) are used by
default, but the color primaries and gamma are different from Rec.601.


In many situations you don't need a `Gray` wrapper, but there are
times when it can be helpful to clarify meaning or assist with
dispatching to appropriate methods.  It is also present for
consistency with the two corresponding grayscale-plus-transparency
types, `AGray` and `GrayA`.

### Gray24 and AGray32

`Gray24` is a grayscale value encoded as a `UInt32`:
```julia
struct Gray24 <: AbstractGray{N0f8}
    color::UInt32
end
```

The storage format is `0xAAIIIIII`, where each `II` (intensity) pair
must be identical.  The `AA` is ignored, but in the corresponding
`AGray32` type it encodes alpha.

## Color gamuts and ranges of components

The [color gamut](https://en.wikipedia.org/wiki/Gamut) is often used to indicate
the colors that can be accurately represented in a particular colorspace.
However, there may be multiple colorspaces with different color gamuts, even
for the same color model.
For example, there are various standards for the RGB color model, such as sRGB,
[DCI-P3](https://en.wikipedia.org/wiki/DCI-P3),
[ProPhoto RGB](https://en.wikipedia.org/wiki/ProPhoto_RGB_color_space),
[Rec.2020](https://en.wikipedia.org/wiki/Rec._2020), and so on.
Because of the wide variations, ColorTypes.jl does not provide the way to
distinguish them within the type system.

For convenience and interoperability, ColorTypes.jl defines the default
colorspace for each types, and Colors.jl implements the default colorspace
conversions.
However, note that it is the responsibility of the downstream packages or users
to manage the characteristics (profiles) of the colors used.

Since ColorTypes.jl does not necessarily know the valid gamut, and since it is
useful to store out-of-gamut colors as intermediate representations, the color
constructors defined in ColorTypes.jl do not check whether the arguments are
in-gamut or out-of-gamut.
On the other hand, the color constructors may know the range of the numeric
type used to represent the components.
Thus, for example, `RGB{N0f8}(2, 0, 0)` will show an error message, but
`RGB{N1f15}(2, 0, 0)` will not throw an error.

## <a name="traits"></a>Traits (utility functions for instances and types)

One of the nicest things about this package is that it provides a rich
set of trait-functions for working with color types:

- `eltype(c)` extracts the underlying element type, e.g., `Float32`

- `length(c)` extracts the number of components (including `alpha`, if present)

- `alphacolor(c)` and `coloralpha(c)` convert a `Color` to an object
  with transparency (either `ARGB` or `RGBA`, respectively).

- `color_type(c)` extracts the opaque (color-only) type of the object (e.g.,
  `RGB{N0f8}` from an object of type `ARGB{N0f8}`).

- `base_color_type(c)` and `base_colorant_type(c)` extract type
  information and discard the element type (e.g.,
  `base_colorant_type(ARGB{N0f8})` yields `ARGB`)

- `ccolor(Cdest, Csrc)` helps pick a concrete element type for methods
  where the output may be left unstated, e.g., `convert(RGB, c)`
  rather than `convert(RGB{N0f8}, c)`.

All of these methods are individually documented (typically with
greater detail); just type `?ccolor` at the REPL.

### Getters

- `red`, `green`, `blue` extract channels from `AbstractRGB` types;
  `gray` extracts the intensity from a grayscale object

- `alpha` extracts the alpha channel from any `Colorant` object
  (returning 1 if there is no alpha channel)

- `comp1`, `comp2`, `comp3`, `comp4` and `comp5` extract color components in the
  order expected by the constructor

- `hue` extracts the hue from an `HSV`-like or `Lab`-like object

- `chroma` extracts the chroma (not the saturation) from a `Lab`-like object

### Functions

- `mapc(f, c)` executes the function `f` on each color channel of `c`,
  returning a new color in the same colorspace.

- `reducec(op, v0, c)` returns a single number based on a binary
  operator `op` across the color channels of `c`. `v0` is the initial
  value.

- `mapreducec(f, op, v0, c)` is similar to `reducec` except it applies
  `f` to each color channel before combining values with `op`.

## Extending ColorTypes and Colors

In most cases, adding a new color space is quite straightforward:

- Add your new type to [`types.jl`](src/types.jl), following the model of the other color types;
- Add the type to the list of exports in [`ColorTypes.jl`](src/ColorTypes.jl);
- In the Colors package, add [conversions](https://github.com/JuliaGraphics/Colors.jl/blob/master/src/conversions.jl) to and from your new colorspace.

In special cases, there may be other considerations:
- For `AbstractRGB`/`AbstractGray` types, `0` means "black" and `1` means
  "saturated."
- If your type has extra fields, check the "Generated code" section of `types.jl` carefully. You may need to define a `colorfields` function and/or call `@make_constructors` or `@make_alpha` manually.
