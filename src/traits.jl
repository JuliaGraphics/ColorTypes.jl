# Provide the field names in the order expected by the constructor
colorfields{C<:AbstractColor}(::Type{C}) = fieldnames(C)
colorfields{C<:RGB1}(::Type{C}) = (:r, :g, :b)
colorfields{C<:RGB4}(::Type{C}) = (:r, :g, :b)
colorfields{C<:BGR }(::Type{C}) = (:r, :g, :b)
colorfields{P<:Transparent}(::Type{P}) = tuple(colorfields(colortype(P))..., :alpha)
colorfields(c::Paint) = colorfields(typeof(c))

# Some of these traits exploit a nice trick: for subtypes, walk up the
# type hierarchy until we get to a stage where we can define the
# function in general

# eltype(RGB{Float32}) -> Float32
eltype{T}(  ::Type{Paint{T}})   = T
eltype{T,N}(::Type{Paint{T,N}}) = T
eltype{P<:Paint}(::Type{P}) = eltype(super(P))

if VERSION < v"0.4.0-dev"
    eltype(c::Paint) = eltype(typeof(c))
end

# colortype(AlphaColor{RGB{Ufixed8},Ufixed8}) -> RGB{Ufixed8}
# Being able to do this is one reason that C is a parameter of
# Transparent
colortype{C<:AbstractColor     }(::Type{C}) = C
colortype{P<:AlphaColor}(::Type{P}) = colortype(super(P))
colortype{P<:ColorAlpha}(::Type{P}) = colortype(super(P))
colortype{P<:Transparent       }(::Type{P}) = P.parameters[1]

colortype(c::Paint) = colortype(typeof(c))

# basecolortype(RGB{Float64}) -> RGB{T}
basecolortype{P<:Paint}(::Type{P}) = _basecolortype(colortype(P))
if VERSION < v"0.4.0-dev"
    _basecolortype{C}(::Type{C}) = eval(C.name.name)  # slow, but oh well
else
    @eval @generated function _basecolortype{C}(::Type{C})
        name = C.name.name
        :($name)
    end
end

basecolortype(c::Paint) = basecolortype(typeof(c))

# basepainttype(ARGB{Float32}) -> ARGB{T}
basepainttype{C<:AbstractColor}(::Type{C}) = basecolortype(C)
if VERSION < v"0.4.0-dev"
    basepainttype{P<:Paint}(::Type{P}) = eval(P.name.name)
else
    @eval @generated function basepainttype{P<:Paint}(::Type{P})
        name = P.name.name
        :($name)
    end
end

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
pick_eltype{C,T1<:Number,T2            }(::Type{C}, ::Type{T1}, ::Type{T2}) = T1
pick_eltype{C,T1<:Number,T2<:FixedPoint}(::Type{C}, ::Type{T1}, ::Type{T2}) = T1
pick_eltype{C,T2            }(::Type{C}, ::Any, ::Type{T2})     = T2
pick_eltype{C,T2<:FixedPoint}(::Type{C}, ::Any, ::Type{T2})     = pick_eltype_compat(C, eltype_default(C), T2)
# When T2 <: FixedPoint, choosed based on whether color type supports it
pick_eltype_compat{T1            ,T2}(::Any, ::Type{T1}, ::Type{T2}) = T1
pick_eltype_compat{T1<:FixedPoint,T2}(::Any, ::Type{T1}, ::Type{T2}) = T2

# This formulation ensures that only concrete types work
typemin{C<:AbstractRGB}(::Type{C}) = (T = eltype(C); colortype(C)(zero(T),zero(T),zero(T)))
typemax{C<:AbstractRGB}(::Type{C}) = (T = eltype(C); colortype(C)(one(T), one(T), one(T)))

### Equality
==(c1::AbstractRGB, c2::AbstractRGB) = c1.r == c2.r && c1.g == c2.g && c1.b == c2.b
