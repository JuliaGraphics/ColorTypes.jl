# These traits exploit a nice trick: for subtypes, walk up the type
# hierarchy until we get to a stage where we can define the function
# in general

# eltype(RGB{Float32}) -> Float32
eltype{T}(  ::Type{Paint{T}})   = T
eltype{T,N}(::Type{Paint{T,N}}) = T
eltype{P<:Paint}(::Type{P}) = eltype(super(P))
# # The problem with the above definitions is they can lose
# # type information for non-concrete types: eltype(RGB) -> Any
# # This definition returns the appropriately-bounded TypeVar
# @generated function eltype{P<:Paint}(::Type{P})
#     T = P.parameters[1]
#     :($T)
# end

# colortype(AlphaColor{RGB{Ufixed8},Ufixed8}) -> RGB{Ufixed8}
# Being able to do this is one reason that C is a parameter of
# Transparent
colortype{C<:AbstractColor    }(::Type{C})                  = C
colortype{C<:AbstractColor    }(::Type{Transparent{C}})     = C
colortype{C<:AbstractColor,T  }(::Type{Transparent{C,T}})   = C
colortype{C<:AbstractColor,T,N}(::Type{Transparent{C,T,N}}) = C
colortype{P<:Transparent}(::Type{P}) = colortype(super(P))
colortype(c::Paint) = colortype(typeof(c))

# basecolortype(RGB{Float64}) -> RGB{T}
basecolortype{P<:Paint}(::Type{P}) = _basecolortype(colortype(P))
@generated function _basecolortype{C}(::Type{C})
    name = C.name.name
    :($name)
end

# This formulation ensures that only concrete types work
typemin{C<:AbstractRGB}(::Type{C}) = (T = eltype(C); colortype(C)(zero(T),zero(T),zero(T)))
typemax{C<:AbstractRGB}(::Type{C}) = (T = eltype(C); colortype(C)(one(T),one(T),one(T)))
