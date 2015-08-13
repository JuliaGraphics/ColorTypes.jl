# These traits exploit a nice trick: for subtypes, walk up the type
# hierarchy until we get to a stage where we can define the function
# in general

# eltype(RGB{Float32}) -> Float32
eltype{T}(  ::Type{Paint{T}})   = T
eltype{T,N}(::Type{Paint{T,N}}) = T
eltype{P<:Paint}(::Type{P}) = eltype(super(P))

# colortype(AlphaColor{RGB{Ufixed8},Ufixed8}) -> RGB{Ufixed8}
# Being able to do this is one reason that C is a parameter of
# Transparent
#colortype(P::TypeConstructor) = basecolortype(P.body.parameters[1]) # colortype(ARGB)
colortype{C<:AbstractColor    }(::Type{C})                  = C
colortype{P<:AbstractAlphaColor}(::Type{P}) = colortype(super(P))
colortype{P<:AbstractColorAlpha}(::Type{P}) = colortype(super(P))
colortype{P<:Transparent}(::Type{P}) = P.parameters[1]

colortype(c::Paint) = colortype(typeof(c))

# basecolortype(RGB{Float64}) -> RGB{T}
#basecolortype(P::TypeConstructor) = colortype(P)
basecolortype{P<:Paint}(::Type{P}) = _basecolortype(colortype(P))
@generated function _basecolortype{C}(::Type{C})
    name = C.name.name
    :($name)
end

basecolortype(c::Paint) = basecolortype(typeof(c))

# basepainttype(ARGB{Float32}) -> ARGB{T}
#basepainttype(P::TypeConstructor) = P
basepainttype{C<:AbstractColor}(::Type{C}) = basecolortype(C)
@generated function basepainttype{P<:Paint}(::Type{P})
    name = symbol(paint_string(P))
    :($name)
end

basepainttype(c::Paint) = basepainttype(typeof(c))

paint_string{P<:Paint}(::Type{P}) = string(P.name.name)

# paint_string{C<:AbstractColor}(::Type{C}) = string(C.name.name)
# paint_string(P::TypeConstructor) = paint_string(P.body)
# paint_string{P<:AlphaColor}(::Type{P}) = string("A", basecolortype(P))
# paint_string{P<:ColorAlpha}(::Type{P}) = string(basecolortype(P), "A")
# paint_string{P<:Gray}(::Type{P}) = "Gray"
# paint_string{P<:AlphaGray}(::Type{P}) = "AlphaGray"
# paint_string{P<:GrayAlpha}(::Type{P}) = "GrayAlpha"

"""
 `ccolor` ("concrete color") helps write flexible methods. The
idea is that users may write `convert(HSV, c)` or even
`convert(Array{HSV}, A)` without specifying the element type
explicitly (e.g., `convert(HSV{Float32}, c)`). `ccolor`
implements the logic "choose the user's eltype if specified,
otherwise retain the eltype of the source object."

Note that in some cases you may have to supply the element type
directly; e.g., `HSV` supports `Float32` but not `U8`, so
`convert(HSV, c::RGB{U8})` will fail. We could automatically pick
`Float32` in such cases, but one worries whether it might be too
magical.

Usage:
    ccolor(desttype, srctype) -> concrete desttype

Example:
    convert{P<:Paint}(::Type{P}, p::Paint) = cnvt(ccolor(P,typeof(p)), p)

where `cnvt` is the function that performs explicit conversion.
"""
#ccolor{Psrc<:Paint}(Pdest::TypeConstructor, ::Type{Psrc}) = basepainttype(Pdest){pick_eltype(eltype(Pdest), eltype(Psrc))}
ccolor{Pdest<:Paint,Psrc<:Paint}(::Type{Pdest}, ::Type{Psrc}) = basepainttype(Pdest){pick_eltype(eltype(Pdest), eltype(Psrc))}
pick_eltype{T1<:Number,T2}(::Type{T1}, ::Type{T2}) = T1
pick_eltype{T2}(::Any, ::Type{T2})                 = T2

supports_fixed{C<:AbstractRGB}(::Type{C}) = true
supports_fixed{C<:Gray}(::Type{C}) = true
supports_fixed{C<:AbstractColor}(::Type{C}) = false
supports_fixed{P<:Paint}(::Type{P}) = supports_fixed(colortype(P))

# This formulation ensures that only concrete types work
typemin{C<:AbstractRGB}(::Type{C}) = (T = eltype(C); colortype(C)(zero(T),zero(T),zero(T)))
typemax{C<:AbstractRGB}(::Type{C}) = (T = eltype(C); colortype(C)(one(T), one(T), one(T)))
