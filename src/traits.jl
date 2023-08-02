# Core traits and accessor functions

"""
`alpha(p)` extracts the alpha component of a color. For a color
without an alpha channel, it will always return 1.
"""
alpha(c::TransparentColor) = c.alpha
alpha(c::Color)   = oneunit(eltype(c))
alpha(c::RGB24)   = N0f8(1)
alpha(c::ARGB32)  = reinterpret(N0f8, (c.color >> 0x18) % UInt8)
alpha(c::AGray32) = reinterpret(N0f8, (c.color >> 0x18) % UInt8)
alpha(x::Number)  = convert(eltype(ccolor(Gray, typeof(x))), oneunit(x))  # ensures it's a type supported by Gray (which has widest eltype support)

"`red(c)` returns the red component of an `AbstractRGB` opaque or transparent color."
red(c::AbstractRGB   ) = c.r
red(c::TransparentRGB) = c.r
red(c::RGB24)  = reinterpret(N0f8, (c.color >> 0x10) % UInt8)
red(c::ARGB32) = reinterpret(N0f8, (c.color >> 0x10) % UInt8)

"`green(c)` returns the green component of an `AbstractRGB` opaque or transparent color."
green(c::AbstractRGB   ) = c.g
green(c::TransparentRGB) = c.g
green(c::RGB24)  = reinterpret(N0f8, (c.color >> 0x08) % UInt8)
green(c::ARGB32) = reinterpret(N0f8, (c.color >> 0x08) % UInt8)

"`blue(c)` returns the blue component of an `AbstractRGB` opaque or transparent color."
blue(c::AbstractRGB   ) = c.b
blue(c::TransparentRGB) = c.b
blue(c::RGB24)  = reinterpret(N0f8, c.color % UInt8)
blue(c::ARGB32) = reinterpret(N0f8, c.color % UInt8)

"`gray(c)` returns the gray component of a grayscale opaque or transparent color."
gray(c::Gray)    = c.val
gray(c::TransparentGray) = c.val
gray(c::Gray24)  = reinterpret(N0f8, c.color % UInt8)
gray(c::AGray32) = reinterpret(N0f8, c.color % UInt8)
gray(x::Number)  = convert(eltype(ccolor(Gray, typeof(x))), x)   # ensures it's a type supported by Gray

"""
`chroma(c)` returns the chroma of a `Lab`, `Luv`, `Oklab` or their variants color.
!!! note
    The other color types (e.g. `RGB`, `HSV` or `YCbCr`) are not supported
    because their definitions of *chroma* are not clear. Colorfulness, chroma
    and saturation are defined as distinct aspects by the CIE.
"""
chroma(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{Lab,DIN99,DIN99o,DIN99d,Oklab}} = sqrt(c.a^2 + c.b^2)
chroma(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Luv} = sqrt(c.u^2 + c.v^2)
chroma(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{LCHab,LCHuv,Oklch}} = c.c

"""
`hue(c)` returns the hue in degrees. This function does not guarantee that the
return value is in [0, 360].
"""
hue(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{HSV,HSL,HSI,LCHab,LCHuv,Oklch}} = c.h
hue(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{Lab,DIN99,DIN99o,DIN99d,Oklab}} =
    (h = atand(c.b, c.a); h < 0 ? h + 360 : h)
hue(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Luv} =
    (h = atand(c.v, c.u); h < 0 ? h + 360 : h)

# fallbacks for compN
_comp(::Val{N}, c::Colorant) where N = getfield(c, N)
_comp(::Val{N}, c::AlphaColor) where N = getfield(c, N + 1)
_comp(::Val{N}, c::AlphaColorN{N}) where N = alpha(c)
_comp(::Val{N}, c::ColorAlphaN{N}) where N = alpha(c)

