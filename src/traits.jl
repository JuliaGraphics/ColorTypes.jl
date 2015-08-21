# Core traits and accessor functions

@doc """
`alpha(p)` extracts the alpha component of a color. For a color
without an alpha channel, it will always return 1.
""" ->
alpha(c::TransparentColor) = c.alpha
alpha(c::OpaqueColor) = one(eltype(c))
alpha(c::RGB24)   = Ufixed8(1)
alpha(c::ARGB32)  = Ufixed8((c.color & 0xff000000)>>24, 0)
alpha(c::AGray32) = Ufixed8((c.color & 0xff000000)>>24, 0)

@doc "`red(c)` returns the red component of an `AbstractRGB` opaque or transparent color." ->
red(c::AbstractRGB   ) = c.r
red(c::TransparentRGB) = c.r
red(c::RGB24)  = Ufixed8((c.color & 0x00ff0000)>>16, 0)
red(c::ARGB32) = Ufixed8((c.color & 0x00ff0000)>>16, 0)

@doc "`green(c)` returns the green component of an `AbstractRGB` opaque or transparent color." ->
green(c::AbstractRGB   ) = c.g
green(c::TransparentRGB) = c.g
green(c::RGB24)  = Ufixed8((c.color & 0x0000ff00)>>8, 0)
green(c::ARGB32) = Ufixed8((c.color & 0x0000ff00)>>8, 0)

@doc "`blue(c)` returns the blue component of an `AbstractRGB` opaque or transparent color." ->
blue(c::AbstractRGB   ) = c.b
blue(c::TransparentRGB) = c.b
blue(c::RGB24)  = Ufixed8(c.color & 0x000000ff, 0)
blue(c::ARGB32) = Ufixed8(c.color & 0x000000ff, 0)

@doc "`gray(c)` returns the gray component of a grayscale opaque or transparent color." ->
gray(c::Gray)    = c.val
gray(c::TransparentGray) = c.val
gray(c::Gray24)  = Ufixed8(c.color & 0x000000ff, 0)
gray(c::AGray32) = Ufixed8(c.color & 0x000000ff, 0)

