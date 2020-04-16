# Core traits and accessor functions

"""
`alpha(p)` extracts the alpha component of a color. For a color
without an alpha channel, it will always return 1.
"""
alpha(c::TransparentColor) = c.alpha
alpha(c::Color)   = oneunit(eltype(c))
alpha(c::RGB24)   = N0f8(1)
alpha(c::ARGB32)  = N0f8((c.color & 0xff000000)>>24, 0)
alpha(c::AGray32) = N0f8((c.color & 0xff000000)>>24, 0)

"`red(c)` returns the red component of an `AbstractRGB` opaque or transparent color."
red(c::AbstractRGB   ) = c.r
red(c::TransparentRGB) = c.r
red(c::RGB24)  = N0f8((c.color & 0x00ff0000)>>16, 0)
red(c::ARGB32) = N0f8((c.color & 0x00ff0000)>>16, 0)

"`green(c)` returns the green component of an `AbstractRGB` opaque or transparent color."
green(c::AbstractRGB   ) = c.g
green(c::TransparentRGB) = c.g
green(c::RGB24)  = N0f8((c.color & 0x0000ff00)>>8, 0)
green(c::ARGB32) = N0f8((c.color & 0x0000ff00)>>8, 0)

"`blue(c)` returns the blue component of an `AbstractRGB` opaque or transparent color."
blue(c::AbstractRGB   ) = c.b
blue(c::TransparentRGB) = c.b
blue(c::RGB24)  = N0f8(c.color & 0x000000ff, 0)
blue(c::ARGB32) = N0f8(c.color & 0x000000ff, 0)

"`gray(c)` returns the gray component of a grayscale opaque or transparent color."
gray(c::Gray)    = c.val
gray(c::TransparentGray) = c.val
gray(c::Gray24)  = N0f8(c.color & 0x000000ff, 0)
gray(c::AGray32) = N0f8(c.color & 0x000000ff, 0)
gray(x::Number)  = x

"""
`chroma(c)` returns the chroma of a `Lab`, `Luv` or their variants color.
!!! note
    The other color types (e.g. `RGB`, `HSV` or `YCbCr`) are not supported
    because their definitions of *chroma* are not clear. Colorfulness, chroma
    and saturation are defined as distinct aspects by the CIE.
"""
chroma(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{Lab,DIN99,DIN99o,DIN99d}} = sqrt(c.a^2 + c.b^2)
chroma(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Luv} = sqrt(c.u^2 + c.v^2)
chroma(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{LCHab,LCHuv}} = c.c

"""
`hue(c)` returns the hue in degrees. This function does not guarantee that the
return value is in [0, 360].
"""
hue(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{HSV,HSL,HSI,LCHab,LCHuv}} = c.h
hue(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Union{Lab,DIN99,DIN99o,DIN99d}} =
    (h = atand(c.b, c.a); h < 0 ? h + 360 : h)
hue(c::Union{C,AlphaColor{C},ColorAlpha{C}}) where {C<:Luv} =
    (h = atand(c.v, c.u); h < 0 ? h + 360 : h)


# Extract the first, second, and third arguments as you'd
# pass them to the constructor
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
comp1(c::AbstractRGB) = red(c)
comp1(c::Union{AlphaColor{C},ColorAlpha{C}}) where {C<:AbstractRGB} = red(c)
comp1(c::Union{Color,ColorAlpha}) = getfield(c, 1)
comp1(c::AlphaColor) = getfield(c, 2)
comp1(c::AGray32) = gray(c)

"`comp2(c)` extracts the second constructor argument (see `comp1`)."
comp2(c::AbstractRGB) = green(c)
comp2(c::Union{AlphaColor{C},ColorAlpha{C}}) where {C<:AbstractRGB} = green(c)
comp2(c::Union{Color,ColorAlpha}) = getfield(c, 2)
comp2(c::AlphaColor) = getfield(c, 3)

"`comp3(c)` extracts the third constructor argument (see `comp1`)."
comp3(c::AbstractRGB) = blue(c)
comp3(c::Union{AlphaColor{C},ColorAlpha{C}}) where {C<:AbstractRGB} = blue(c)
comp3(c::Union{Color,ColorAlpha}) = getfield(c, 3)
comp3(c::AlphaColor) = getfield(c, 4)

"`color(c)` extracts the opaque color component from a Colorant (e.g., omits the alpha channel, if present)."
color(c::Color) = c
color(c::TransparentColor{C,T,4}) where {C,T} = C(comp1(c), comp2(c), comp3(c))
color(c::TransparentColor{C,T,2}) where {C,T} = C(comp1(c))

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# recurse up the type hierarchy until you get to Colorant{T,N} for
# specific T,N.
to_top(::Type{Colorant{T,N}}) where {T,N} = Colorant{T,N}
@pure to_top(::Type{C}) where {C<:Colorant} = to_top(supertype(C))