@noinline function _comp_error(c::ColorantN{N}, n::Int) where N
    io = IOBuffer()
    print(io, "attempt to access ", N, "-component color ")
    print(IOContext(io, :compact=>true), typeof(c), " with `comp", n, "`")
    throw(ArgumentError(String(take!(io))))
end

"""
`comp1(c)` extracts the first component you'd pass to the constructor
of the corresponding object.  For most color types without an alpha
channel, this is just the first field, but for types like `BGR` that
reverse the internal storage order this provides the value that you'd
use to reconstruct the color.

Specifically, for any `Color{T,3}`,

    c == typeof(c)(comp1(c), comp2(c), comp3(c))

returns true.
"""
comp1(c::Colorant) = _comp(Val(1), c)
comp1(c::Union{AbstractRGB, TransparentRGB}) = red(c)
comp1(c::Union{AbstractGray, TransparentGray}) = gray(c)

"`comp2(c)` extracts the second constructor argument (see `comp1`)."
comp2(c::Colorant) = _comp(Val(2), c)
comp2(c::ColorantN{1}) = _comp_error(c, 2)
comp2(c::Union{AbstractRGB, TransparentRGB}) = green(c)

"`comp3(c)` extracts the third constructor argument (see `comp1`)."
comp3(c::Colorant) = _comp(Val(3), c)
comp3(c::Union{ColorantN{1}, ColorantN{2}}) = _comp_error(c, 3)
comp3(c::Union{AbstractRGB, TransparentRGB}) = blue(c)

"`comp4(c)` extracts the fourth constructor argument (see `comp1`)."
comp4(c::Colorant) = _comp(Val(4), c)
comp4(c::Union{ColorantN{1}, ColorantN{2}, ColorantN{3}}) = _comp_error(c, 4)

"`comp5(c)` extracts the fifth constructor argument (see `comp1`)."
comp5(c::Colorant) = _comp(Val(5), c)
comp5(c::Union{ColorantN{1}, ColorantN{2}, ColorantN{3}, ColorantN{4}}) = _comp_error(c, 5)


"`color(c)` extracts the opaque color component from a Colorant (e.g., omits the alpha channel, if present)."
color(c::Color) = c
color(c::TransparentColorN{2,C}) where {C} = C(comp1(c))
color(c::TransparentColorN{3,C}) where {C} = C(comp1(c), comp2(c))
color(c::TransparentColorN{4,C}) where {C} = C(comp1(c), comp2(c), comp3(c))
color(c::TransparentColorN{5,C}) where {C} = C(comp1(c), comp2(c), comp3(c), comp4(c))

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# recurse up the type hierarchy until you get to Colorant{T,N} for
# specific T,N.
to_top(::Type{Colorant{T,N}}) where {T,N} = Colorant{T,N}
@pure to_top(::Type{C}) where {C<:Colorant} = to_top(supertype(C))

to_top(c::Colorant) = to_top(typeof(c))


# Return the number of components in the color
# Note this is different from div(sizeof(c), sizeof(eltype(c))) (e.g., XRGB)
length(::Type{<:ColorantN{N}}) where N = N

length(c::Colorant) = length(typeof(c))


# eltype(RGB{Float32}) -> Float32
eltype(::Type{C}) where {C<:Colorant{T}} where {T} = T

eltype(c::Colorant) = eltype(typeof(c))

@pure function _parameter_upper_bound(t::UnionAll, idx)
    Base.rewrap_unionall((Base.unwrap_unionall(t)::DataType).parameters[idx], t)
end

# eltypes_supported(Colorant{T<:X}) -> X
function eltypes_supported(::Type{C}) where {C<:Colorant}
    Cb = base_colorant_type(C)
    isconcretetype(C) && C === Cb && return eltype(C)
    _eltypes_supported(Cb, supertype(Cb))
end
@pure _eltypes_supported(::Type{<:Colorant}, ::Type{C}) where {C<:Colorant} = _eltypes_supported(C, supertype(C))
_eltypes_supported(::Type{C}, ::Type) where {C<:Colorant} = _parameter_upper_bound(C, 1)

