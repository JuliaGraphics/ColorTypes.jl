using ColorTypes, FixedPointNumbers, Compat
using Base.Test

if VERSION < v"0.4.0-dev"
    macro infrd(ex)
        ex
    end
else
    macro infrd(ex)
        Expr(:macrocall, symbol("@inferred"), ex)
    end
end

@test @infrd(eltype(Paint{U8})) == U8
@test @infrd(eltype(RGB{Float32})) == Float32
@test @infrd(eltype(RGBA{Float64})) == Float64
# @test eltype(RGB) == TypeVar(:T, Fractional)
@infrd(eltype(RGB))      # just test that it doesn't error

@test length(RGB)    == 3
@test length(RGB1)   == 3
@test length(Gray)   == 1
@test length(ARGB)   == 4
@test length(RGB24)  == 3
@test length(ARGB32) == 4
@test length(AGray{Float32}) == 2

@test @infrd(colortype(RGB{U8})) == RGB{U8}
@test @infrd(colortype(RGB)) == RGB
@test @infrd(colortype(RGBA{Float32})) == RGB{Float32}
@test @infrd(colortype(GrayA{U8})) == Gray{U8}
@test @infrd(colortype(RGBA)) == RGB
@test @infrd(colortype(RGB24) ) == RGB24
@test @infrd(colortype(ARGB32)) == RGB24
@test @infrd(colortype(Transparent{RGB})) == RGB
@test @infrd(colortype(Transparent{RGB,Float64})) == RGB
@test @infrd(colortype(Transparent{RGB{Float64},Float64})) == RGB{Float64}
@test colortype(Transparent) <: AbstractColor
@test AbstractColor <: colortype(Transparent)
@test_throws MethodError colortype(Paint{U8})

@test @infrd(basecolortype(RGBA{Float32})) == RGB
@test @infrd(basecolortype(ARGB{Float32})) == RGB
@test @infrd(basecolortype(BGR{U8})      ) == BGR
@test @infrd(basecolortype(HSV) ) == HSV
@test @infrd(basecolortype(HSVA)) == HSV
@test @infrd(basecolortype(Transparent{RGB{Float64},Float64})) == RGB

@test @infrd(basepainttype(RGBA{Float32})) == RGBA
@test @infrd(basepainttype(ARGB{Float32})) == ARGB
@test @infrd(basepainttype(BGR{U8})      ) == BGR
@test @infrd(basepainttype(HSV) ) == HSV
@test @infrd(basepainttype(HSVA)) == HSVA

@test @infrd(ccolor(RGB{Float32}, HSV{Float32})) == RGB{Float32}
@test @infrd(ccolor(RGB{U8},      HSV{Float32})) == RGB{U8}
@test @infrd(ccolor(RGB,          HSV{Float32})) == RGB{Float32}
@test @infrd(ccolor(ARGB{Float32}, HSV{Float32})) == ARGB{Float32}
@test @infrd(ccolor(ARGB{U8},      HSV{Float32})) == ARGB{U8}
@test @infrd(ccolor(ARGB,          HSV{Float32})) == ARGB{Float32}

# Traits for instances (and their constructors)
@test @infrd(eltype(RGB{U8}(1,0,0))) == U8
@test @infrd(eltype(RGB(1.0,0,0))) == Float64
@test @infrd(eltype(ARGB(1.0,0.8,0.6,0.4))) == Float64
@test @infrd(eltype(RGBA{Float32}(1.0,0.8,0.6,0.4))) == Float32
@test @infrd(eltype(RGB(0x01,0x00,0x00))) == U8

@test length(ARGB(1.0,0.8,0.6,0.4)) == 4

