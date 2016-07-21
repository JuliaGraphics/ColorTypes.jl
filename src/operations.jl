# rand
import Base.rand

typealias RandTypes{T,C} Union{AbstractRGB{T},
                               TransparentRGB{C,T},
                               AbstractGray{T},
                               TransparentGray{C,T}}
typealias RandTypesFloat{C,T<:AbstractFloat} RandTypes{T,C}

rand{G<:AbstractGray}(::Type{G}) = G(rand())
rand{G<:TransparentGray}(::Type{G}) = G(rand(), rand())
rand{C<:AbstractRGB}(::Type{C}) = C(rand(), rand(), rand())
rand{C<:TransparentRGB}(::Type{C}) = C(rand(), rand(), rand(), rand())
function rand{C<:RandTypesFloat}(::Type{C}, sz::Dims)
    reinterpret(C, rand(eltype(C), (sizeof(C)÷sizeof(eltype(C)), sz...)), sz)
end
function rand{C<:RandTypes{U8}}(::Type{C}, sz::Dims)
    reinterpret(C, rand(UInt8, (sizeof(C), sz...)), sz)
end
function rand{C<:RandTypes{U16}}(::Type{C}, sz::Dims)
    reinterpret(C, rand(UInt16, (sizeof(C)>>1, sz...)), sz)
end
