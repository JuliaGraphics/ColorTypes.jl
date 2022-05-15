# test helpers
module CustomTypes

using ColorTypes
using ColorTypes.FixedPointNumbers

export C2, C2A, C4, AC4
export StrangeGray, Cyanotype
export AnaglyphColor, CMYK, ACMYK

struct C2{T <: Real} <: Color{T,2}
    c1::T
    c2::T
end

struct C2A{T} <: ColorAlpha{C2{T},T,3} # T should be <: Real
    c1::T
    c2::T
    alpha::T
end
ColorTypes.coloralpha(::Type{<:C2}) = C2A

struct C4{T <: Real} <: Color{T,4}
    c1::T
    c2::T
    c3::T
    c4::T
end
ColorTypes.eltype_default(::Type{<:C4}) = Int16

struct AC4{T <: Real} <: AlphaColor{C4{T},T,5}
    alpha::T
    c1::T
    c2::T
    c3::T
    c4::T
    AC4{T}(c1::T, c2::T, c3::T, c4::T, alpha::T=oneunit(T)) where {T} = new{T}(alpha, c1, c2, c3, c4)
end
ColorTypes.alphacolor(::Type{<:C4}) = AC4
ColorTypes.eltype_default(::Type{<:AC4}) = Int16
# TODO: The following should be generated automatically
AC4{T}(c1, c2, c3, c4, alpha=1) where {T} = AC4{T}(T(c1), T(c2), T(c3), T(c4), T(alpha))

struct StrangeGray{Something,T <: Integer} <: AbstractGray{Normed{T}}
    val::T
    function StrangeGray{T}(g::Normed{T,f}) where {T,f}
        f == sizeof(T) || error()
        new{:X,T}(reinterpret(g))
    end
end
ColorTypes.gray(g::StrangeGray{X,T}) where {X, T} = reinterpret(Normed{T,sizeof(T)}, g.val)

# non-gray color with a single component
struct Cyanotype{T <: Real} <: Color{T,1}
   value::T
end

function Base.convert(::Type{Cout}, c::C) where {Cout <: AbstractRGB, T, C <: Cyanotype{T}}
    r = max(1 - 1.5 * c.value, 0)
    g = 0.98 - 0.7 * c.value
    b = 0.88 - 0.5 * c.value^2
    Cout(T(r), T(g), T(b))
end

# minimal type for testing 2-component color
struct AnaglyphColor{T} <: Color{T,2} # not `TransparentGray`
    left::T
    right::T
end

# minimal type for testing 4-component color
struct CMYK{T <: Fractional} <: Color{T,4} # not `Transparent3`
    c::T
    m::T
    y::T
    k::T
    CMYK{T}(c::T, m::T, y::T, k::T) where {T} = new{T}(c, m, y, k)
end
# TODO: The following should be generated automatically
CMYK{T}(c, m, y, k) where {T} = CMYK{T}(T(c), T(m), T(y), T(k))

ColorTypes.eltype_default(::Type{<:CMYK}) = N0f8
Base.oneunit(::Type{C}) where {C <: CMYK} = (isconcretetype(C) ? C : C{N0f8})(1, 1, 1, 1)

# minimal type for testing 5-component color
struct ACMYK{T <: Fractional} <: AlphaColor{CMYK{T},T,5}
    alpha::T
    c::T
    m::T
    y::T
    k::T
    ACMYK{T}(c::T, m::T, y::T, k::T, alpha::T=oneunit(T)) where {T} = new{T}(alpha, c, m, y, k)
end
# TODO: The following should be generated automatically
ACMYK{T}(c, m, y, k, alpha=1) where {T} = ACMYK{T}(T(c), T(m), T(y), T(k), T(alpha))
ACMYK(c::T, m::T, y::T, k::T, alpha::T=oneunit(T)) where {T} = ACMYK{T}(c, m, y, k, alpha)
ACMYK{T}(col::CMYK{T}, alpha::T=oneunit(T)) where {T} = ACMYK{T}(col.c, col.m, col.y, col.k, alpha)
end # module
