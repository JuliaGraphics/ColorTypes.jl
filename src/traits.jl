# Core traits and accessor functions

@doc """
`alpha(p)` extracts the alpha component of a paint. For a paint
without an alpha channel, it will always return 1.
""" ->
alpha(c::Transparent) = c.alpha
alpha(c::AbstractColor) = one(eltype(c))
alpha(c::RGB24)   = Ufixed8(1)
alpha(c::ARGB32)  = Ufixed8((c.color & 0xff000000)>>24, 0)
alpha(c::AGray32) = Ufixed8((c.color & 0xff000000)>>24, 0)

@doc "`red(c)` returns the red component of an `AbstractRGB` color or paint." ->
red(c::AbstractRGB   ) = c.r
red(c::TransparentRGB) = c.r
red(c::RGB24)  = Ufixed8((c.color & 0x00ff0000)>>16, 0)
red(c::ARGB32) = Ufixed8((c.color & 0x00ff0000)>>16, 0)

@doc "`green(c)` returns the green component of an `AbstractRGB` color or paint." ->
green(c::AbstractRGB   ) = c.g
green(c::TransparentRGB) = c.g
green(c::RGB24)  = Ufixed8((c.color & 0x0000ff00)>>8, 0)
green(c::ARGB32) = Ufixed8((c.color & 0x0000ff00)>>8, 0)

@doc "`blue(c)` returns the blue component of an `AbstractRGB` color or paint." ->
blue(c::AbstractRGB   ) = c.b
blue(c::TransparentRGB) = c.b
blue(c::RGB24)  = Ufixed8(c.color & 0x000000ff, 0)
blue(c::ARGB32) = Ufixed8(c.color & 0x000000ff, 0)

@doc "`gray(c)` returns the gray component of an `AbstractGray` color or paint." ->
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