eltypes_supported(c::Colorant) = eltypes_supported(typeof(c))

"""
    issupported(C::Type, T::Type)::Bool

Returns `true` if `T` is a valid numeric eltype for `C<:Colorant`.
"""
issupported(::Type{C}, ::Type{T}) where {C<:Colorant,T} = T <: eltypes_supported(C)

"""
    CT = color_type(C::Type)
    CT = color_type(c::Colorant)

Return the type of the Color object, discarding any alpha channel.
For example,

    color_type(RGB)          === RGB
    color_type(RGB{Float32}) === RGB{Float32}
    color_type(ARGB{N0f8})   === RGB{N0f8}
    color_type(RGB(1,0,0))   === RGB{N0f8}

`color_type`, and related functions like [`base_color_type`](@ref),
[`base_colorant_type`](@ref), and [`ccolor`](@ref) are useful for manipulating types
when writing generic code.
"""
color_type(::Type{C}) where {C<:Color} = C
color_type(::Type{C}) where {C<:AlphaColor} = color_type(supertype(C)) # may help caching
color_type(::Type{C}) where {C<:ColorAlpha} = color_type(supertype(C)) # may help caching
function color_type(::Type{TC}) where {TC <: TransparentColor}
    _color_type(::Type{TC}) where {C, TC <: TransparentColor{C}} = C
    if TC isa UnionAll
        supertype(TC) <: TransparentColor && return color_type(supertype(TC))
        C1 = _parameter_upper_bound(TC, 1)
        color_type(C1) # simplify
    else
        _color_type(TC)
    end
end
color_type(::Type{Colorant{T,N}}) where {T,N} = Color{T,N}
color_type(::Type{ColorantN{N}}) where {N} = ColorN{N}
color_type(::Type{Colorant{T}}) where {T} = Color{T}
color_type(::Type{Colorant}) = Color
color_type(::Type{X}) where {X<:Number} = typeof(Gray(zero(X)))

color_type(c::Union{Colorant, Number}) = color_type(typeof(c))

"""
    Cbase = base_color_type(C::Type)
    Cbase = base_color_type(c::Colorant)

Return the Color type without alpha channel or a specified numeric element type.
`base_color_type` is similar to [`color_type`](@ref), except it "strips off" the
element type. It always returns a parametric type, which makes it convenient
for switching the numeric element type.

For example, compare

    base_color_type(RGB{N0f8})  === RGB
    base_color_type(RGBA{N0f8}) === RGB

vs

    color_type(RGB{N0f8})       === RGB{N0f8}

Switching element types can be done as follows:

    c64 = base_color_type(c){Float64}(color(c))

`base_color_type` discards any alpha channel. See [`base_colorant_type`](@ref)
if you want to preserve the alpha channel.
"""
base_color_type(::Type{C}) where {C<:Colorant} = base_colorant_type(color_type(C))
base_color_type(::Type{<:Number}) = Gray

base_color_type(x::Union{Colorant,Number}) = base_color_type(typeof(x))

## base_colorant_type implementation

base_colorant_type(::Type{C}) where {C<:Colorant} = isabstracttype(C) ? abstract_basetype(C) : basetype(C)
base_colorant_type(::Type{<:Number}) = Gray

@pure basetype(@nospecialize(C)) = Base.typename(C).wrapper

abstract_basetype(::Type{<:AbstractRGB}) = AbstractRGB
abstract_basetype(::Type{<:AbstractGray}) = AbstractGray
abstract_basetype(::Type{<:ColorN{N}}) where N = ColorN{N}
abstract_basetype(::Type{<:Color}) = Color
function abstract_basetype(::Type{TC}) where {TC<:TransparentColor}
    P = TC <: AlphaColor ? AlphaColor : TC <: ColorAlpha ? ColorAlpha : TransparentColor
    _abstract_transparent_basetype(TC, P, base_color_type(TC))
