
###Colors
# should go into Colors.jl, even though these are more "hardware colortypes", these are still colors

abstract Color{T, N}        <: FixedVector{T, N}
abstract AlphaColor{T}      <: Color{T, 4}
abstract Color3{T}          <: Color{T, 3}
abstract Gray{T}            <: Color{T, 1}
abstract Intensity{T}       <: Color{T, 1}
abstract AbstractRGB{T}     <: Color3{T}


# Little-endian RGB (useful for BGRA & Cairo)
immutable BGR{T<:Fractional} <: AbstractRGB{T}
    b::T
    g::T
    r::T

    BGR(r::Real, g::Real, b::Real) = new(b, g, r)
end


# Some readers return a byte for an alpha channel even if it's not meaningful
immutable RGB1{T<:Fractional} <: AbstractRGB{T}
    alphadummy::T
    r::T
    g::T
    b::T

    RGB1(r::Real, g::Real, b::Real) = new(one(T), r, g, b)
end

immutable RGB4{T<:Fractional} <: AbstractRGB{T}
    r::T
    g::T
    b::T
    alphadummy::T

    RGB4(r::Real, g::Real, b::Real) = new(r, g, b, one(T))
end

immutable Gray{T<:Fractional} <: AbstractGray{T}
    val::T
end

immutable Gray24 <: ColorValue{Uint8}
    color::Uint32
end

immutable AGray32 <: AbstractAlphaColorValue{Gray24, Uint8}
    color::Uint32
end


# YIQ (NTSC)
immutable YIQ{T<:FloatingPoint} <: ColorValue{T}
    y::T
    i::T
    q::T

    YIQ(y::Real, i::Real, q::Real) = new(y, i, q)
end


# Y'CbCr
immutable YCbCr{T<:FloatingPoint} <: ColorValue{T}
    y::T
    cb::T
    cr::T

    YCbCr(y::Real, cb::Real, cr::Real) = new(y, cb, cr)
end


# HSI
immutable HSI{T<:FloatingPoint} <: ColorValue{T}
    h::T
    s::T
    i::T

    HSI(h::Real, s::Real, i::Real) = new(h, s, i)
end