
function _promote_et(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant}
    T1 = isconcretetype(eltype(C1)) ? eltype(C1) : eltypes_supported(C1)
    T2 = isconcretetype(eltype(C2)) ? eltype(C2) : eltypes_supported(C2)
    promote_type(T1, T2)
end

_with_et(C::UnionAll, et) = isconcretetype(et) ? C{et} : C
function _transparentcolor_with_et(::Type{C0}, et) where {N, C0<:TransparentColorN{N}}
    if isconcretetype(et)
        C0 <: AlphaColor && return AlphaColor{C,et,N} where {C<:Color{et,N-1}}
        C0 <: ColorAlpha && return ColorAlpha{C,et,N} where {C<:Color{et,N-1}}
        return TransparentColor{C,et,N} where {C<:Color{et,N-1}}
    else
        # Note that the constraint between the element type `T` and the element
        # type of the base color type `C`.
        # The element types should be the same, but there is no such a constraint in
        # the definition of `TransparentColor`/`AlphaColor`/`ColorAlpha`.
        # The following should be consistent with `base_colorant_type`
        C0 <: AlphaColor && return AlphaColor{C,T,N} where {T, C<:Color{T,N-1}}
        C0 <: ColorAlpha && return ColorAlpha{C,T,N} where {T, C<:Color{T,N-1}}
        return TransparentColor{C,T,N} where {T, C<:Color{T,N-1}}
    end
end
function _transparentcolor_with_et(::Type{C0}, et) where {C0<:TransparentColor}
    if isconcretetype(et)
        C0 <: AlphaColor && return AlphaColor{C,et} where {C<:Color{et}}
        C0 <: ColorAlpha && return ColorAlpha{C,et} where {C<:Color{et}}
        return TransparentColor{C,et} where {C<:Color{et}}
    else
        C0 <: AlphaColor && return AlphaColor{C,T} where {T, C<:Color{T}}
        C0 <: ColorAlpha && return ColorAlpha{C,T} where {T, C<:Color{T}}
        return TransparentColor{C,T} where {T, C<:Color{T}}
    end
end

Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant} = _promote_rule(C1, C2)
Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:Color, C2<:TransparentColor} = Base.Bottom

Base.promote_rule(::Type{RGB24},   ::Type{Gray24})  = RGB24 # C vs. C
Base.promote_rule(::Type{Gray24},  ::Type{RGB24})   = RGB24 # C vs. C
Base.promote_rule(::Type{ARGB32},  ::Type{AGray32}) = ARGB32 # TC vs. TC
Base.promote_rule(::Type{AGray32}, ::Type{ARGB32})  = ARGB32 # TC vs. TC
Base.promote_rule(::Type{AGray32}, ::Type{Gray24})  = AGray32
Base.promote_rule(::Type{AGray32}, ::Type{RGB24})   = ARGB32
Base.promote_rule(::Type{ARGB32},  ::Type{Gray24})  = ARGB32
Base.promote_rule(::Type{ARGB32},  ::Type{RGB24})   = ARGB32


function _promote_rule(::Type{C1}, ::Type{C2}) where {C1<:Colorant, C2<:Colorant}
    et, Cb1, Cb2 = _promote_et(C1, C2), base_colorant_type(C1), base_colorant_type(C2)
    Cb1 === Cb2 && return _with_et(Cb1, et)
    C1 <: AbstractGray && return _with_et(Cb2 === RGB24 || Cb2 === AbstractRGB ? RGB : Cb2, et)
    C2 <: AbstractGray && return _with_et(Cb1 === RGB24 || Cb1 === AbstractRGB ? RGB : Cb1, et)
    _with_et(base_color_type(typejoin(C1, C2)), et)