end
function _abstract_transparent_basetype(::Type{TC}, P, Cb) where {N, TC <: TransparentColorN{N}}
    Cb === Color && return P{C,T,N} where {T,C<:ColorN{N-1,T}}
    isabstracttype(Cb) || return P{Cb{T},T,N} where T
    return P{C,T,N} where {T,C<:Cb{T}}
end
function _abstract_transparent_basetype(::Type{TC}, P, Cb) where {TC <: TransparentColor}
    TC === P && return P
    isabstracttype(Cb) || return P{Cb{T},T} where T
    return P{C,T} where {T,C<:Cb{T}}
end
# This fallback dispatches to a separate function to control method ordering.
# Otherwise the generic ColorantN methods supersede the AlphaColor/ColorAlpha/Transparent methods
abstract_basetype(::Type{C}) where C = abstract_colorant_basetype(C)

abstract_colorant_basetype(::Type{<:ColorantN{N}}) where N = ColorantN{N}
abstract_colorant_basetype(::Type{<:Colorant})             = Colorant

"""
    Cbase = base_colorant_type(C::Type)
    Cbase = base_colorant_type(c::Colorant)

Return the Colorant type without specified numeric element type.

For example, compare

    base_colorant_type(ARGB{N0f8}) === ARGB

vs

    base_color_type(ARGB{N0f8})    === RGB
    color_type(ARGB{N0f8})         === RGB{N0f8}

When possible, `base_colorant_type` returns a parametric `UnionAll`, so
that `Cbase{T}` can be used to specify a colorant with element type `T`.
However, `base_colorant_type` is not guaranteed to return a parametric result,
for example

```jldoctest; setup = :(using ColorTypes)
julia> base_colorant_type(RGB24)
RGB24
```

In generic code, you can check whether `Cbase` is a `DataType` or `UnionAll`;
`Cbase{T}` will be valid only if it's a `UnionAll`.

# Usage example

A safe and easy way to switch the element type of a colorant value `c` to be `Float64` is

    Cbase = base_colorant_type(parametric_colorant(typeof(c)))
    c64 = Cbase{Float64}(c)

"""
base_colorant_type(c::Union{Colorant, Number}) = base_colorant_type(typeof(c))

"""
    Cp = parametric_colorant(C::Type)

Return a parametric colorant type.

# Examples

```jldoctest; setup = :(using ColorTypes, ColorTypes.FixedPointNumbers)
julia> parametric_colorant(RGB)
RGB

julia> parametric_colorant(RGB{Float32})
RGB{Float32}

julia> parametric_colorant(BGR)
BGR

julia> parametric_colorant(RGB24) == RGB{N0f8}
true
```
"""
parametric_colorant(::Type{C}) where C<:Colorant = C
parametric_colorant(::Type{RGB24}) = RGB{N0f8}
parametric_colorant(::Type{Gray24}) = Gray{N0f8}
parametric_colorant(::Type{ARGB32}) = ARGB{N0f8}
parametric_colorant(::Type{AGray32}) = AGray{N0f8}

"""
    CF = floattype(C::Type)

Promote storage data type of colorant type `C` to `AbstractFloat` while keeping the
`base_colorant_type` the same.

!!! info

    Non-parametric colorants will be promoted to corresponding parametric
    colorants. For example, `floattype(RGB24) == RGB{Float32}`.
"""
floattype(::Type{T}) where T <: Colorant =
    base_colorant_type(T){floattype(eltype(T))} # 1 parameter
# 0 parameter
floattype(::Type{RGB24})   = RGB{floattype(N0f8)}
floattype(::Type{Gray24})  = Gray{floattype(N0f8)}
floattype(::Type{ARGB32})  = ARGB{floattype(N0f8)}
floattype(::Type{AGray32}) = AGray{floattype(N0f8)}

