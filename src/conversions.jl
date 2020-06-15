# Get the promoted element type
# Note that `promote_eltype` defined in "types.jl" means promote "arguments".
function _promote_et(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant}
    T1 = isconcretetype(eltype(C1)) ? eltype(C1) : eltypes_supported(C1)
    T2 = isconcretetype(eltype(C2)) ? eltype(C2) : eltypes_supported(C2)
    promote_type(T1, T2)
end
# Get the promoted base "color" type
_promote_color(::Type{C},  ::Type{C})  where {C<:Color} = C
_promote_color(::Type{C},  ::Type{C})  where {N, C<:ColorN{N}} = C
_promote_color(::Type{C1}, ::Type{C2}) where {C1<:Color, C2<:Color} = Color
_promote_color(::Type{C1}, ::Type{C2}) where {N1, C1<:ColorN{N1}, N2, C2<:ColorN{N2}} = ColorN{max(N1, N2)}
_promote_color(::Type{C1}, ::Type{C2}) where {C1<:AbstractGray, C2<:Color} = _promote_color(C2, C2) # C2 may be AbstractRGB
_promote_color(::Type{C1}, ::Type{C2}) where {C1<:Color, C2<:AbstractGray} = _promote_color(C1, C1) # C1 may be AbstractRGB
_promote_color(::Type{C1}, ::Type{C2}) where {C1<:AbstractGray, N2, C2<:ColorN{N2}} = _promote_color(C2, C2)
_promote_color(::Type{C1}, ::Type{C2}) where {N1, C1<:ColorN{N1}, C2<:AbstractGray} = _promote_color(C1, C1)
_promote_color(::Type{C1}, ::Type{C2}) where {C1<:AbstractGray, C2<:AbstractGray} = Gray
function _promote_color(::Type{C1}, ::Type{C2}) where {C1<:AbstractRGB, C2<:AbstractRGB}
    (C1 === XRGB || C2 === XRGB) && return XRGB
    (C1 === RGBX || C2 === RGBX) && return RGBX
    RGB
end

# Get the promoted transparent type
_promote_alpha(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant} = AlphaColor
_promote_alpha(::Type{C1}, ::Type{C2}) where {C1<:ColorAlpha, C2<:Color} = ColorAlpha
_promote_alpha(::Type{C1}, ::Type{C2}) where {C1<:ColorAlpha, C2<:ColorAlpha} = ColorAlpha
_promote_alpha(::Type{C1}, ::Type{C2}) where {C1<:ColorAlpha, C2<:AbstractAGray} = ColorAlpha
_promote_alpha(::Type{C1}, ::Type{C2}) where {C1<:AbstractAGray, C2<:ColorAlpha} = ColorAlpha
_promote_alpha(::Type{C1}, ::Type{C2}) where {C1<:Color, C2<:Color} = Color

Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant} = _promote_rule(C1, C2)
Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:Color, C2<:TransparentColor} = Base.Bottom # to reduce rules

Base.promote_rule(::Type{RGB24},   ::Type{Gray24})  = RGB24 # C vs. C
Base.promote_rule(::Type{Gray24},  ::Type{RGB24})   = RGB24 # C vs. C
Base.promote_rule(::Type{ARGB32},  ::Type{AGray32}) = ARGB32 # TC vs. TC
Base.promote_rule(::Type{AGray32}, ::Type{ARGB32})  = ARGB32 # TC vs. TC
Base.promote_rule(::Type{AGray32}, ::Type{Gray24})  = AGray32
Base.promote_rule(::Type{AGray32}, ::Type{RGB24})   = ARGB32
Base.promote_rule(::Type{ARGB32},  ::Type{Gray24})  = ARGB32
Base.promote_rule(::Type{ARGB32},  ::Type{RGB24})   = ARGB32


function _promote_rule(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant}
    et, alpha = _promote_et(C1, C2), _promote_alpha(C1, C2)
    Cp1, Cp2 = parametric_colorant(C1), parametric_colorant(C2)
    color = _promote_color(base_color_type(Cp1), base_color_type(Cp2))

    _with_et(C::UnionAll, et) = isconcretetype(et) ? C{et} : C
    if !isabstracttype(color)
        alpha <: Color && return _with_et(color, et)
        c = color <: XRGB || color <: RGBX ? RGB : color
        return _with_et(alpha <: ColorAlpha ? coloralpha(c) : alphacolor(c), et)
    end

    function _with_et(A::UnionAll, ::Type{Cb}, et) where {Nb, Cb<:ColorN{Nb}}
        A <: Color && return isconcretetype(et) ? Color{et,Nb} : ColorN{Nb}
        N = min(4, Nb + 1) # FIXME: N should be calculated based on C1 and C2
        isconcretetype(et) ? A{C,et,N} where {C<:Cb{et}} : A{C,T,N} where {T, C<:Cb{T}}
    end
    function _with_et(A::UnionAll, ::Type{Cb}, et) where {Cb<:Color}
        A <: Color && return isconcretetype(et) ? Color{et} : Color
        isconcretetype(et) ? A{C,et} where {C<:Cb{et}} : A{C,T} where {T, C<:Cb{T}}
    end
    _with_et(alpha, color, et)
