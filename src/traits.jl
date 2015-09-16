# Core traits and accessor functions

@doc """
`alpha(p)` extracts the alpha component of a color. For a color
without an alpha channel, it will always return 1.
""" ->
alpha(c::TransparentColor) = c.alpha
alpha(c::Color)   = one(eltype(c))
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

Specifically, for any `Color{T,3}`,

    c == typeof(c)(comp1(c), comp2(c), comp3(c))

returns true.
""" ->
comp1(c::AbstractRGB) = red(c)
comp1{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = red(c)
comp1(c::Union(Color,ColorAlpha)) = getfield(c, 1)
comp1(c::AlphaColor) = getfield(c, 2)

@doc "`comp2(c)` extracts the second constructor argument (see `comp1`)." ->
comp2(c::AbstractRGB) = green(c)
comp2{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = green(c)
comp2(c::Union(Color,ColorAlpha)) = getfield(c, 2)
comp2(c::AlphaColor) = getfield(c, 3)

@doc "`comp3(c)` extracts the third constructor argument (see `comp1`)." ->
comp3(c::AbstractRGB) = blue(c)
comp3{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = blue(c)
comp3(c::Union(Color,ColorAlpha)) = getfield(c, 3)
comp3(c::AlphaColor) = getfield(c, 4)

@doc "`color(c)` extracts the opaque color component from a Colorant (e.g., omits the alpha channel, if present)." ->
color(c::Color) = c
color{C,T}(c::TransparentColor{C,T,4}) = C(comp1(c), comp2(c), comp3(c))
color{C,T}(c::TransparentColor{C,T,2}) = C(comp1(c))

# Generate the transparent analog of a color
alphacolor{C<:Color}(c::C) = alphacolor(C)(c)
coloralpha{C<:Color}(c::C) = coloralpha(C)(c)

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# recurse up the type hierarchy until you get to Colorant{T,N} for
# specific T,N.
to_top{T,N}(::Type{Colorant{T,N}}) = Colorant{T,N}
to_top{C<:Colorant}(::Type{C}) = to_top(super(C))

to_top(c::Colorant) = to_top(typeof(c))

# eltype(RGB{Float32}) -> Float32
eltype{T          }(::Type{Colorant{T}})   = T
eltype{T,N        }(::Type{Colorant{T,N}}) = T
eltype{C<:Colorant}(::Type{C}) = eltype(super(C))

eltype(c::Colorant) = eltype(typeof(c))

# Return the number of components in the color
# Note this is different from div(sizeof(c), sizeof(eltype(c))) (e.g., RGB1)
length{T,N}(::Type{Colorant{T,N}}) = N
length{N}(::Type{Colorant{TypeVar(:T),N}}) = N   # julia #12596
length{C<:Colorant}(::Type{C}) = length(super(C))

length(c::Colorant) = length(typeof(c))

@doc """
`color_type(c)` or `color_type(C)` (`c` being a color instance and `C`
being the type) returns the type of the Color object (without
alpha channel).  This, and related functions like `base_color_type`,
`base_colorant_type`, and `ccolor` are useful for manipulating types for
writing generic code.

For example,

    color_type(RGB)          == RGB
    color_type(RGB{Float32}) == RGB{Float32}
    color_type(ARGB{U8})     == RGB{U8}
""" ->
color_type{C<:Color}(::Type{C}) = C
color_type{C<:AlphaColor}(::Type{C}) = color_type(super(C))
color_type{C<:ColorAlpha}(::Type{C}) = color_type(super(C))
color_type{     }(::Type{TransparentColor})        = Color
color_type{C    }(::Type{TransparentColor{C}})     = C
color_type{C,T  }(::Type{TransparentColor{C,T}})   = C
color_type{C,T,N}(::Type{TransparentColor{C,T,N}}) = C
color_type{C,N  }(::Type{TransparentColor{C,TypeVar(:T),N}}) = C

color_type(c::Colorant) = color_type(typeof(c))

@doc """
`base_color_type` is similar to `color_type`, except it "strips off" the
element type.  For example,

    color_type(RGB{U8})     == RGB{U8}
    base_color_type(RGB{U8}) == RGB

This can be very handy if you want to switch element types. For example:

    c64 = base_color_type(c){Float64}(color(c))

converts `c` into a `Float64` representation (potentially discarding
any alpha-channel information).
""" ->
base_color_type{C<:Colorant}(::Type{C}) = base_colorant_type(color_type(C))

base_color_type(c::Colorant) = base_color_type(typeof(c))

if VERSION < v"0.4.0-dev"
    for CT in union(setdiff(parametric3, [RGB1,RGB4]), [Gray])
        @eval base_colorant_type{C<:$CT}(::Type{C}) = $CT
        AC = alphacolor(CT)
        @eval base_colorant_type{C<:$AC}(::Type{C}) = $AC
        CA = coloralpha(CT)
        @eval base_colorant_type{C<:$CA}(::Type{C}) = $CA
    end
    base_colorant_type{C<:RGB1}(::Type{C}) = RGB1
    base_colorant_type{C<:RGB4}(::Type{C}) = RGB4
    # Fallback, in case we missed any. Slow, but oh well.
    base_colorant_type{C<:Colorant}(::Type{C}) = eval(C.name.name)
else
    @eval @generated function base_colorant_type{C<:Colorant}(::Type{C})
        name = C.name.name
        :($name)
    end
end

@doc """
`base_colorant_type` is similar to `base_color_type`, but it preserves the
"alpha" portion of the type.