@pure pureintersect(::Type{C1}, ::Type{C2}) where {C1,C2} = typeintersect(C1, C2)

"""
    Calpha, Cbase, T = colorsplit(C)

Split a color type `C` into three components: `T` is the numeric type,
`Cbase` is the `base_color_type(C)`, and `Calpha` is one of `Nothing`
(when `C` has no transparency), `AlphaColor`, or `ColorAlpha`.

If `C` is an abstract type, `Calpha` may be `TransparentColor` or `Any`.
"""
function colorsplit(::Type{C}) where C<:Colorant
    Calpha = C <: AlphaColor ? AlphaColor :
             C <: ColorAlpha ? ColorAlpha :
             C <: Color ? Nothing :
             C <: TransparentColor ? TransparentColor : Any
    Cbase = C <: Union{Color,TransparentColor} ? base_color_type(C) : Color
    return Calpha, Cbase, eltype(C)
end

"""
    C = ccolor(Cdest, Csrc)

`ccolor` ("concrete color") supports independent selection of colorspace and
numeric element type. `ccolor` chooses the numeric element type from
`Cdest` if available, but if not specified gets it from `Csrc`.

```jldoctest; setup = :(using ColorTypes, ColorTypes.FixedPointNumbers)
julia> ccolor(RGB, Gray{Float32})
RGB{Float32}

julia> ccolor(RGB, Gray{N0f8}) == RGB{N0f8}
true

julia> ccolor(RGB{Float32}, Gray{N0f8})
RGB{Float32}
```

Some colorspaces don't support `FixedPoint` numeric element types;
in such cases the `eltype_default` for `Cdest` is chosen:

```jldoctest; setup = :(using ColorTypes, ColorTypes.FixedPointNumbers)
julia> ccolor(HSV, RGB{N0f8})
HSV{Float32}
```

`Cdest` can be an abstract type, in which case `Csrc` must be in that
abstract color space.

```jldoctest; setup = :(using ColorTypes, ColorTypes.FixedPointNumbers)
julia> ccolor(Color{Float32}, RGB{N0f8})
RGB{Float32}

julia> ccolor(AbstractRGB{Float32}, BGR{N0f8})
BGR{Float32}

julia> ccolor(AbstractRGB{Float32}, HSV{Float32})
ERROR: in ccolor, empty intersection between AbstractRGB and HSV
[...]
```
`ccolor` will throw an error when no unambiguous concrete type can be determined.
In the previous case, `AbstractRGB{Float32}` encompases `RGB{Float32}` and `BGR{Float32}`.

`ccolor` is most useful in defining other methods.
For example, to allow users to write `convert(RGB, c)` without having to specify the
numeric element type of `RGB`, define

```
convert(::Type{C}, p::Colorant) where C<:Colorant = cnvt(ccolor(C,typeof(p)), p)
```

where `cnvt` is the function that performs explicit conversion.
"""
function ccolor(::Type{Cdest}, ::Type{Csrc}) where {Cdest<:Colorant, Csrc<:Union{Number,Colorant}}
    Cdestalpha, Cdestbase, Tdest = colorsplit(Cdest)
    if Csrc <: Number
        Cdestbase <: Union{AbstractGray, AbstractRGB} || throw(ColorTypeResolutionError(:ccolor, "no automatic conversion from", Csrc, Cdestbase))
        Csrcalpha, Csrcbase, Tsrc = Any, Color, Csrc
    else
        Csrcalpha, Csrcbase, Tsrc = colorsplit(Csrc)
    end
    # Step 1: pick the base color type
    if isabstracttype(Cdestbase)
        C = pureintersect(Cdestbase, Csrcbase)
        C === Union{} && throw(ColorTypeResolutionError(:ccolor, "empty intersection between", Cdestbase, Csrcbase))
        isabstracttype(C) && throw(ColorTypeResolutionError(:ccolor, "abstract intersection between", Cdestbase, Csrcbase))
    else
        C = Cdestbase
    end
    # Step 2: combine with the alpha representation
    if Cdestalpha === Nothing
    else
        Calpha = (Cdestalpha === TransparentColor || Cdestalpha === Any) ? Csrcalpha : Cdestalpha
        Cdestalpha === TransparentColor && Calpha === Nothing && throw(ColorTypeResolutionError(:ccolor, "ambiguous alpha storage between", Cdest, Csrc))
        if Calpha !== Nothing
            Calpha === TransparentColor && throw(ColorTypeResolutionError(:ccolor, "ambiguous alpha storage between", Cdest, Csrc))
            C = Calpha <: AlphaColor ? alphacolor(C) :
                Calpha <: ColorAlpha ? coloralpha(C) : error("unexpected Calpha ", Calpha)
        end
    end
    # Step 3: assign the eltype
    if !isa(C, UnionAll)
        eltype(C) <: Tdest && return C   # RGB24 etc.
        error("nonparametric type ", C, " has ambiguous destination ", Cdest)
    end
    isabstracttype(Tdest) || !issupported(C, Tdest) || return C{Tdest}
    T = pureintersect(Tdest, Tsrc)
    T === Union{} && throw(ColorTypeResolutionError(:ccolor, "empty intersection between", Tdest, Tsrc))
    T === Any && return C
    issupported(C, T) && return C{T}
    Tdef = eltype_default(C)
    T<:Integer && return C{Tdef}
    Tf = floattype(Tsrc)
    issupported(C, Tf) && return C{Tf}
    return C{Tdef}