end


# no-op and element-type conversions, plus conversion to and from transparency
# Colorimetry conversions are in Colors.jl
convert(::Type{C}, c::C) where {C<:Colorant} = c
convert(::Type{C}, c::Colorant) where {C<:Colorant} = cconvert(ccolor(C, typeof(c)), c)
convert(::Type{C}, c::Number) where {C<:Colorant} = cconvert(ccolor(C, typeof(c)), c)
cconvert(::Type{C}, c::C) where {C} = c
cconvert(::Type{C}, c) where {C} = _convert(C, base_color_type(C), base_color_type(c), c)

convert(::Type{C}, c::Color, alpha) where {C<:TransparentColor} = cconvert(ccolor(C, typeof(c)), c, alpha)
cconvert(::Type{C}, c::Color, alpha) where {C<:TransparentColor} =_convert(C, base_color_type(C), base_color_type(c), c, alpha)
cconvert(::Type{ARGB32}, c::AbstractRGB, alpha) = ARGB32(c, alpha) # optimization for speed

# Fallback definitions that print nice error messages
_convert(::Type{C}, ::Any, ::Any, c) where {C} = error("No conversion of ", c, " to ", C, " has been defined")
_convert(::Type{C}, C1::Any, C2::Any, c, alpha) where {C} = error("No conversion of (", c, ",alpha=$alpha) to ", C, " with consistency-types $C1 and $C2 has been defined")

# Any AbstractRGB types can be interconverted
_convert(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) where {Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractRGB} = Cout(red(c), green(c), blue(c))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha=alpha(c)) where {A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractRGB} = A(red(c), green(c), blue(c), alpha)

# Implementations for when the base color type is not changing
# These might trip/add transparency, however
_convert(::Type{Cout}, ::Type{Ccmp}, ::Type{Ccmp}, c) where {Cout<:Color3,Ccmp<:Color3} = Cout(comp1(c), comp2(c), comp3(c))
_convert(::Type{A}, ::Type{Ccmp}, ::Type{Ccmp}, c, alpha=alpha(c)) where {A<:Transparent3,Ccmp<:Color3} = A(comp1(c), comp2(c), comp3(c), alpha)

# Grayscale
_convert(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) where {Cout<:AbstractGray,C1<:AbstractGray,C2<:AbstractGray} = Cout(gray(c))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha=alpha(c)) where {A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray} = A(gray(c), alpha)

_convert(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) where {Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractGray} = (g = convert(eltype(Cout), gray(c)); Cout(g, g, g))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha=alpha(c)) where {A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractGray} = (g = convert(eltype(A), gray(c)); A(g, g, g, alpha))

convert(::Type{RGB24},   x::Real) = RGB24(x, x, x)
convert(::Type{ARGB32},  x::Real) = ARGB32(x, x, x)
convert(::Type{ARGB32},  x::Real, alpha) = ARGB32(x, x, x, alpha)
convert(::Type{Gray24},  x::Real) = Gray24(x)
convert(::Type{AGray32}, x::Real) = AGray32(x)
convert(::Type{AGray32}, x::Real, alpha) = AGray32(x, alpha)

convert(::Type{Gray{T}},  x::Real) where {T} = Gray{T}(x)
convert(::Type{AGray{T}}, x::Real) where {T} = AGray{T}(x)
convert(::Type{GrayA{T}}, x::Real) where {T} = GrayA{T}(x)

convert(::Type{T}, x::Gray  ) where {T<:Real} = convert(T, x.val)
convert(::Type{T}, x::Gray24) where {T<:Real} = convert(T, gray(x))
(::Type{T})(x::AbstractGray)  where {T<:Real} = T(gray(x))
Base.real(x::AbstractGray) = gray(x)

# Define some constructors that just call convert since the fallback constructor in Base
# is removed in Julia 0.7
# The parametric types are handled in @make_constructors and @make_alpha
for t in (:ARGB32, :Gray24, :RGB24)
    @eval $t(x) = convert($t, x)
end

# reinterpret
for T in (RGB24, ARGB32, Gray24, AGray32)
    @eval begin
        reinterpret(::Type{UInt32}, x::$T) = x.color
        reinterpret(::Type{$T}, x::UInt32) = $T(x, Val{true})
    end
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
