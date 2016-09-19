using ColorTypes, FixedPointNumbers
using Base.Test

@test ColorTypes.to_top(AGray32(.8)) == ColorTypes.Colorant{FixedPointNumbers.UFixed{UInt8,8},2}
@test @inferred(eltype(Color{U8})) == U8
@test @inferred(eltype(RGB{Float32})) == Float32
@test @inferred(eltype(RGBA{Float64})) == Float64
# @test eltype(RGB) == TypeVar(:T, Fractional)
@inferred(eltype(RGB))      # just test that it doesn't error

@test length(RGB)    == 3
@test length(RGB1)   == 3
@test length(Gray)   == 1
@test length(ARGB)   == 4
@test length(RGB24)  == 3
@test length(ARGB32) == 4
@test length(AGray{Float32}) == 2

@test @inferred(color_type(RGB{U8})) == RGB{U8}
@test @inferred(color_type(RGB)) == RGB
@test @inferred(color_type(RGBA{Float32})) == RGB{Float32}
@test @inferred(color_type(GrayA{U8})) == Gray{U8}
@test @inferred(color_type(RGBA)) == RGB
@test @inferred(color_type(RGB24) ) == RGB24
@test @inferred(color_type(ARGB32)) == RGB24
@test @inferred(color_type(TransparentColor{RGB})) == RGB
@test @inferred(color_type(TransparentColor{RGB,Float64})) == RGB
@test @inferred(color_type(TransparentColor{RGB{Float64},Float64})) == RGB{Float64}
@test color_type(TransparentColor) <: Color
@test Color <: color_type(TransparentColor)
@test_throws MethodError color_type(Colorant{U8})

@test @inferred(base_color_type(RGBA{Float32})) == RGB
@test @inferred(base_color_type(ARGB{Float32})) == RGB
@test @inferred(base_color_type(BGR{U8})      ) == BGR
@test @inferred(base_color_type(HSV) ) == HSV
@test @inferred(base_color_type(HSVA)) == HSV
@test @inferred(base_color_type(TransparentColor{RGB{Float64},Float64})) == RGB

@test @inferred(base_colorant_type(RGBA{Float32})) == RGBA
@test @inferred(base_colorant_type(ARGB{Float32})) == ARGB
@test @inferred(base_colorant_type(BGR{U8})      ) == BGR
@test @inferred(base_colorant_type(HSV) ) == HSV
@test @inferred(base_colorant_type(HSVA)) == HSVA

@test @inferred(ccolor(Colorant{U8,3}, BGR{U8})) == BGR{U8}

@test @inferred(ccolor(RGB{Float32}, HSV{Float32})) == RGB{Float32}
@test @inferred(ccolor(RGB{U8},      HSV{Float32})) == RGB{U8}
@test @inferred(ccolor(RGB,          HSV{Float32})) == RGB{Float32}
@test @inferred(ccolor(ARGB{Float32}, HSV{Float32})) == ARGB{Float32}
@test @inferred(ccolor(ARGB{U8},      HSV{Float32})) == ARGB{U8}
@test @inferred(ccolor(ARGB,          HSV{Float32})) == ARGB{Float32}

@test @inferred(ccolor(Gray{U8}, Bool)) === Gray{U8}
@test @inferred(ccolor(Gray,     Bool)) === Gray{Bool}

@test @inferred(ccolor(RGB,  RGB))  === RGB
@test @inferred(ccolor(Gray, Gray)) === Gray

# Traits for instances (and their constructors)
@test @inferred(eltype(RGB{U8}(1,0,0))) == U8
@test @inferred(eltype(RGB(1.0,0,0))) == Float64
@test @inferred(eltype(ARGB(1.0,0.8,0.6,0.4))) == Float64
@test @inferred(eltype(RGBA{Float32}(1.0,0.8,0.6,0.4))) == Float32
@test @inferred(eltype(RGB(0x01,0x00,0x00))) == U8

@test length(ARGB(1.0,0.8,0.6,0.4)) == 4