For example,

    base_color_type(ARGB{U8})  == RGB
    base_colorant_type(ARGB{U8})  == ARGB

If you just want to switch element types, this is the safest default
and the easiest to use:

    c64 = base_colorant_type(c){Float64}(c)
""" ->
base_colorant_type(c::Colorant) = base_colorant_type(typeof(c))

colorant_string{C<:Colorant}(::Type{C}) = string(C.name.name)

@doc """
 `ccolor` ("concrete color") helps write flexible methods. The idea is
that users may write `convert(HSV, c)` or even `convert(Array{HSV},
A)` without specifying the element type explicitly (e.g.,
`convert(HSV{Float32}, c)`). `ccolor` implements the logic "choose the
user's eltype if specified, otherwise retain the eltype of the source
object." However, when the source object has FixedPoint element type,
and the destination only supports AbstractFloat, we choose Float32.

Usage:

    ccolor(desttype, srctype) -> concrete desttype

Example:

    convert{C<:Colorant}(::Type{C}, p::Colorant) = cnvt(ccolor(C,typeof(p)), p)

where `cnvt` is the function that performs explicit conversion.
""" ->
ccolor{   Csrc<:Colorant}(::Type{Colorant   }, ::Type{Csrc}) = Csrc
ccolor{T, Csrc<:Colorant}(::Type{Colorant{T}}, ::Type{Csrc}) = base_colorant_type(Csrc){T}
ccolor{   Csrc<:Colorant}(::Type{Color   }, ::Type{Csrc}) = color_type(Csrc)
ccolor{T, Csrc<:Colorant}(::Type{Color{T}}, ::Type{Csrc}) = base_color_type(Csrc){T}

ccolor{Csrc<:Color}(::Type{TransparentColor}, ::Type{Csrc}) =
          error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor{C<:Color,    Csrc<:Color}(
       ::Type{TransparentColor{C    }}, ::Type{Csrc}) =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor{C<:Color,T,  Csrc<:Color}(
       ::Type{TransparentColor{C,T  }}, ::Type{Csrc}) =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")
ccolor{C<:Color,T,N,Csrc<:Color}(
       ::Type{TransparentColor{C,T,N}}, ::Type{Csrc}) =
           error("Ambiguous storage order, choose AlphaColor or ColorAlpha")

ccolor{Csrc<:TransparentColor}(::Type{TransparentColor}, ::Type{Csrc}) = Csrc

ccolor{Csrc<:Colorant}(::Type{AlphaColor}, ::Type{Csrc}) = alphacolor(Csrc)
ccolor{C<:Color,    Csrc<:Colorant}(
       ::Type{AlphaColor{C    }}, ::Type{Csrc}) = ccolor(alphacolor(C), Csrc)
ccolor{C<:Color,T,  Csrc<:Colorant}(
       ::Type{AlphaColor{C,T  }}, ::Type{Csrc}) = ccolor(alphacolor(C){T}, Csrc)
ccolor{C<:Color,T,N,Csrc<:Colorant}(
       ::Type{AlphaColor{C,T,N}}, ::Type{Csrc}) = ccolor(alphacolor(C){T}, Csrc)

ccolor{Csrc<:Colorant}(::Type{ColorAlpha}, ::Type{Csrc}) = coloralpha(Csrc)
ccolor{C<:Color,    Csrc<:Colorant}(
       ::Type{ColorAlpha{C    }}, ::Type{Csrc}) = ccolor(coloralpha(C), Csrc)
ccolor{C<:Color,T,  Csrc<:Colorant}(
       ::Type{ColorAlpha{C,T  }}, ::Type{Csrc}) = ccolor(coloralpha(C){T}, Csrc)
ccolor{C<:Color,T,N,Csrc<:Colorant}(
       ::Type{ColorAlpha{C,T,N}}, ::Type{Csrc}) = ccolor(coloralpha(C){T}, Csrc)

ccolor{  Csrc<:AbstractRGB}(::Type{AbstractRGB},    ::Type{Csrc}) = Csrc
ccolor{T,Csrc<:AbstractRGB}(::Type{AbstractRGB{T}}, ::Type{Csrc}) = base_colorant_type(Csrc){T}

# Concrete types
ccolor{Cdest<:Colorant,Csrc<:Colorant}(::Type{Cdest}, ::Type{Csrc}) = base_colorant_type(Cdest){pick_eltype(color_type(Cdest), eltype(Cdest), eltype(Csrc))}
ccolor{Csrc<:Colorant}(::Type{RGB24},   ::Type{Csrc}) = RGB24
ccolor{Csrc<:Colorant}(::Type{ARGB32},  ::Type{Csrc}) = ARGB32
ccolor{Csrc<:Colorant}(::Type{Gray24},  ::Type{Csrc}) = Gray24
ccolor{Csrc<:Colorant}(::Type{AGray32}, ::Type{Csrc}) = AGray32

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
        ==(x::UInt32, y::$T) = x == convert(UInt32, y)
        ==(x::$T, y::UInt32) = ==(y, x)
    end
end
==(x::Gray, y::Gray) = x.val == y.val
==(x::Number, y::Gray) = x == y.val
==(x::Gray, y::Number) = ==(y, x)

zero{T}(::Type{Gray{T}}) = Gray{T}(zero(T))
 one{T}(::Type{Gray{T}}) = Gray{T}(one(T))
