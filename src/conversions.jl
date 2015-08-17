# no-op and element-type conversions, plus conversion to and from transparency
# Colorimetry conversions are in Colors.jl

convert{P<:Paint}(::Type{P}, p::Paint) = _convert(ccolor(P, typeof(p)), basecolortype(P), basecolortype(p), p)
convert{P<:Transparent}(::Type{P}, p::AbstractColor, alpha) = _convert(ccolor(P, typeof(p)), basecolortype(P), basecolortype(p), p, alpha)

# Fallback definitions that print nice error messages
_convert{P}(::Type{P}, ::Any, ::Any, p) = error("No conversion of ", p, " to ", P, " has been defined")
_convert{P}(::Type{P}, ::Any, ::Any, p, alpha) = error("No conversion of (", p, ",alpha=$alpha) to ", P, " has been defined")

# Implementations for when the base color type is not changing
_convert{Cout<:Color,Ccmp<:Color}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) = Cout(comp1(c), comp2(c), comp3(c))
_convert{A<:Transparent,Ccmp<:Color}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) = A(comp1(c), comp2(c), comp3(c), alpha(c))

# With user-supplied alpha
_convert{A<:Transparent,Ccmp<:Color}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha) = A(comp1(c), comp2(c), comp3(c), alpha)

# Any AbstractRGB types can be interconverted
# (these next 2 are just for ambiguity resolution)
_convert{Cout<:Color,C1<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C1}, c) = Cout(red(c), green(c), blue(c))
_convert{A<:Transparent,C1<:AbstractRGB}(::Type{A}, ::Type{C1}, ::Type{C1}, c) = A(red(c), green(c), blue(c), alpha(c))

_convert{Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) = Cout(red(c), green(c), blue(c))
_convert{A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractRGB}(::Type{A}, ::Type{C1}, ::Type{C2}, c) = A(red(c), green(c), blue(c), alpha(c))

# Grayscale
_convert{Cout<:AbstractGray,C1<:AbstractGray,C2<:AbstractGray}(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) = Cout(gray(c))
_convert{A<:Transparent,C1<:AbstractGray,C2<:AbstractGray}(::Type{A}, ::Type{C1}, ::Type{C2}, c) = A(gray(c), alpha(c))
_convert{A<:Transparent,Ccmp<:AbstractGray}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha) = A(gray(c), alpha)


convert(::Type{UInt32}, c::RGB24)   = c.color
convert(::Type{UInt32}, c::ARGB32)  = c.color
convert(::Type{UInt32}, g::Gray24)  = g.color
convert(::Type{UInt32}, g::AGray32) = g.color

convert(::Type{RGB24},   x::Real) = RGB24(x)
convert(::Type{ARGB32},  x::Real) = ARGB32(x)
convert(::Type{Gray24},  x::Real) = Gray24(x)
convert(::Type{AGray32}, x::Real) = AGray32(x)
convert(::Type{ARGB32},  x::Real, alpha) = ARGB32(x, alpha)
convert(::Type{AGray32}, x::Real, alpha) = AGray32(x, alpha)

convert{T}(::Type{Gray{T}},  x::Real)    = Gray{T}(x)
convert{T<:Real}(::Type{T},  x::Gray)    = convert(T, x.val)
convert{T}(::Type{AGray{T}}, x::Real)    = AGray{T}(x)
convert{T}(::Type{GrayA{T}}, x::Real)    = GrayA{T}(x)


# extract the color from a paint
color(c::AbstractColor) = c
color{C,T}(c::Transparent{C,T,2}) = C(comp1(c))
color{C,T}(c::Transparent{C,T,4}) = C(comp1(c),comp2(c),comp3(c))
#color(c::ARGB32) = convert(RGB24, c)


# Generate the transparent analog of a color
alphacolor{C<:AbstractColor}(c::C) = alphacolor(C)(c)
coloralpha{C<:AbstractColor}(c::C) = coloralpha(C)(c)