@test @infrd(colortype(RGB{U8}(1,0,0))) == RGB{U8}
@test @infrd(colortype(ARGB(1.0,0.8,0.6,0.4))) == RGB{Float64}
@test @infrd(colortype(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGB{Float32}

@test @infrd(basecolortype(RGB{U8}(1,0,0))) == RGB
@test @infrd(basecolortype(ARGB(1.0,0.8,0.6,0.4))) == RGB
@test @infrd(basecolortype(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGB

@test @infrd(basepainttype(RGB{U8}(1,0,0))) == RGB
@test @infrd(basepainttype(ARGB(1.0,0.8,0.6,0.4))) == ARGB
@test @infrd(basepainttype(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGBA

# Constructors
for C in ColorTypes.parametric
    @test eltype(C{Float32}) == Float32
    et = (C <: AbstractRGB) ? U8 : Float32
    @test eltype(C(1,0,0)) == et
    @test colortype(C(1,0,0)) == C{et}
    @test colortype(C) == C
    @test colortype(C{Float32}) == C{Float32}
    @test eltype(C{Float32}(1,0,0)) == Float32
end

# Specifically test the AbstractRGB types
# This checks that the constructor order is the same, even if the
# storage order is not
for C in subtypes(AbstractRGB)
    c = C(1, 0.5, 0)
    C == RGB24 && continue
    @test red(c)   == c.r == 1
    @test green(c) == c.g == 0.5
    @test blue(c)  == c.b == 0
end

# Transparency
for C in setdiff(ColorTypes.parametric, [RGB1,RGB4])
    for A in (alphacolor(C), coloralpha(C))
        @test eltype(A{Float32}) == Float32
        @test colortype(A) == C
        @test colortype(A{Float32}) == C{Float32}
        @test eltype(A(1,0.8,0.6,0.4)) == Float64
        c = A{Float64}(1,0.8,0.6,0.4)
        @test colortype(c) == C{Float64}
        cc = color(c)
        @test cc == C{Float64}(1,0.8,0.6)
        if VERSION >= v"0.4.0-dev"
            @test A(cc) == A{Float64}(1,0.8,0.6,1)
            @test A(cc, 0.4)  == c
            @test A(cc, 0x01) == A{Float64}(1,0.8,0.6,1)
            @test A{Float32}(cc, 0x01) == A{Float32}(1,0.8,0.6,1)
            @test C(c         ) == C{Float64}(1,0.8,0.6)
            @test C{Float32}(c) == C{Float32}(1,0.8,0.6)
        end
        @test convert(A, cc) == A{Float64}(1,0.8,0.6,1)
        @test convert(A, cc, 0.4)  == c
        @test convert(A, cc, 0x01) == A{Float64}(1,0.8,0.6,1)
        @test convert(A{Float32}, cc, 0x01) == A{Float32}(1,0.8,0.6,1)
        @test convert(C,          c) == C{Float64}(1,0.8,0.6)
        @test convert(C{Float32}, c) == C{Float32}(1,0.8,0.6)
    end
end
ac = ARGB32(rand(UInt32))
@test convert(ARGB32, ac) == ac
c = convert(RGB24, ac)
@test convert(RGB24, c) == c
@test red(c)   == red(ac)
@test green(c) == green(ac)
@test blue(c)  == blue(ac)
ac2 = convert(ARGB32, c)
@test ac2.color == (c.color | 0xff000000)
@test color(c) == c
@test color(ac) == c
@test alpha(c) == U8(1)
@test alpha(ac) == Ufixed8(ac.color>>24, 0)
@test alpha(ac2) == U8(1)
@test convert(RGB24,  0xff020304).color == 0xff020304
@test convert(ARGB32, 0x01020304).color == 0x01020304
ac3 = convert(RGBA, ac)
@test convert(RGB24, ac3) == c

for C in subtypes(AbstractRGB)
    rgb = convert(C, c)
    C == RGB24 && continue
    argb = convert(alphacolor(C), ac)
    @test rgb.r == red(c)
    @test rgb.g == green(c)
    @test rgb.b == blue(c)
    @test argb.alpha == alpha(ac)
    @test argb.r == red(ac)
    @test argb.g == green(ac)
    @test argb.b == blue(ac)
end

@test Gray{U8}(0.37).val           == U8(0.37)
@test convert(Gray{U8}, 0.37).val  == U8(0.37)
@test Gray24(0x0duf8).color           == 0x000d0d0d
@test convert(Gray24, 0x0duf8).color  == 0x000d0d0d
@test AGray32(0x0duf8).color          == 0xff0d0d0d
@test convert(AGray32, 0x0duf8).color == 0xff0d0d0d
@test AGray32(0x0duf8, 0x80uf8).color    == 0x800d0d0d
@test convert(Gray{Ufixed16}, Gray24(0x0duf8)) == Gray{Ufixed16}(0.05098)

iob = IOBuffer()
cf = RGB{Float32}(0.32218,0.14983,0.87819)
c  = convert(RGB{U8}, cf)
show(iob, c)
@test takebuf_string(iob) == "RGB{U8}(0.322,0.149,0.878)"
c = RGB{Ufixed16}(0.32218,0.14983,0.87819)
show(iob, c)
@test takebuf_string(iob) == "RGB{Ufixed16}(0.32218,0.14983,0.87819)"
c = RGBA{Ufixed8}(0.32218,0.14983,0.87819,0.99241)
show(iob, c)
@test takebuf_string(iob) == "RGBA{U8}(0.322,0.149,0.878,0.992)"
show(iob, cf)
@test takebuf_string(iob) == "RGB{Float32}(0.32218f0,0.14983f0,0.87819f0)"
showcompact(iob, cf)
@test takebuf_string(iob) == "RGB{Float32}(0.32218,0.14983,0.87819)"

c = Gray(0.8)
show(iob, c)
@test takebuf_string(iob) == "Gray{Float64}(0.8)"
show(iob, AGray(0.8))
@test takebuf_string(iob) == "AGray{Float64}(0.8,1.0)"
