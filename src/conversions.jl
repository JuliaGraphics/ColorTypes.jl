Base.promote_rule{T1<:AbstractGray,T2<:AbstractGray}(::Type{T1}, ::Type{T2}) = Gray{promote_type(eltype(T1), eltype(T2))}
Base.promote_rule{T1<:AbstractRGB,T2<:AbstractRGB}(::Type{T1}, ::Type{T2}) = RGB{promote_type(eltype(T1), eltype(T2))}

# no-op and element-type conversions, plus conversion to and from transparency
# Colorimetry conversions are in Colors.jl
convert{C<:Colorant}(::Type{C}, c::C) = c
convert{C<:Colorant}(::Type{C}, c) = cconvert(ccolor(C, typeof(c)), c)
cconvert{C}(::Type{C}, c::C) = c
cconvert{C}(::Type{C}, c)    = _convert(C, base_color_type(C), base_color_type(c), c)
convert{C<:TransparentColor}(::Type{C}, c::Color, alpha) = cconvert(ccolor(C, typeof(c)), c, alpha)
cconvert{C<:Color,T,N}(::Type{AlphaColor{C,T,N}}, c::C, alpha) = alphacolor(C)(c, alpha)
cconvert{C<:Color,T,N}(::Type{ColorAlpha{C,T,N}}, c::C, alpha) = coloralpha(C)(c, alpha)
cconvert{C<:TransparentColor}(::Type{C}, c::Color, alpha) =_convert(C, base_color_type(C), base_color_type(c), c, alpha)

# Fallback definitions that print nice error messages
_convert{C}(::Type{C}, ::Any, ::Any, c) = error("No conversion of ", c, " to ", C, " has been defined")
_convert{C}(::Type{C}, C1::Any, C2::Any, c, alpha) = error("No conversion of (", c, ",alpha=$alpha) to ", C, " with consistency-types $C1 and $C2 has been defined")

# Any AbstractRGB types can be interconverted
# (the first 2 are just for ambiguity resolution)
# Note: on julia 0.3 these have to be before the block below, or you
# get a spurious ambiguity warning.
_convert{Cout<:AbstractRGB,C1<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C1}, c) = Cout(red(c), green(c), blue(c))
_convert{A<:TransparentRGB,C1<:AbstractRGB}(::Type{A}, ::Type{C1}, ::Type{C1}, c) = A(red(c), green(c), blue(c), alpha(c))
_convert{Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractRGB}(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) = Cout(red(c), green(c), blue(c))
_convert{A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractRGB}(::Type{A}, ::Type{C1}, ::Type{C2}, c) = A(red(c), green(c), blue(c), alpha(c))

# Implementations for when the base color type is not changing
# These might trip/add transparency, however
_convert{Cout<:Color3,Ccmp<:Color3}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) = Cout(comp1(c), comp2(c), comp3(c))
_convert{A<:Transparent3,Ccmp<:Color3}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) = A(comp1(c), comp2(c), comp3(c), alpha(c))
_convert{Cout<:AbstractGray,Ccmp<:AbstractGray}(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) = Cout(gray(c))
_convert{A<:TransparentGray,Ccmp<:AbstractGray}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) = A(gray(c), alpha(c))

# With user-supplied alpha
_convert{A<:Transparent3,Ccmp<:Color3}(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha) = A(comp1(c), comp2(c), comp3(c), alpha)

# Grayscale
_convert{Cout<:AbstractGray,C1<:AbstractGray,C2<:AbstractGray}(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) = Cout(gray(c))
_convert{A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray}(::Type{A}, ::Type{C1}, ::Type{C2}, c) = A(gray(c), alpha(c))
_convert{A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray}(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha) = A(gray(c), alpha)


for T in (RGB24, ARGB32, Gray24, AGray32)
    @eval begin
        @deprecate convert(::Type{UInt32}, c::$T) reinterpret(UInt32, c)
        @deprecate getindex(::Type{$T}, x::UInt32) $T[reinterpret($T, x)]
        @deprecate getindex(::Type{$T}, x::UInt32, y::UInt32) $T[reinterpret($T, x), reinterpret($T, y)]
        @deprecate getindex(::Type{$T}, x::UInt32, y::UInt32, z::UInt32) $T[reinterpret($T, x), reinterpret($T, y), reinterpret($T, z)]
        @deprecate getindex(::Type{$T}, vals::UInt32...) $T[map(x->reinterpret($T, x), vals)...]
    end
end

convert(::Type{RGB24},   x::Real) = RGB24(x, x, x)
convert(::Type{ARGB32},  x::Real) = ARGB32(x, x, x, 1)
convert(::Type{Gray24},  x::Real) = Gray24(x)
convert(::Type{AGray32}, x::Real) = AGray32(x, 1)
convert(::Type{AGray32}, x::Real, alpha) = AGray32(x, alpha)

convert{T}(::Type{Gray{T}},  x::Real)    = Gray{T}(x)
convert{T<:Real}(::Type{T},  x::Gray)    = convert(T, x.val)
convert{T<:Real}(::Type{T},  x::Gray24)  = convert(T, gray(x))
convert{T}(::Type{AGray{T}}, x::Real)    = AGray{T}(x)
convert{T}(::Type{GrayA{T}}, x::Real)    = GrayA{T}(x)

# Generate the transparent analog of a color
alphacolor{C<:Color}(c::C) = alphacolor(C)(c)
alphacolor{C<:Color}(c::C,a) = alphacolor(C)(c,a)
alphacolor{C<:TransparentColor}(c::C) = alphacolor(base_color_type(C))(color(c), alpha(c))
alphacolor{C<:TransparentColor}(c::C,a) = alphacolor(base_color_type(C))(color(c), a)
coloralpha{C<:Color}(c::C) = coloralpha(C)(c)
coloralpha{C<:Color}(c::C,a) = coloralpha(C)(c,a)
coloralpha{C<:TransparentColor}(c::C) = coloralpha(base_color_type(C))(color(c), alpha(c))
coloralpha{C<:TransparentColor}(c::C,a) = coloralpha(base_color_type(C))(color(c), a)