end
function _promote_rule(::Type{C1}, ::Type{C2}) where {C1<:TransparentColor, C2<:TransparentColor}
    et, Cb1, Cb2 = _promote_et(C1, C2), base_colorant_type(C1), base_colorant_type(C2)
    Cb1 === Cb2 && return _with_et(Cb1, et)
    C1 === ARGB32 && C2 <: AbstractARGB && return ARGB{et}
    C2 === ARGB32 && C1 <: AbstractARGB && return ARGB{et}
    C1 === AGray32 && C2 <: AbstractAGray && return AGray{et}
    C2 === AGray32 && C1 <: AbstractAGray && return AGray{et}
    C1 <: TransparentGray && return _with_et(Cb2 === ARGB32 ? ARGB : Cb2, et)
    C2 <: TransparentGray && return _with_et(Cb1 === ARGB32 ? ARGB : Cb1, et)
    _transparentcolor_with_et(typejoin(C1, C2), et)
end
function _promote_rule(::Type{C1}, ::Type{C2}) where {C1<:TransparentColor, C2<:Color}
    et, Cb1, Cb2 = _promote_et(C1, C2), base_color_type(C1), base_color_type(C2)
    Cb1 === Cb2 && return _with_et(base_colorant_type(C1), et) # != Cb1
    C1 === ARGB32 && C2 <: AbstractGray && return _with_et(ARGB, et)
    C1 === AGray32 && C2 <: AbstractRGB && return _with_et(ARGB, et)
    C1 <: AbstractAGray && return _with_et(Cb2 === RGB24 || Cb2 === AbstractRGB ? ARGB : alphacolor(Cb2), et)
    C1 <: AbstractGrayA && return _with_et(Cb2 === RGB24 || Cb2 === AbstractRGB ? RGBA : coloralpha(Cb2), et)
    if C2 <: AbstractGray
        Cbc1 = base_colorant_type(C1) # != Cb1
        C1 <: AlphaColor && return _with_et(Cb1 <: AbstractRGB ? ARGB : Cbc1, et)
        C1 <: ColorAlpha && return _with_et(Cb1 <: AbstractRGB ? RGBA : Cbc1, et)
        return _with_et(Cb1 <: AbstractRGB ? TransparentRGB{RGB} : Cbc1, et)
    end
    _transparentcolor_with_et(C1, et)
end
function _promote_rule(::Type{C1}, ::Type{C2}) where {C1<:AbstractRGB, C2<:AbstractRGB}
    et, Cb1, Cb2 = _promote_et(C1, C2), base_color_type(C1), base_color_type(C2)
    Cb1 === Cb2 && return _with_et(Cb1, et)
    C1 <: RGBX && !(C2 <: XRGB) && return _with_et(RGBX, et)
    C1 <: XRGB && !(C2 <: RGBX) && return _with_et(XRGB, et)
    C2 <: RGBX && !(C1 <: XRGB) && return _with_et(RGBX, et)
    C2 <: XRGB && !(C1 <: RGBX) && return _with_et(XRGB, et)
    _with_et(RGB, et)
end
function _promote_rule(::Type{C1}, ::Type{C2}) where {C1<:AbstractGray, C2<:AbstractGray}
    et, Cb1, Cb2 = _promote_et(C1, C2), base_color_type(C1), base_color_type(C2)
    Cb1 === Cb2 && return _with_et(Cb1, et)
    _with_et(Gray, et)
end
_promote_rule(::Type{C1}, ::Type{C2}) where {C1<:TransparentRGB, C2<:AbstractRGB} =
    _with_et(C1 === ARGB32 ? ARGB : base_colorant_type(C1), _promote_et(C1, C2))

_promote_rule(::Type{C1}, ::Type{C2}) where {C1<:TransparentGray, C2<:AbstractGray} =
    _with_et(C1 === AGray32 ? AGray : base_colorant_type(C1), _promote_et(C1, C2))


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
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha=alpha(c)) where {A<:TransparentGray,C1<:AbstractGray,C2<:AbstractGray} = A(gray(c), alpha)

_convert(::Type{Cout}, ::Type{C1}, ::Type{C2}, c) where {Cout<:AbstractRGB,C1<:AbstractRGB,C2<:AbstractGray} = (g = convert(eltype(Cout), gray(c)); Cout(g, g, g))
_convert(::Type{A}, ::Type{C1}, ::Type{C2}, c, alpha=alpha(c)) where {A<:TransparentRGB,C1<:AbstractRGB,C2<:AbstractGray} = (g = convert(eltype(A), gray(c)); A(g, g, g, alpha))

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