Specifically, for any `Color`,

    c == typeof(c)(comp1(c), comp2(c), comp3(c)

return true.
""" ->
comp1(c::AbstractRGB) = red(c)
comp1{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = red(c)
comp1(c::Union(AbstractColor,ColorAlpha, TransparentGray)) = getfield(c, 1)
comp1(c::AlphaColor) = getfield(c, 2)

@doc "`comp2(c)` extracts the second constructor argument (see `comp1`)." ->
comp2(c::AbstractRGB) = green(c)
comp2{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = green(c)
comp2(c::Union(AbstractColor,ColorAlpha, TransparentGray)) = getfield(c, 2)
comp2(c::AlphaColor) = getfield(c, 3)

@doc "`comp3(c)` extracts the third constructor argument (see `comp1`)." ->
comp3(c::AbstractRGB) = blue(c)
comp3{C<:AbstractRGB}(c::Union(AlphaColor{C},ColorAlpha{C})) = blue(c)
comp3(c::Union(AbstractColor,ColorAlpha)) = getfield(c, 3)
comp3(c::AlphaColor) = getfield(c, 4)

@doc "`color(p)` extracts the color-object from a paint (e.g., omits the alpha channel)." ->
color(c::AbstractColor) = c
color{T}(p::Paint{T,4}) = colortype(p)(comp1(p), comp2(p), comp3(p))
color{T}(p::Paint{T,2}) = colortype(p)(comp1(p))

# Generate the transparent analog of a color
alphacolor{C<:AbstractColor}(c::C) = alphacolor(C)(c)
coloralpha{C<:AbstractColor}(c::C) = coloralpha(C)(c)

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# recurse up the type hierarchy until you get to Paint{T,N} for
# specific T,N.
to_paint{T,N}(::Type{Paint{T,N}}) = Paint{T,N}
to_paint{P<:Paint}(::Type{P}) = to_paint(super(P))

to_paint(c::Paint) = to_paint(typeof(c))

# eltype(RGB{Float32}) -> Float32
eltype{T       }(::Type{Paint{T}})   = T
eltype{T,N     }(::Type{Paint{T,N}}) = T
eltype{P<:Paint}(::Type{P}) = eltype(super(P))

eltype(c::Paint) = eltype(typeof(c))

# Return the number of components in the color
# Note this is different from div(sizeof(c), sizeof(eltype(c))) (e.g., RGB1)
length{T,N}(::Type{Paint{T,N}}) = N
length{N}(::Type{Paint{TypeVar(:T),N}}) = N   # julia #12596
length{P<:Paint}(::Type{P}) = length(super(P))

length(c::Paint) = length(typeof(c))

@doc """
`colortype(p)` or `colortype(P)` (`p` being a paint instance
and `P` being the type) returns the type of the color object (without
alpha channel).  This, and related functions like `basecolortype`,
`basepainttype`, and `ccolor` are useful for manipulating types
for writing generic code.

For example,

    colortype(RGB)          == RGB
    colortype(RGB{Float32}) == RGB{Float32}
    colortype(ARGB{U8})     == RGB{U8}
""" ->
colortype{C<:AbstractColor}(::Type{C}) = C
colortype{P<:AlphaColor   }(::Type{P}) = colortype(super(P))
colortype{P<:ColorAlpha   }(::Type{P}) = colortype(super(P))
colortype{     }(::Type{Transparent})        = AbstractColor
colortype{C    }(::Type{Transparent{C}})     = C
colortype{C,T  }(::Type{Transparent{C,T}})   = C
colortype{C,T,N}(::Type{Transparent{C,T,N}}) = C
colortype{C,N  }(::Type{Transparent{C,TypeVar(:T),N}}) = C

colortype(c::Paint) = colortype(typeof(c))

@doc """
`basecolortype` is similar to `colortype`, except it "strips off" the
element type.  For example,

    colortype(RGB{U8})     == RGB{U8}
    basecolortype(RGB{U8}) == RGB

This can be very handy if you want to switch element types. For example:

    c64 = basecolortype(c){Float64}(color(c))

converts `c` into a `Float64` representation (potentially discarding
any alpha-channel information).
""" ->
basecolortype{P<:Paint}(::Type{P}) = basepainttype(colortype(P))

basecolortype(c::Paint) = basecolortype(typeof(c))

if VERSION < v"0.4.0-dev"
    basepainttype{P<:Paint}(::Type{P}) = eval(P.name.name)  # slow, but oh well
else
    @eval @generated function basepainttype{P<:Paint}(::Type{P})
        name = P.name.name
        :($name)
    end
end

@doc """
`basepainttype` is similar to `basecolortype`, but it preserves the
"alpha" portion of the type.

For example,

    basecolortype(ARGB{U8})  == RGB
    basepainttype(ARGB{U8})  == ARGB

If you just want to switch element types, this is the safest default
and the easiest to use:

    c64 = basepainttype(c){Float64}(c)
""" ->
basepainttype(c::Paint) = basepainttype(typeof(c))

paint_string{P<:Paint}(::Type{P}) = string(P.name.name)

"""
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

    convert{P<:Paint}(::Type{P}, p::Paint) = cnvt(ccolor(P,typeof(p)), p)

where `cnvt` is the function that performs explicit conversion.
"""
ccolor{Pdest<:Paint,Psrc<:Paint}(::Type{Pdest}, ::Type{Psrc}) = basepainttype(Pdest){pick_eltype(colortype(Pdest), eltype(Pdest), eltype(Psrc))}
ccolor{Psrc<:Paint}(::Type{RGB24},   ::Type{Psrc}) = RGB24
ccolor{Psrc<:Paint}(::Type{ARGB32},  ::Type{Psrc}) = ARGB32
ccolor{Psrc<:Paint}(::Type{Gray24},  ::Type{Psrc}) = Gray24
ccolor{Psrc<:Paint}(::Type{AGray32}, ::Type{Psrc}) = AGray32

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
=={T}(x::Gray{T}, y::Gray{T}) = x.val == y.val
=={T}(x::T, y::Gray{T}) = x == convert(T, y)
=={T}(x::Gray{T}, y::T) = ==(y, x)

zero{T}(::Type{Gray{T}}) = Gray{T}(zero(T))
 one{T}(::Type{Gray{T}}) = Gray{T}(one(T))