# Extract the first, second, and third arguments as you'd
# pass them to the constructor
@doc """
`comp1(c)` extracts the first component you'd pass to the constructor
of the corresponding object.  For most color types without an alpha
channel, this is just the first field, but for types like `BGR` that
reverse the internal storage order this provides the value that you'd
use to reconstruct the color.

Specifically, for any `OpaqueColor{T,3}`,

    c == typeof(c)(comp1(c), comp2(c), comp3(c))

returns true.
""" ->
comp1(c::AbstractRGB) = red(c)
comp1{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = red(c)
comp1(c::Union(OpaqueColor,ColorAlpha)) = getfield(c, 1)
comp1(c::AlphaColor) = getfield(c, 2)

@doc "`comp2(c)` extracts the second constructor argument (see `comp1`)." ->
comp2(c::AbstractRGB) = green(c)
comp2{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = green(c)
comp2(c::Union(OpaqueColor,ColorAlpha)) = getfield(c, 2)
comp2(c::AlphaColor) = getfield(c, 3)

@doc "`comp3(c)` extracts the third constructor argument (see `comp1`)." ->
comp3(c::AbstractRGB) = blue(c)
comp3{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = blue(c)
comp3(c::Union(OpaqueColor,ColorAlpha)) = getfield(c, 3)
comp3(c::AlphaColor) = getfield(c, 4)

@doc "`opaquecolor(c)` extracts the opaque color component from a Color (e.g., omits the alpha channel, if present)." ->
opaquecolor(c::OpaqueColor) = c
opaquecolor{T}(c::Color{T,4}) = opaquetype(c)(comp1(c), comp2(c), comp3(c))
opaquecolor{T}(c::Color{T,2}) = opaquetype(c)(comp1(c))

# Generate the transparent analog of a color
alphacolor{C<:OpaqueColor}(c::C) = alphacolor(C)(c)
coloralpha{C<:OpaqueColor}(c::C) = coloralpha(C)(c)

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# recurse up the type hierarchy until you get to Color{T,N} for
# specific T,N.
to_top{T,N}(::Type{Color{T,N}}) = Color{T,N}
to_top{C<:Color}(::Type{C}) = to_top(super(C))

to_top(c::Color) = to_top(typeof(c))

# eltype(RGB{Float32}) -> Float32
eltype{T       }(::Type{Color{T}})   = T
eltype{T,N     }(::Type{Color{T,N}}) = T
eltype{C<:Color}(::Type{C}) = eltype(super(C))

eltype(c::Color) = eltype(typeof(c))

# Return the number of components in the color
# Note this is different from div(sizeof(c), sizeof(eltype(c))) (e.g., RGB1)
length{T,N}(::Type{Color{T,N}}) = N
length{N}(::Type{Color{TypeVar(:T),N}}) = N   # julia #12596
length{C<:Color}(::Type{C}) = length(super(C))

length(c::Color) = length(typeof(c))

@doc """
`opaquetype(c)` or `opaquetype(C)` (`c` being a color instance and `C`
being the type) returns the type of the OpaqueColor object (without
alpha channel).  This, and related functions like `baseopaquetype`,
`basecolortype`, and `ccolor` are useful for manipulating types for
writing generic code.

For example,

    opaquetype(RGB)          == RGB
    opaquetype(RGB{Float32}) == RGB{Float32}
    opaquetype(ARGB{U8})     == RGB{U8}
""" ->
opaquetype{C<:OpaqueColor}(::Type{C}) = C
opaquetype{C<:AlphaColor }(::Type{C}) = opaquetype(super(C))
opaquetype{C<:ColorAlpha }(::Type{C}) = opaquetype(super(C))
opaquetype{     }(::Type{TransparentColor})        = OpaqueColor
opaquetype{C    }(::Type{TransparentColor{C}})     = C
opaquetype{C,T  }(::Type{TransparentColor{C,T}})   = C
opaquetype{C,T,N}(::Type{TransparentColor{C,T,N}}) = C
opaquetype{C,N  }(::Type{TransparentColor{C,TypeVar(:T),N}}) = C

opaquetype(c::Color) = opaquetype(typeof(c))

@doc """
`baseopaquetype` is similar to `opaquetype`, except it "strips off" the
element type.  For example,

    opaquetype(RGB{U8})     == RGB{U8}
    baseopaquetype(RGB{U8}) == RGB

This can be very handy if you want to switch element types. For example:

    c64 = baseopaquetype(c){Float64}(color(c))

converts `c` into a `Float64` representation (potentially discarding
any alpha-channel information).
""" ->
baseopaquetype{C<:Color}(::Type{C}) = basecolortype(opaquetype(C))

baseopaquetype(c::Color) = baseopaquetype(typeof(c))

if VERSION < v"0.4.0-dev"
    basecolortype{C<:Color}(::Type{C}) = eval(C.name.name)  # slow, but oh well
else
    @eval @generated function basecolortype{C<:Color}(::Type{C})
        name = C.name.name
        :($name)
    end
end

@doc """
`basecolortype` is similar to `baseopaquetype`, but it preserves the
"alpha" portion of the type.

For example,

    baseopaquetype(ARGB{U8})  == RGB
    basecolortype(ARGB{U8})  == ARGB

If you just want to switch element types, this is the safest default
and the easiest to use:

    c64 = basecolortype(c){Float64}(c)
""" ->
basecolortype(c::Color) = basecolortype(typeof(c))

color_string{C<:Color}(::Type{C}) = string(C.name.name)

@doc """
 `ccolor` ("concrete color") helps write flexible methods. The idea is
that users may write `convert(HSV, c)` or even `convert(Array{HSV},
A)` without specifying the element type explicitly (e.g.,
`convert(HSV{Float32}, c)`). `ccolor` implements the logic "choose the
user's eltype if specified, otherwise retain the eltype of the source
object." However, when the source object has FixedPoint element type,
and the destination only supports FloatingPoint, we choose Float32.

Usage:

    ccolor(desttype, srctype) -> concrete desttype

Example:

    convert{C<:Color}(::Type{C}, p::Color) = cnvt(ccolor(C,typeof(p)), p)

where `cnvt` is the function that performs explicit conversion.
""" ->
ccolor{   Csrc<:Color}(::Type{Color   }, ::Type{Csrc}) = Csrc
ccolor{T, Csrc<:Color}(::Type{Color{T}}, ::Type{Csrc}) = basecolortype(Csrc){T}
ccolor{   Csrc<:Color}(::Type{OpaqueColor   }, ::Type{Csrc}) = opaquetype(Csrc)
ccolor{T, Csrc<:Color}(::Type{OpaqueColor{T}}, ::Type{Csrc}) = baseopaquetype(Csrc){T}

ccolor{Csrc<:OpaqueColor}(::Type{TransparentColor}, ::Type{Csrc}) =
          error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor{C<:OpaqueColor,    Csrc<:OpaqueColor}(
       ::Type{TransparentColor{C    }}, ::Type{Csrc}) =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor{C<:OpaqueColor,T,  Csrc<:OpaqueColor}(
       ::Type{TransparentColor{C,T  }}, ::Type{Csrc}) =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor{C<:OpaqueColor,T,N,Csrc<:OpaqueColor}(
       ::Type{TransparentColor{C,T,N}}, ::Type{Csrc}) =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")

ccolor{Csrc<:TransparentColor}(::Type{TransparentColor}, ::Type{Csrc}) = Csrc

ccolor{Csrc<:Color}(::Type{AlphaColor}, ::Type{Csrc}) = alphacolor(Csrc)
ccolor{C<:OpaqueColor,    Csrc<:Color}(
       ::Type{AlphaColor{C    }}, ::Type{Csrc}) = ccolor(alphacolor(C), Csrc)
ccolor{C<:OpaqueColor,T,  Csrc<:Color}(
       ::Type{AlphaColor{C,T  }}, ::Type{Csrc}) = ccolor(alphacolor(C){T}, Csrc)
ccolor{C<:OpaqueColor,T,N,Csrc<:Color}(
       ::Type{AlphaColor{C,T,N}}, ::Type{Csrc}) = ccolor(alphacolor(C){T}, Csrc)

ccolor{Csrc<:Color}(::Type{ColorAlpha}, ::Type{Csrc}) = coloralpha(Csrc)
ccolor{C<:OpaqueColor,    Csrc<:Color}(
       ::Type{ColorAlpha{C    }}, ::Type{Csrc}) = ccolor(coloralpha(C), Csrc)
ccolor{C<:OpaqueColor,T,  Csrc<:Color}(
       ::Type{ColorAlpha{C,T  }}, ::Type{Csrc}) = ccolor(coloralpha(C){T}, Csrc)
ccolor{C<:OpaqueColor,T,N,Csrc<:Color}(
       ::Type{ColorAlpha{C,T,N}}, ::Type{Csrc}) = ccolor(coloralpha(C){T}, Csrc)

ccolor{  Csrc<:AbstractRGB}(::Type{AbstractRGB},    ::Type{Csrc}) = Csrc
ccolor{T,Csrc<:AbstractRGB}(::Type{AbstractRGB{T}}, ::Type{Csrc}) = basecolortype(Csrc){T}

# Concrete types
ccolor{Cdest<:Color,Csrc<:Color}(::Type{Cdest}, ::Type{Csrc}) = basecolortype(Cdest){pick_eltype(opaquetype(Cdest), eltype(Cdest), eltype(Csrc))}
ccolor{Csrc<:Color}(::Type{RGB24},   ::Type{Csrc}) = RGB24
ccolor{Csrc<:Color}(::Type{ARGB32},  ::Type{Csrc}) = ARGB32
ccolor{Csrc<:Color}(::Type{Gray24},  ::Type{Csrc}) = Gray24
ccolor{Csrc<:Color}(::Type{AGray32}, ::Type{Csrc}) = AGray32

pick_eltype{C,T1<:Number,T2            }(::Type{C}, ::Type{T1}, ::Type{T2}) = T1
pick_eltype{C,T1<:Number,T2<:FixedPoint}(::Type{C}, ::Type{T1}, ::Type{T2}) = T1
pick_eltype{C,T2            }(::Type{C}, ::Any, ::Type{T2})     = T2
pick_eltype{C,T2<:FixedPoint}(::Type{C}, ::Any, ::Type{T2})     = pick_eltype_compat(C, eltype_default(C), T2)
# When T2 <: FixedPoint, choosed based on whether color type supports it
pick_eltype_compat{T1            ,T2}(::Any, ::Type{T1}, ::Type{T2}) = T1
pick_eltype_compat{T1<:FixedPoint,T2}(::Any, ::Type{T1}, ::Type{T2}) = T2



### Equality
==(c1::AbstractRGB, c2::AbstractRGB) = red(c1) == red(c2) && green(c1) == green(c2) && blue(c1) == blue(c2)

for T in (RGB24, ARGB32, Gray24, AGray32)
    @eval begin
        ==(x::Uint32, y::$T) = x == convert(Uint32, y)
        ==(x::$T, y::Uint32) = ==(y, x)
    end
end
==(x::Gray, y::Gray) = x.val == y.val
==(x::Number, y::Gray) = x == y.val
==(x::Gray, y::Number) = ==(y, x)

zero{T}(::Type{Gray{T}}) = Gray{T}(zero(T))
 one{T}(::Type{Gray{T}}) = Gray{T}(one(T))