end

isfinite(c::Colorant) = mapreducec(isfinite, &, true, c)
isinf(c::Colorant) = mapreducec(isinf, |, false, c)
isnan(c::Colorant) = mapreducec(isnan, |, false, c)

"""
    ColorTypes.nan(C)

Return a color instance of the specified type in which all components are NaN.

# Examples
```jldoctest; setup = :(using ColorTypes)
julia> ColorTypes.nan(RGB{Float32})
RGB{Float32}(NaN, NaN, NaN)

julia> ColorTypes.nan(AHSV{Float64})
AHSV{Float64}(NaN, NaN, NaN, NaN)
```
"""
nan(::Type{T}) where {T<:AbstractFloat} = convert(T, NaN)
nan(::Type{C}) where {T<:AbstractFloat, N, C<:Colorant{T, N}} = C(ntuple(_ -> nan(T), Val(N))...)

zero(::Type{C}) where {N, C<:ColorantN{N}} = C(ntuple(_ -> 0, Val(N))...)
zero(c::Colorant) = zero(typeof(c))

oneunit(::Type{C}) where {C<:Colorant} = throw_oneunit_error(C)
@noinline function throw_oneunit_error(@nospecialize(C))
    throw(ArgumentError("`oneunit` for $C is not defined. Perhaps the meaning is not clear."))
end
oneunit(::Type{C}) where {C<:AbstractGray} = C(1)
# It's not clear what `oneunit` means for most Color3s,
# but for AbstractRGB, XYZ, and LMS, it's OK
oneunit(::Type{C}) where {C<:AbstractRGB}      = C(1, 1, 1)
oneunit(::Type{C}) where {C<:Union{XYZ, LMS}}  = C(1, 1, 1)
oneunit(::Type{C}) where {C<:TransparentColor} = C(oneunit(color_type(C)))
oneunit(::Type{C}) where {C<:Union{AGray, GrayA}} = C(1, 1) # workaround for inconsistent `color_type`
oneunit(c::Colorant) = oneunit(typeof(c))

one(::Type{C}) where {C<:Colorant} = one(eltype_default(C))
one(::Type{C}) where {T, C<:Colorant{T}} = one(T)
one(c::Colorant) = one(typeof(c))

Base.broadcastable(x::Colorant) = Ref(x)
