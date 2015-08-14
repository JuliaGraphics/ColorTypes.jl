using ColorTypes, FixedPointNumbers
using Base.Test

@test eltype(Paint{U8}) == U8
@test eltype(RGB{Float32}) == Float32
@test eltype(RGBA{Float64}) == Float64
# @test eltype(RGB) == TypeVar(:T, Fractional)
eltype(RGB)      # just test that it doesn't error

@test colortype(RGB{U8}) == RGB{U8}
@test colortype(RGB) == RGB
@test colortype(RGBA{Float32}) == RGB{Float32}
@test colortype(GrayA{U8}) == Gray{U8}
@test colortype(RGBA) == RGB
@test colortype(RGB24)  == RGB24
@test colortype(ARGB32) == RGB24
@test colortype(Transparent{RGB}) == RGB
@test colortype(Transparent{RGB,Float64}) == RGB
@test colortype(Transparent{RGB{Float64},Float64}) == RGB{Float64}
@test colortype(Transparent) <: AbstractColor
@test AbstractColor <: colortype(Transparent)
@test_throws MethodError colortype(Paint{U8})

@test basecolortype(RGBA{Float32}) == RGB
@test basecolortype(ARGB{Float32}) == RGB
@test basecolortype(BGR{U8})       == BGR
@test basecolortype(HSV)  == HSV
@test basecolortype(HSVA) == HSV
@test basecolortype(Transparent{RGB{Float64},Float64}) == RGB

@test basepainttype(RGBA{Float32}) == RGBA
@test basepainttype(ARGB{Float32}) == ARGB
@test basepainttype(BGR{U8})       == BGR
@test basepainttype(HSV)  == HSV
@test basepainttype(HSVA) == HSVA

@test ccolor(RGB{Float32}, HSV{Float32}) == RGB{Float32}
@test ccolor(RGB{U8},      HSV{Float32}) == RGB{U8}
@test ccolor(RGB,          HSV{Float32}) == RGB{Float32}
@test ccolor(ARGB{Float32}, HSV{Float32}) == ARGB{Float32}
@test ccolor(ARGB{U8},      HSV{Float32}) == ARGB{U8}
@test ccolor(ARGB,          HSV{Float32}) == ARGB{Float32}

# Traits for instances (and their constructors)
@test eltype(RGB{U8}(1,0,0)) == U8
@test eltype(RGB(1.0,0,0)) == Float64
@test eltype(ARGB(1.0,0.8,0.6,0.4)) == Float64
@test eltype(RGBA{Float32}(1.0,0.8,0.6,0.4)) == Float32
@test eltype(RGB(0x01,0x00,0x00)) == U8

@test colortype(RGB{U8}(1,0,0)) == RGB{U8}
@test colortype(ARGB(1.0,0.8,0.6,0.4)) == RGB{Float64}
@test colortype(RGBA{Float32}(1.0,0.8,0.6,0.4)) == RGB{Float32}

@test basecolortype(RGB{U8}(1,0,0)) == RGB
@test basecolortype(ARGB(1.0,0.8,0.6,0.4)) == RGB
@test basecolortype(RGBA{Float32}(1.0,0.8,0.6,0.4)) == RGB

@test basepainttype(RGB{U8}(1,0,0)) == RGB
@test basepainttype(ARGB(1.0,0.8,0.6,0.4)) == ARGB
@test basepainttype(RGBA{Float32}(1.0,0.8,0.6,0.4)) == RGBA

# Constructors
for C in ColorTypes.parametric
    @test eltype(C{Float32}) == Float32
    et = (C <: AbstractRGB) ? U8 : Float32
    @test eltype(C(1,0,0)) == et
    @test colortype(C(1,0,0)) == C{et}
    @test colortype(C) == C
    @test colortype(C{Float32}) == C{Float32}
end

# Specifically test the AbstractRGB types
# This checks that the constructor order is the same, even if the
# storage order is not
for C in subtypes(AbstractRGB)
    c = C(1, 0.5, 0)
    @test c.r == 1
    @test c.g == 0.5
    @test c.b == 0
end

# Transparency
for C in setdiff(ColorTypes.parametric, [RGB1,RGB4])
    for A in (alphacolor(C), coloralpha(C))
        @test eltype(A{Float32}) == Float32
        @test colortype(A) == C
        @test colortype(A{Float32}) == C{Float32}
        c = A{Float64}(1,0.8,0.6,0.4)
        @test colortype(c) == C{Float64}
        cc = Color(c)
        @test cc == C{Float64}(1,0.8,0.6)
        @test A(cc) == A{Float64}(1,0.8,0.6,1)
        @test A(cc, 0.4)  == c
        @test A(cc, 0x01) == A{Float64}(1,0.8,0.6,1)
        @test A{Float32}(cc, 0x01) == A{Float32}(1,0.8,0.6,1)
        @test C(c) == C{Float64}(1,0.8,0.6)
        @test C{Float32}(c) == C{Float32}(1,0.8,0.6)
    end
end

iob = IOBuffer()
c = RGB{U8}(0.32218,0.14983,0.87819)
show(iob, c)
@test takebuf_string(iob) == "RGB{U8}(0.322,0.149,0.878)"
c = RGB{Ufixed16}(0.32218,0.14983,0.87819)
show(iob, c)
@test takebuf_string(iob) == "RGB{Ufixed16}(0.32218,0.14983,0.87819)"
c = RGBA{Ufixed8}(0.32218,0.14983,0.87819,0.99241)
show(iob, c)
@test takebuf_string(iob) == "RGBA{U8}(0.322,0.149,0.878,0.992)"