to_top(c::Colorant) = to_top(typeof(c))

# eltype(RGB{Float32}) -> Float32
eltype(::Type{Colorant{T}}) where {T}       = T
eltype(::Type{Colorant{T,N}}) where {T,N}   = T
@pure eltype(::Type{C}) where {C<:Colorant} = eltype(supertype(C))

eltype(c::Colorant) = eltype(typeof(c))

# eltypes_supported(Colorant{T<:X}) -> X
@pure eltypes_supported(::Type{C}) where {C<:Colorant} =
    Base.parameter_upper_bound(base_colorant_type(C), 1)
eltypes_supported(::Type{RGB24})   = N0f8
eltypes_supported(::Type{Gray24})  = N0f8
eltypes_supported(::Type{ARGB32})  = N0f8
eltypes_supported(::Type{AGray32}) = N0f8

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
color_type(::Type{C}) where {C<:AlphaColor} = color_type(supertype(C))
color_type(::Type{C}) where {C<:ColorAlpha} = color_type(supertype(C))
function color_type(::Type{TC}) where TC<:TransparentColor
    _color_type(::Type{TC}) where TC<:TransparentColor{C, T} where {C,T} = C
    return isa(TC, UnionAll) ? Base.parameter_upper_bound(TC, 1) : _color_type(TC)
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
abstract_basetype(::Type{<:ColorN{N}}) where N = ColorN{N}
abstract_basetype(::Type{<:Color}) = Color
abstract_basetype(::Type{<:AlphaColorN{N,C}}) where {N,C<:Color} = AlphaColor{base_colorant_type(C){T},T,N} where T
abstract_basetype(::Type{<:ColorAlphaN{N,C}}) where {N,C<:Color} = ColorAlpha{base_colorant_type(C){T},T,N} where T
abstract_basetype(::Type{<:AlphaColor{C}}) where {C<:Color} = AlphaColor{base_colorant_type(C){T},T} where T
abstract_basetype(::Type{<:ColorAlpha{C}}) where {C<:Color} = ColorAlpha{base_colorant_type(C){T},T} where T
abstract_basetype(::Type{<:AlphaColor}) = AlphaColor
abstract_basetype(::Type{<:ColorAlpha}) = ColorAlpha
abstract_basetype(::Type{<:TransparentColorN{N,C}}) where {N,C<:Color} = TransparentColor{base_colorant_type(C){T},T,N} where T
abstract_basetype(::Type{<:TransparentColor{C}}) where {C<:Color} = TransparentColor{base_colorant_type(C){T},T} where T
abstract_basetype(::Type{<:TransparentColor}) = TransparentColor
# These handle things like base_colorant_type(AbstractRGBA)
parameter1(::Type{C}) where C = C isa DataType ? C.parameters[1] : Base.parameter_upper_bound(C, 1)
function abstract_basetype(::Type{AC}) where AC <: AlphaColorN{N} where {N}
    Cb = parameter1(AC)
    Cb === Color && return AlphaColor{C,T,N} where {T,C<:ColorN{N-1,T}}
    isabstracttype(Cb) || return AlphaColor{Cb{T},T,N} where T
    return AlphaColor{C,T,N} where {T,C<:Cb{T}}
end
function abstract_basetype(::Type{CA}) where CA <: ColorAlphaN{N} where {N}
    Cb = parameter1(CA)
    Cb === Color && return ColorAlpha{C,T,N} where {T,C<:ColorN{N-1,T}}
    isabstracttype(Cb) || return ColorAlpha{Cb{T},T,N} where T
    return ColorAlpha{C,T,N} where {T,C<:Cb{T}}
end
function abstract_basetype(::Type{TC}) where TC <: TransparentColorN{N} where {N}
    Cb = parameter1(TC)
    Cb === Color && return TransparentColor{C,T,N} where {T,C<:ColorN{N-1,T}}
    isabstracttype(Cb) || return TransparentColor{Cb{T},T,N} where T
    return TransparentColor{C,T,N} where {T,C<:Cb{T}}
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

