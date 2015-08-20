# no-op and element-type conversions, plus conversion to and from transparency
# Colorimetry conversions are in Colors.jl

convert{C<:Color}(::Type{C}, p::Color) = _convert(ccolor(C, typeof(p)), baseopaquetype(C), baseopaquetype(p), p)
convert{C<:TransparentColor}(::Type{C}, p::OpaqueColor, alpha) = _convert(ccolor(C, typeof(p)), baseopaquetype(C), baseopaquetype(p), p, alpha)

# Fallback definitions that print nice error messages
_convert{C}(::Type{C}, ::Any, ::Any, p) = error("No conversion of ", p, " to ", C, " has been defined")
_convert{C}(::Type{C}, ::Any, ::Any, p, alpha) = error("No conversion of (", p, ",alpha=$alpha) to ", C, " has been defined")

# Implementations for when the base color type is not changing
_convert{Cout<:OpaqueColor,Ccmp<:OpaqueColor}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c::Cout) = c
_convert{Cout<:OpaqueColor,Ccmp<:OpaqueColor}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) = Cout(comp1(c), comp2(c), comp3(c))
_convert{A<:TransparentColor,Ccmp<:OpaqueColor}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) = A(comp1(c), comp2(c), comp3(c), alpha(c))

# With user-supplied alpha
_convert{A<:TransparentColor,Ccmp<:OpaqueColor}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha) = A(comp1(c), comp2(c), comp3(c), alpha)

# Any AbstractRGB types can be interconverted
# (these next 2 are just for ambiguity resolution)
_convert{Cout<:OpaqueColor,C1<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C1}, c::Cout) = c
_convert{Cout<:OpaqueColor,C1<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C1}, c) = Cout(red(c), green(c), blue(c))
_convert{A<:TransparentColor,C1<:AbstractRGB}(::Type{A}, ::Type{C1}, ::Type{C1}, c) = A(red(c), green(c), blue(c), alpha(c))

_convert{Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C2}, c::Union(AbstractRGB,TransparentRGB)) = Cout(red(c), green(c), blue(c))
_convert{A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractRGB}(::Type{A}, ::Type{C1}, ::Type{C2}, c) = A(red(c), green(c), blue(c), alpha(c))

# Grayscale
_convert{Cout<:AbstractGray,Ccmp<:AbstractGray}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c::Cout) = c
_convert{Cout<:AbstractGray,Ccmp<:AbstractGray}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) = Cout(gray(c))
_convert{Cout<:AbstractGray,C1<:AbstractGray,C2<:AbstractGray}(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) = Cout(gray(c))
_convert{A<:TransparentGray,Ccmp<:AbstractGray}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) = A(gray(c), alpha(c))
_convert{A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray}(::Type{A}, ::Type{C1}, ::Type{C2}, c) = A(gray(c), alpha(c))
_convert{A<:TransparentGray,Ccmp<:AbstractGray}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha) = A(gray(c), alpha)


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

# Generate the transparent analog of a color
alphacolor{C<:OpaqueColor}(c::C) = alphacolor(C)(c)
coloralpha{C<:OpaqueColor}(c::C) = coloralpha(C)(c)
