Base.promote_rule(::Type{T1}, ::Type{T2}) where {T1<:AbstractGray,T2<:AbstractGray} = Gray{promote_type(eltype(T1), eltype(T2))}
Base.promote_rule(::Type{T1}, ::Type{T2}) where {T1<:AbstractRGB,T2<:AbstractRGB} = RGB{promote_type(eltype(T1), eltype(T2))}

# no-op and element-type conversions, plus conversion to and from transparency
# Colorimetry conversions are in Colors.jl
convert(::Type{C}, c::C) where {C<:Colorant} = c
convert(::Type{C}, c) where {C<:Colorant} = cconvert(ccolor(C, typeof(c)), c)
cconvert(::Type{C}, c::C) where {C} = c
cconvert(::Type{C}, c) where {C}    = _convert(C, base_color_type(C), base_color_type(c), c)
convert(::Type{C}, c::Color, alpha) where {C<:TransparentColor} = cconvert(ccolor(C, typeof(c)), c, alpha)
cconvert(::Type{AlphaColor{C,T,N}}, c::C, alpha) where {C<:Color,T,N} = alphacolor(C)(c, alpha)
cconvert(::Type{ColorAlpha{C,T,N}}, c::C, alpha) where {C<:Color,T,N} = coloralpha(C)(c, alpha)
cconvert(::Type{C}, c::Color, alpha) where {C<:TransparentColor} =_convert(C, base_color_type(C), base_color_type(c), c, alpha)

# Fallback definitions that print nice error messages
_convert(::Type{C}, ::Any, ::Any, c) where {C} = error("No conversion of ", c, " to ", C, " has been defined")
_convert(::Type{C}, C1::Any, C2::Any, c, alpha) where {C} = error("No conversion of (", c, ",alpha=$alpha) to ", C, " with consistency-types $C1 and $C2 has been defined")

# Any AbstractRGB types can be interconverted
# (the first 2 are just for ambiguity resolution)
# Note: on julia 0.3 these have to be before the block below, or you
# get a spurious ambiguity warning.
_convert(::Type{Cout}, ::Type{C1}, ::Type{C1}, c) where {Cout<:AbstractRGB,C1<:AbstractRGB} = Cout(red(c), green(c), blue(c))
_convert(::Type{A}, ::Type{C1}, ::Type{C1}, c) where {A<:TransparentRGB,C1<:AbstractRGB} = A(red(c), green(c), blue(c), alpha(c))
_convert(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) where {Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractRGB} = Cout(red(c), green(c), blue(c))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c) where {A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractRGB} = A(red(c), green(c), blue(c), alpha(c))

# Implementations for when the base color type is not changing
# These might trip/add transparency, however
_convert(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) where {Cout<:Color3,Ccmp<:Color3} = Cout(comp1(c), comp2(c), comp3(c))
_convert(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) where {A<:Transparent3,Ccmp<:Color3} = A(comp1(c), comp2(c), comp3(c), alpha(c))
_convert(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) where {Cout<:AbstractGray,Ccmp<:AbstractGray} = Cout(gray(c))
_convert(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c) where {A<:TransparentGray,Ccmp<:AbstractGray} = A(gray(c), alpha(c))

# With user-supplied alpha
_convert(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha) where {A<:Transparent3,Ccmp<:Color3} = A(comp1(c), comp2(c), comp3(c), alpha)

# Grayscale
_convert(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) where {Cout<:AbstractGray,C1<:AbstractGray,C2<:AbstractGray} = Cout(gray(c))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c) where {A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray} = A(gray(c), alpha(c))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha) where {A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray} = A(gray(c), alpha)

convert(::Type{RGB24},   x::Real) = RGB24(x, x, x)
convert(::Type{ARGB32},  x::Real) = ARGB32(x, x, x, 1)
convert(::Type{Gray24},  x::Real) = Gray24(x)
convert(::Type{AGray32}, x::Real) = AGray32(x, 1)
convert(::Type{AGray32}, x::Real, alpha) = AGray32(x, alpha)

convert(::Type{Gray{T}},  x::Real) where {T}    = Gray{T}(x)
convert(::Type{T},  x::Gray) where {T<:Real}    = convert(T, x.val)
convert(::Type{T},  x::Gray24) where {T<:Real}  = convert(T, gray(x))
convert(::Type{AGray{T}}, x::Real) where {T}    = AGray{T}(x)
convert(::Type{GrayA{T}}, x::Real) where {T}    = GrayA{T}(x)

(::Type{T})(x::AbstractGray) where {T<:Real}    = T(gray(x))

# Define some constructors that just call convert since the fallback constructor in Base
# is removed in Julia 0.7
# The parametric types are handled in @make_constructors and @make_alpha
for t in (:ARGB32, :Gray24, :RGB24)
    @eval $t(x) = convert($t, x)
end

# Generate the transparent analog of a color
alphacolor(c::C) where {C<:Color} = alphacolor(C)(c)
alphacolor(c::C,a) where {C<:Color} = alphacolor(C)(c,a)
alphacolor(c::C) where {C<:TransparentColor} = alphacolor(base_color_type(C))(color(c), alpha(c))
alphacolor(c::C,a) where {C<:TransparentColor} = alphacolor(base_color_type(C))(color(c), a)
coloralpha(c::C) where {C<:Color} = coloralpha(C)(c)
coloralpha(c::C,a) where {C<:Color} = coloralpha(C)(c,a)
coloralpha(c::C) where {C<:TransparentColor} = coloralpha(base_color_type(C))(color(c), alpha(c))
coloralpha(c::C,a) where {C<:TransparentColor} = coloralpha(base_color_type(C))(color(c), a)