@test @inferred(color_type(RGB{U8}(1,0,0))) == RGB{U8}
@test @inferred(color_type(ARGB(1.0,0.8,0.6,0.4))) == RGB{Float64}
@test @inferred(color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGB{Float32}

@test @inferred(base_color_type(RGB{U8}(1,0,0))) == RGB
@test @inferred(base_color_type(ARGB(1.0,0.8,0.6,0.4))) == RGB
@test @inferred(base_color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGB

@test @inferred(base_colorant_type(RGB{U8}(1,0,0))) == RGB
@test @inferred(base_colorant_type(ARGB(1.0,0.8,0.6,0.4))) == ARGB
@test @inferred(base_colorant_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGBA

# Constructors
@test eltype(Gray()) == U8
@test Gray(Gray()) == Gray()  # no StackOverflowError
for C in ColorTypes.parametric3
    @test eltype(C{Float32}) == Float32
    et = (C <: AbstractRGB) ? U8 : Float32
    @test eltype(C(1,0,0)) == et
    @test color_type(C(1,0,0)) == C{et}
    @test color_type(C) == C
    @test color_type(C{Float32}) == C{Float32}
    @test eltype(C{Float32}(1,0,0)) == Float32
    @test C(C()) == C()  # no StackOverflowError
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

c = Gray(0.8)
@test gray(c) == 0.8
@test gray(0.8) == 0.8
c = convert(Gray, 0.8)
@test c === Gray{Float64}(0.8)

c = AGray(0.8)
@test gray(c) == 0.8
@test color(c) == Gray(0.8)

c = convert(Gray, true)
@test c === Gray{Bool}(true)
@test gray(c) === true
@test gray(false) === false

# Transparency
@test alphacolor(Gray24(.2), .8) == AGray32(.2,.8)
@test alphacolor(RGB24(1,0,0), .8) == ARGB32(1,0,0,.8)
@test alphacolor(RGB(1,0,0), .8) == ARGB{U8}(1,0,0,.8)
@test coloralpha(RGB(1,0,0), .8) == RGBA{U8}(1,0,0,.8)
@test alphacolor(RGBA(1,0,0,.8)) == ARGB{Float64}(1,0,0,.8)
@test coloralpha(ARGB(1,0,0,.8)) == RGBA{Float64}(1,0,0,.8)
@test alphacolor(RGBA(1,0,0,.8)) == ARGB{Float64}(1,0,0,.8)
@test coloralpha(ARGB(1,0,0,.8)) == RGBA{Float64}(1,0,0,.8)
for C in setdiff(ColorTypes.parametric3, [RGB1,RGB4])
    for A in (alphacolor(C), coloralpha(C))
        @test eltype(A{Float32}) == Float32
        @test color_type(A) == C
        @test color_type(A{Float32}) == C{Float32}
        @test eltype(A(1,0.8,0.6,0.4)) == Float64
        c = A{Float64}(1,0.8,0.6,0.4)
        @test color_type(c) == C{Float64}
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

crgb   = convert(RGB, c)
acargb = convert(ARGB, ac)
@test convert(Colorant,       crgb) === crgb
@test convert(Colorant{U8},   crgb) === crgb
@test convert(Colorant{Float32},       crgb) === convert(RGB{Float32}, crgb)
@test convert(Color,          crgb) === crgb
@test convert(Color{U8},      crgb) === crgb
@test convert(Color{Float32}, crgb) === convert(RGB{Float32}, crgb)
@test_throws ErrorException convert(TransparentColor, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{U8}}, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{U8},U8}, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{U8},U8,2}, crgb)
@test convert(AlphaColor, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{U8}}, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{U8},U8}, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{U8},U8,4}, crgb) === alphacolor(crgb)
@test convert(ColorAlpha, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{U8}}, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{U8},U8}, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{U8},U8,4}, crgb) === coloralpha(crgb)

@test convert(Colorant, acargb) === acargb
@test convert(Colorant{U8},   acargb) === acargb
@test convert(Colorant{U8,3}, acargb) === crgb
@test convert(TransparentColor, acargb) == acargb
@test convert(Color, acargb) == crgb

@test red(c)   == red(ac)
@test green(c) == green(ac)
@test blue(c)  == blue(ac)
ac2 = convert(ARGB32, c)
@test ac2.color == (c.color | 0xff000000)
@test color(c) == c
@test color(ac) == c
@test alpha(c) == U8(1)
@test alpha(ac) == UFixed8(ac.color>>24, 0)
@test alpha(ac2) == U8(1)
@test convert(RGB24,  0xff020304).color == 0xff020304
@test convert(ARGB32, 0x01020304).color == 0x01020304
ac3 = convert(RGBA, ac)
@test convert(RGB24, ac3) == c
ac4 = AGray32(.2,.8)
@test alpha(ac4) == .8
@test gray(ac4) == .2

for C in subtypes(AbstractRGB)
    rgb = convert(C, c)
    C == RGB24 && continue
    @test ccolor(Gray24, C) == Gray24
    @test ccolor(AGray32, C) == AGray32
    @test convert(AbstractRGB, c) == c
    @test convert(AbstractRGB{Float64}, rgb) === convert(C{Float64}, c)
    argb = convert(alphacolor(C), ac)
    rgba = convert(coloralpha(C), ac)
    @test rgb.r == red(c)
    @test rgb.g == green(c)
    @test rgb.b == blue(c)
    @test argb.alpha == alpha(ac)
    @test argb.r == red(ac)
    @test argb.g == green(ac)
    @test argb.b == blue(ac)
    @test rgba.alpha == alpha(ac)
    @test rgba.r == red(ac)
    @test rgba.g == green(ac)
    @test rgba.b == blue(ac)