julia> parametric_colorant(RGB24)
RGB{Normed{UInt8,8}}
```
"""
parametric_colorant(::Type{C}) where C<:Colorant = C
parametric_colorant(::Type{RGB24}) = RGB{N0f8}
parametric_colorant(::Type{Gray24}) = Gray{N0f8}
parametric_colorant(::Type{ARGB32}) = ARGB{N0f8}
parametric_colorant(::Type{AGray32}) = AGray{N0f8}

"""
    floattype(::Type{T}) where T<:Colorant

Promote storage data type of colorant `T` to `AbstractFloat` while keep the
`base_colorant_type` the same.

!!! info

    Non-parametric colorants will be promote to corresponding parametric
    colorants. For example, `floattype(RGB24) == RGB{Float32}`
"""
floattype(::Type{T}) where T <: Colorant =
    base_colorant_type(T){floattype(eltype(T))} # 1 parameter
# 0 parameter
floattype(::Type{RGB24}) = RGB{Float32}
floattype(::Type{Gray24}) = Gray{Float32}
floattype(::Type{ARGB32}) = ARGB{Float32}
floattype(::Type{AGray32}) = AGray{Float32}


@pure pureintersect(::Type{C1}, ::Type{C2}) where {C1,C2} = typeintersect(C1, C2)

"""
    Calpha, Cbase, T = colorsplit(C)

Split a color type `C` into three components: `T` is the numeric eltype,
`Cbase` is the `base_color_type(C)`, and `wrap` is one of `identity`, `coloralpha`,
or `alphacolor`.
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

julia> ccolor(RGB, Gray{N0f8})
RGB{Normed{UInt8,8}}

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

### Equality
function ==(c1::AbstractRGB, c2::AbstractRGB)
    red(c1) == red(c2) && green(c1) == green(c2) && blue(c1) == blue(c2)
end
==(c1::HSV, c2::HSV) = c1.h == c2.h && c1.s == c2.s && c1.v == c2.v
==(c1::HSI, c2::HSI) = c1.h == c2.h && c1.s == c2.s && c1.i == c2.i
==(c1::HSL, c2::HSL) = c1.h == c2.h && c1.s == c2.s && c1.l == c2.l
==(c1::XYZ, c2::XYZ) = c1.x == c2.x && c1.y == c2.y && c1.z == c2.z
==(c1::xyY, c2::xyY) = c1.x == c2.x && c1.y == c2.y && c1.Y == c2.Y
==(c1::Lab, c2::Lab) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::Luv, c2::Luv) = c1.l == c2.l && c1.u == c2.u && c1.v == c2.v
==(c1::LCHab, c2::LCHab) = c1.l == c2.l && c1.c == c2.c && c1.h == c2.h
==(c1::LCHuv, c2::LCHuv) = c1.l == c2.l && c1.c == c2.c && c1.h == c2.h
==(c1::DIN99, c2::DIN99) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::DIN99d, c2::DIN99d) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::DIN99o, c2::DIN99o) = c1.l == c2.l && c1.a == c2.a && c1.b == c2.b
==(c1::LMS, c2::LMS) = c1.l == c2.l && c1.m == c2.m && c1.s == c2.s
==(c1::YIQ, c2::YIQ) = c1.y == c2.y && c1.i == c2.i && c1.q == c2.q
==(c1::YCbCr, c2::YCbCr) = c1.y == c2.y && c1.cb == c2.cb && c1.cr == c2.cr

==(x::AbstractGray, y::AbstractGray) = gray(x) == gray(y)
==(x::Number, y::AbstractGray) = x == gray(y)
==(x::AbstractGray, y::Number) = ==(y, x)

function ==(x::TransparentColor, y::TransparentColor)
    color(x) == color(y) && alpha(x) == alpha(y)
end


struct BoolTuple end
@inline BoolTuple(args::Bool...) = (args...,)

function _isapprox(a::Colorant, b::Colorant; kwargs...)
    componentapprox(x, y) = isapprox(x, y; kwargs...)
    all(ColorTypes._mapc(BoolTuple, componentapprox, a, b))
end
isapprox(a::C, b::C; kwargs...) where {C<:Colorant} =
    _isapprox(a, b; kwargs...)
isapprox(a::Colorant, b::Colorant; kwargs...) =
    _isapprox(base_colorant_type(a), base_colorant_type(b), a, b; kwargs...)
_isapprox(::Type{C}, ::Type{C}, a, b; kwargs...) where {C<:Colorant} =
    _isapprox(a, b; kwargs...)
_isapprox(::Type{<:AbstractRGB}, ::Type{<:AbstractRGB}, a, b; kwargs...) =
    _isapprox(RGB(a), RGB(b); kwargs...)
_isapprox(::Type{<:AbstractGray}, ::Type{<:AbstractGray}, a, b; kwargs...) =
    isapprox(gray(a), gray(b); kwargs...)
_isapprox(TA::Type, TB::Type, a, b; kwargs...) = false
isapprox(x::Number, y::AbstractGray; kwargs...) =
    isapprox(x, gray(y); kwargs...)
isapprox(x::AbstractGray, y::Number; kwargs...) =
    isapprox(y, x; kwargs...)


zero(::Type{C}) where {C<:Gray} = C(0)
oneunit(::Type{C}) where {C<:Gray} = C(1)

function Base.one(::Type{C}) where {C<:Gray}
    Base.depwarn("one($C) will soon switch to returning 1; you might need to switch to `oneunit`", :one)
    C(1)
end

Base.broadcastable(x::Colorant) = Ref(x)

Base.isless(a::AbstractGray, b::AbstractGray) =
    isless(gray(a), gray(b))