end

@test convert(Float64, Gray(.3)) === .3
@test convert(GrayA{U8}, .2) == GrayA{U8}(.2)
@test convert(AGray{U8}, .2) == AGray{U8}(.2)
@test Gray{U8}(0.37).val           == U8(0.37)
@test convert(Gray{U8}, 0.37).val  == U8(0.37)
@test Gray24(0x0duf8).color           == 0x000d0d0d
@test convert(Gray24, 0x0duf8).color  == 0x000d0d0d
@test AGray32(0x0duf8).color          == 0xff0d0d0d
@test convert(AGray32, 0x0duf8).color == 0xff0d0d0d
@test AGray32(0x0duf8, 0x80uf8).color    == 0x800d0d0d
@test convert(Gray{UFixed16}, Gray24(0x0duf8)) == Gray{UFixed16}(0.05098)

iob = IOBuffer()
cf = RGB{Float32}(0.32218,0.14983,0.87819)
c  = convert(RGB{U8}, cf)
show(iob, c)
@test takebuf_string(iob) == "RGB{U8}(0.322,0.149,0.878)"
c = RGB{UFixed16}(0.32218,0.14983,0.87819)
show(iob, c)
@test takebuf_string(iob) == "RGB{UFixed16}(0.32218,0.14983,0.87819)"
c = RGBA{UFixed8}(0.32218,0.14983,0.87819,0.99241)
show(iob, c)
@test takebuf_string(iob) == "RGBA{U8}(0.322,0.149,0.878,0.992)"
showcompact(iob, c)
@test takebuf_string(iob) == "RGBA{U8}(0.322,0.149,0.878,0.992)"
show(iob, cf)
@test takebuf_string(iob) == "RGB{Float32}(0.32218f0,0.14983f0,0.87819f0)"
showcompact(iob, cf)
@test takebuf_string(iob) == "RGB{Float32}(0.32218,0.14983,0.87819)"

@test one(Gray{U8}) == Gray{U8}(1)
@test zero(Gray{U8}) == Gray{U8}(0)

c = Gray(0.8)
@test c == 0.8
show(iob, c)
@test takebuf_string(iob) == "Gray{Float64}(0.8)"
show(iob, AGray(0.8))
@test takebuf_string(iob) == "AGray{Float64}(0.8,1.0)"
show(iob, AGray32(0.8))
@test takebuf_string(iob) == "AGray32{U8}(0.8,1.0)"

# if the test below fails, please extend the list of types at the call to
# make_alpha in types.jl (this is the price of making that list explicit)
@test Set(ColorTypes.ctypes) ==
Set([DIN99d, DIN99o, DIN99, HSI, HSL, HSV, LCHab, LCHuv,
     LMS, Lab, Luv, XYZ, YCbCr, YIQ, xyY, BGR, RGB, Gray])

## operations
for T in (Gray{U8}, AGray{Float32}, GrayA{Float64},
          RGB{U8}, ARGB{U16}, RGBA{Float32},
          BGR{Float16}, RGB1{U8}, RGB4{Float64}, ABGR{U8})
    a = rand(T)
    @test isa(a, T)
    a = rand(T, (3, 5))
    @test isa(a, Array{T,2})
    @test size(a) == (3,5)
end

# colorfields
@test ColorTypes.colorfields(AGray32(.2)) == (:color,:alpha)
@test ColorTypes.colorfields(Gray) == (:val,)
@test ColorTypes.colorfields(RGB1) == (:r, :g, :b)
@test ColorTypes.colorfields(RGB4) == (:r, :g, :b)
@test ColorTypes.colorfields(BGR) == (:r, :g, :b)

# UInt32 comparison
@test Gray24() == 0x00000000
@test Gray24(.2) == 0x00333333
@test Gray24(0x23uf8) == 0x00232323
@test convert(UInt32, Gray24(0x23uf8)) === 0x00232323
@test AGray32() == 0xff000000
@test AGray32(.2) == 0xff333333
@test convert(AGray32, .2, 0.) == 0x00333333
@test AGray32(0x23uf8) == 0xff232323
@test convert(UInt32, AGray32(0x23uf8)) === 0xff232323
@test RGB24() == 0x00000000
@test RGB24(0x00232323) == 0x00232323
@test convert(UInt32, RGB24(0x00232323)) === 0x00232323
@test ARGB32() == 0xff000000
@test ARGB32(0xff232323) == 0xff232323
@test ARGB32(1,.2,.3) == 0xffff334c
@test convert(UInt32, ARGB32(1,.2,.3)) === 0xffff334c
