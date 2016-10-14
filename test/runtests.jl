using ColorTypes, FixedPointNumbers
using Base.Test

if VERSION >= v"0.5.0-dev+2396"
    macro inferred5(ex)
        Expr(:macrocall, Symbol("@inferred"), esc(ex))
    end
else
    macro inferred5(ex)
        esc(ex)
    end
end

if VERSION >= v"0.5.0"
    @test isempty(detect_ambiguities(ColorTypes, Base, Core))
end

@test ColorTypes.to_top(AGray32(.8)) == ColorTypes.Colorant{FixedPointNumbers.UFixed{UInt8,8},2}
@test @inferred(eltype(Color{N0f8})) == N0f8
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

@test @inferred(color_type(RGB{N0f8})) == RGB{N0f8}
@test @inferred(color_type(RGB)) == RGB
@test @inferred(color_type(RGBA{Float32})) == RGB{Float32}
@test @inferred(color_type(GrayA{N0f8})) == Gray{N0f8}
@test @inferred(color_type(RGBA)) == RGB
@test @inferred(color_type(RGB24) ) == RGB24
@test @inferred(color_type(ARGB32)) == RGB24
@test @inferred(color_type(TransparentColor{RGB})) == RGB
@test @inferred(color_type(TransparentColor{RGB,Float64})) == RGB
@test @inferred(color_type(TransparentColor{RGB{Float64},Float64})) == RGB{Float64}
@test color_type(TransparentColor) <: Color
@test Color <: color_type(TransparentColor)
@test_throws MethodError color_type(Colorant{N0f8})

@test @inferred(base_color_type(RGBA{Float32})) == RGB
@test @inferred(base_color_type(ARGB{Float32})) == RGB
@test @inferred(base_color_type(BGR{N0f8})      ) == BGR
@test @inferred(base_color_type(HSV) ) == HSV
@test @inferred(base_color_type(HSVA)) == HSV
@test @inferred(base_color_type(TransparentColor{RGB{Float64},Float64})) == RGB

@test @inferred(base_colorant_type(RGBA{Float32})) == RGBA
@test @inferred(base_colorant_type(ARGB{Float32})) == ARGB
@test @inferred(base_colorant_type(BGR{N0f8})      ) == BGR
@test @inferred(base_colorant_type(HSV) ) == HSV
@test @inferred(base_colorant_type(HSVA)) == HSVA

@test @inferred(ccolor(Colorant{N0f8,3}, BGR{N0f8})) == BGR{N0f8}

@test @inferred(ccolor(RGB{Float32}, HSV{Float32})) == RGB{Float32}
@test @inferred(ccolor(RGB{N0f8},      HSV{Float32})) == RGB{N0f8}
@test @inferred(ccolor(RGB,          HSV{Float32})) == RGB{Float32}
@test @inferred(ccolor(ARGB{Float32}, HSV{Float32})) == ARGB{Float32}
@test @inferred(ccolor(ARGB{N0f8},      HSV{Float32})) == ARGB{N0f8}
@test @inferred(ccolor(ARGB,          HSV{Float32})) == ARGB{Float32}

@test @inferred(ccolor(Gray{N0f8}, Bool)) === Gray{N0f8}
@test @inferred(ccolor(Gray,     Bool)) === Gray{Bool}
@test @inferred(ccolor(Gray,     Int))  === Gray{N0f8}
# This tests the same thing as the last, but in a user-observable way
a = Array{Gray}(1)
a[1] = Gray(0)
a[1] = 1
@test a[1] === Gray(1)

@test @inferred(ccolor(RGB,  RGB))  === RGB
@test @inferred(ccolor(Gray, Gray)) === Gray

# Traits for instances (and their constructors)
@test @inferred(eltype(RGB{N0f8}(1,0,0))) == N0f8
@test @inferred(eltype(RGB(1.0,0,0))) == Float64
@test @inferred(eltype(ARGB(1.0,0.8,0.6,0.4))) == Float64
@test @inferred(eltype(RGBA{Float32}(1.0,0.8,0.6,0.4))) == Float32
@test @inferred(eltype(RGB(0x01,0x00,0x00))) == N0f8

@test length(ARGB(1.0,0.8,0.6,0.4)) == 4

@test @inferred(color_type(RGB{N0f8}(1,0,0))) == RGB{N0f8}
@test @inferred(color_type(ARGB(1.0,0.8,0.6,0.4))) == RGB{Float64}
@test @inferred(color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGB{Float32}

@test @inferred(base_color_type(RGB{N0f8}(1,0,0))) == RGB
@test @inferred(base_color_type(ARGB(1.0,0.8,0.6,0.4))) == RGB
@test @inferred(base_color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGB

@test @inferred(base_colorant_type(RGB{N0f8}(1,0,0))) == RGB
@test @inferred(base_colorant_type(ARGB(1.0,0.8,0.6,0.4))) == ARGB
@test @inferred(base_colorant_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) == RGBA

@test N0f8 <: ColorTypes.eltypes_supported(RGB(1,0,0))

# Constructors
for val in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2),
            Gray{N0f8}(0.2), Gray{N4f12}(0.2), Gray24(0.2))
    @test isa(Gray(val), Gray)
    @test Gray{N0f8}(val) === Gray{N0f8}(0.2)
    @test Gray{N0f16}(val) === Gray{N0f16}(0.2)
    @test Gray24(val) === Gray24(0.2)
    @test AGray32(val) === AGray32(0.2, 1)
    @test AGray32(val, 0.8) === AGray32(0.2, 0.8)
end
for val in (1.2, 1.2f0, N4f12(1.2), Gray{N4f12}(1.2), 2)
    !isa(val, Int) && @test isa(Gray(val), Gray)
    @test_throws ArgumentError Gray{N0f8}(val)
    @test_throws ArgumentError Gray{N0f16}(val)
    @test_throws ArgumentError Gray24(val) == Gray24(0.2)
    @test_throws ArgumentError GrayA{N0f8}(val)
    @test_throws ArgumentError AGray{N0f8}(val)
    @test_throws ArgumentError AGray32(val)
    @test_throws ArgumentError AGray32(val, 0.8)
end
@test eltype(Gray()) == N0f8
@test Gray(Gray()) == Gray()  # no StackOverflowError
@test eltype(broadcast(Gray, rand(5))) == Gray{Float64}
@test eltype(broadcast(Gray, rand(Float32,5))) == Gray{Float32}

for C in ColorTypes.parametric3
    @test eltype(C{Float32}) == Float32
    et = (C <: AbstractRGB) ? N0f8 : Float32
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
# Check various input types and values
for C in subtypes(AbstractRGB)
    for val1 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
        for val2 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
            c = C(val1,val2,val1)
            @test isa(c, C)
            @test isa(alphacolor(C)(val1,val2,val1), alphacolor(C))
            @test isa(alphacolor(C)(val1,val2,val1,0.2), alphacolor(C))
            @test alphacolor(C)(c) === alphacolor(C)(val1,val2,val1,convert(eltype(c), 1))
            @test alphacolor(C)(c, 0.2) === alphacolor(C)(val1,val2,val1,convert(eltype(c), 0.2))
            @test alphacolor(c, 0.2) === alphacolor(C)(val1,val2,val1,convert(eltype(c), 0.2))
            if C !== RGB24
                @test isa(coloralpha(C)(val1,val2,val1), coloralpha(C))
                @test isa(coloralpha(C)(val1,val2,val1,0.2), coloralpha(C))
                @test C{N0f8}(val1,val2,val1) === C{N0f8}(0.2,0.2,0.2)
                @test C{N0f16}(val1,val2,val1) === C{N0f16}(0.2,0.2,0.2)
                @test alphacolor(C){N0f8}(val1,val2,val1) === alphacolor(C){N0f8}(0.2,0.2,0.2,1)
                @test alphacolor(C){N0f8}(val1,val2,val1,0.2) === alphacolor(C){N0f8}(0.2,0.2,0.2,0.2)
                @test coloralpha(C){N0f8}(val1,val2,val1) === coloralpha(C){N0f8}(0.2,0.2,0.2,1)
                @test coloralpha(C){N0f8}(val1,val2,val1,0.2) === coloralpha(C){N0f8}(0.2,0.2,0.2,0.2)
                @test coloralpha(C)(c) === coloralpha(C){eltype(c)}(val1,val2,val1,1)
                @test coloralpha(C)(c, 0.2) === coloralpha(C)(val1,val2,val1,convert(eltype(c), 0.2))
                @test coloralpha(c, 0.2) === coloralpha(C)(val1,val2,val1,convert(eltype(c), 0.2))
            end
        end
    end
    @test isa(C(1,0,1), C)
    @test C() === C(0,0,0)
    @test isa(alphacolor(C)(1,0,1), alphacolor(C))
    @test alphacolor(C)() === alphacolor(C)(0,0,0,1)
    if C != RGB24
        @test C(1,0,1) === C{N0f8}(1,0,1)
        @test alphacolor(C)(1,0,1) === alphacolor(C){N0f8}(1,0,1,1)
        @test alphacolor(C)(1,0,1,0.2) === alphacolor(C){Float64}(1,0,1,0.2)
        @test coloralpha(C)(1,0,1) === coloralpha(C){N0f8}(1,0,1,1)
        @test coloralpha(C)(1,0,1,0.2) === coloralpha(C){Float64}(1,0,1,0.2)
        @test coloralpha(C)() === coloralpha(C)(0,0,0,1)
    end
    for val in (1.2, 1.2f0, N4f12(1.2), 2)
        if C !== RGB24
            @test_throws ArgumentError C{N0f8}(val,val,val)
            @test_throws ArgumentError C{N0f16}(val,val,val)
            @test_throws ArgumentError alphacolor(C){N0f8}(val,val,val)
            @test_throws ArgumentError coloralpha(C){N0f8}(val,val,val)
            if val != 2
                @test isa(C(val,val,val), C)
                c = C(val,val,val)
                @test_throws ArgumentError alphacolor(C){N0f8}(c)
                @test_throws ArgumentError coloralpha(C){N0f8}(c)
                if C != RGB1 && C != RGB4
                    @test_throws ArgumentError alphacolor(C){N0f8}(c, 0.2)
                    @test_throws ArgumentError coloralpha(C){N0f8}(c, 0.2)
                end
            end
        end
        if C == RGB24 || isa(val, Int)
            @test_throws ArgumentError C(val,val,val)
            @test_throws ArgumentError alphacolor(C)(val,val,val)
        end
    end
end
if VERSION >= v"0.5.0"
    ret = @test_throws ArgumentError RGB(255, 17, 48)
    @test contains(ret.value.msg, "255,17,48")
    @test contains(ret.value.msg, "0-255")
    ret = @test_throws ArgumentError RGB(256, 17, 48)
    @test contains(ret.value.msg, "256,17,48")
    @test !contains(ret.value.msg, "0-255")
end

c = Gray(0.8)
@test gray(c) == real(c) == 0.8
@test gray(0.8) == 0.8
c = convert(Gray, 0.8)
@test c === Gray{Float64}(0.8)

ac = convert(AGray, c)
@test ac === AGray{Float64}(0.8, 1.0)

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
@test alphacolor(RGB(1,0,0), .8) == ARGB{N0f8}(1,0,0,.8)
@test coloralpha(RGB(1,0,0), .8) == RGBA{N0f8}(1,0,0,.8)
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
ac = reinterpret(ARGB32, rand(UInt32))
@test convert(ARGB32, ac) == ac
c = convert(RGB24, ac)
@test convert(RGB24, c) == c

crgb   = convert(RGB, c)
acargb = convert(ARGB, ac)
@test convert(Colorant,       crgb) === crgb
@test convert(Colorant{N0f8},   crgb) === crgb
@test convert(Colorant{Float32},       crgb) === convert(RGB{Float32}, crgb)
@test convert(Color,          crgb) === crgb
@test convert(Color{N0f8},      crgb) === crgb
@test convert(Color{Float32}, crgb) === convert(RGB{Float32}, crgb)
@test_throws ErrorException convert(TransparentColor, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{N0f8}}, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8}, crgb)
@test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8,2}, crgb)
@test convert(AlphaColor, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{N0f8}}, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{N0f8},N0f8}, crgb) === alphacolor(crgb)
@test convert(AlphaColor{RGB{N0f8},N0f8,4}, crgb) === alphacolor(crgb)
@test convert(ColorAlpha, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{N0f8}}, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{N0f8},N0f8}, crgb) === coloralpha(crgb)
@test convert(ColorAlpha{RGB{N0f8},N0f8,4}, crgb) === coloralpha(crgb)

@test convert(Colorant, acargb) === acargb
@test convert(Colorant{N0f8},   acargb) === acargb
@test convert(Colorant{N0f8,3}, acargb) === crgb
@test convert(TransparentColor, acargb) == acargb
@test convert(Color, acargb) == crgb

h = N0f8(0.5)
@test Gray24(0.5) == Gray24(h)
@test convert(Gray24, 0.5) == Gray24(h)
@test convert(AGray, Gray24(h)) === AGray{N0f8}(h, 1)
@test convert(AGray, Gray24(h), 0.8)  === AGray{N0f8}(h, 0.8)
@test convert(AGray, AGray32(h, 0.8)) === AGray{N0f8}(h, 0.8)
@test AGray32(0.5) == AGray32(h, 1)
@test convert(AGray32, 0.5, 0.8) == AGray32(h, N0f8(0.8))
@test RGB24(0.5) == RGB24(h, h, h)
@test convert(RGB24, 0.5) == RGB24(h, h, h)
@test ARGB32(0.5) == ARGB32(h, h, h, 1)

@test red(c)   == red(ac)
@test green(c) == green(ac)
@test blue(c)  == blue(ac)
ac2 = convert(ARGB32, c)
@test reinterpret(UInt32, ac2) == (c.color | 0xff000000)
@test color(c) == c
@test color(ac) == c
@test alpha(c) == N0f8(1)
@test alpha(ac) == N0f8(ac.color>>24, 0)
@test alpha(ac2) == N0f8(1)
@test reinterpret(UInt32, reinterpret(RGB24,  0xff020304)) == 0xff020304
@test reinterpret(UInt32, reinterpret(ARGB32, 0x01020304)) == 0x01020304
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

@test_throws ErrorException convert(HSV, RGB(1,0,1))
@test_throws ErrorException convert(AHSV, RGB(1,0,1), 0.5)

@test convert(Float64, Gray(.3)) === .3
x = N0f8(0.3)
@test convert(N0f8, Gray24(0.3)) === x
@test convert(GrayA{N0f8}, .2) == GrayA{N0f8}(.2)
@test convert(AGray{N0f8}, .2) == AGray{N0f8}(.2)
@test Gray{N0f8}(0.37).val           == N0f8(0.37)
@test convert(Gray{N0f8}, 0.37).val  == N0f8(0.37)
@test reinterpret(UInt32, Gray24(reinterpret(N0f8, 0x0d)))           == 0x000d0d0d
@test reinterpret(UInt32, convert(Gray24, reinterpret(N0f8, 0x0d)))  == 0x000d0d0d
@test reinterpret(UInt32, AGray32(reinterpret(N0f8, 0x0d)))          == 0xff0d0d0d
@test reinterpret(UInt32, convert(AGray32, reinterpret(N0f8, 0x0d))) == 0xff0d0d0d
@test reinterpret(UInt32, AGray32(reinterpret(N0f8, 0x0d), reinterpret(N0f8, 0x80))) == 0x800d0d0d
@test convert(Gray{N0f16}, Gray24(reinterpret(N0f8, 0x0d))) == Gray{N0f16}(0.05098)

@test promote(Gray{N0f8}(0.2), Gray24(0.3)) === (Gray{N0f8}(0.2), Gray{N0f8}(0.3))
@test promote(Gray(0.2f0), Gray24(0.3)) === (Gray{Float32}(0.2), Gray{Float32}(N0f8(0.3)))
@test promote(RGB{N0f8}(0.2,0.3,0.4), RGB24(0.3,0.8,0.1)) === (RGB{N0f8}(0.2,0.3,0.4), RGB{N0f8}(0.3,0.8,0.1))
@test promote(RGB{Float32}(0.2,0.3,0.4), RGB24(0.3,0.8,0.1)) === (RGB{Float32}(0.2,0.3,0.4), RGB{Float32}(N0f8(0.3),N0f8(0.8),N0f8(0.1)))

iob = IOBuffer()
cf = RGB{Float32}(0.32218,0.14983,0.87819)
c  = convert(RGB{N0f8}, cf)
show(iob, c)
@test takebuf_string(iob) == "RGB{N0f8}(0.322,0.149,0.878)"
c = RGB{N0f16}(0.32218,0.14983,0.87819)
show(iob, c)
@test takebuf_string(iob) == "RGB{N0f16}(0.32218,0.14983,0.87819)"
c = RGBA{N0f8}(0.32218,0.14983,0.87819,0.99241)
show(iob, c)
@test takebuf_string(iob) == "RGBA{N0f8}(0.322,0.149,0.878,0.992)"
showcompact(iob, c)
@test takebuf_string(iob) == "RGBA{N0f8}(0.322,0.149,0.878,0.992)"
show(iob, cf)
@test takebuf_string(iob) == "RGB{Float32}(0.32218f0,0.14983f0,0.87819f0)"
showcompact(iob, cf)
@test takebuf_string(iob) == "RGB{Float32}(0.32218,0.14983,0.87819)"

@test one(Gray{N0f8}) == Gray{N0f8}(1)
@test zero(Gray{N0f8}) == Gray{N0f8}(0)

c = Gray(0.8)
@test c == 0.8
show(iob, c)
@test takebuf_string(iob) == "Gray{Float64}(0.8)"
show(iob, AGray(0.8))
@test takebuf_string(iob) == "AGray{Float64}(0.8,1.0)"
show(iob, AGray32(0.8))
@test takebuf_string(iob) == "AGray32{N0f8}(0.8,1.0)"

# if the test below fails, please extend the list of types at the call to
# make_alpha in types.jl (this is the price of making that list explicit)
@test Set(ColorTypes.ctypes) ==
Set([DIN99d, DIN99o, DIN99, HSI, HSL, HSV, LCHab, LCHuv,
     LMS, Lab, Luv, XYZ, YCbCr, YIQ, xyY, BGR, RGB, Gray])

## operations
for T in (Gray{N0f8}, AGray{Float32}, GrayA{Float64},
          RGB{N0f8}, ARGB{N0f16}, RGBA{Float32},
          BGR{Float16}, RGB1{N0f8}, RGB4{Float64}, ABGR{N0f8})
    a = rand(T)
    @test isa(a, T)
    a = rand(T, (3, 5))
    @test isa(a, Array{T,2})
    @test size(a) == (3,5)
end
a = [BGR(1,0,0)]
@test eltype(broadcast(RGB, a)) == RGB{N0f8}

# colorfields
@test ColorTypes.colorfields(AGray32(.2)) == (:color,:alpha)
@test ColorTypes.colorfields(Gray) == (:val,)
@test ColorTypes.colorfields(RGB1) == (:r, :g, :b)
@test ColorTypes.colorfields(RGB4) == (:r, :g, :b)
@test ColorTypes.colorfields(BGR) == (:r, :g, :b)

# UInt32 comparison
@test reinterpret(UInt32, Gray24()) == 0x00000000
@test reinterpret(UInt32, Gray24(.2)) == 0x00333333
@test reinterpret(UInt32, Gray24(reinterpret(N0f8, 0x23))) == 0x00232323
@test reinterpret(UInt32, AGray32()) == 0xff000000
@test reinterpret(UInt32, AGray32(.2)) == 0xff333333
@test reinterpret(UInt32, convert(AGray32, .2, 0.)) == 0x00333333
@test reinterpret(UInt32, AGray32(reinterpret(N0f8, 0x23))) == 0xff232323
@test reinterpret(UInt32, RGB24()) == 0x00000000
@test reinterpret(UInt32, ARGB32()) == 0xff000000
@test reinterpret(UInt32, ARGB32(1,.2,.3)) == 0xffff334c

@test @inferred5(mapc(sqrt, Gray{N0f8}(0.04))) == Gray(sqrt(N0f8(0.04)))
@test @inferred5(mapc(sqrt, AGray{N0f8}(0.04, 0.4))) == AGray(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
@test @inferred5(mapc(sqrt, GrayA{N0f8}(0.04, 0.4))) == GrayA(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
@test @inferred5(mapc(x->2x, RGB{N0f8}(0.04,0.2,0.3))) == RGB(map(x->2*N0f8(x), (0.04,0.2,0.3))...)
@test @inferred5(mapc(sqrt, RGBA{N0f8}(0.04,0.2,0.3,0.7))) == RGBA(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7))...)
@test @inferred5(mapc(x->1.5f0x, RGBA{N0f8}(0.04,0.2,0.3,0.4))) == RGBA(map(x->1.5f0*N0f8(x), (0.04,0.2,0.3,0.4))...)

@test @inferred5(mapc(max, Gray{N0f8}(0.2), Gray{N0f8}(0.3))) == Gray{N0f8}(0.3)
@test @inferred5(mapc(-, AGray{Float32}(0.3), AGray{Float32}(0.2))) == AGray{Float32}(0.3f0-0.2f0,0.0)
@test @inferred5(mapc(min, RGB{N0f8}(0.2,0.8,0.7), RGB{N0f8}(0.5,0.2,0.99))) == RGB{N0f8}(0.2,0.2,0.7)
@test @inferred5(mapc(+, RGBA{N0f8}(0.2,0.8,0.7,0.3), RGBA{Float32}(0.5,0.2,0.99,0.5))) == RGBA(0.5f0+N0f8(0.2),0.2f0+N0f8(0.8),0.99f0+N0f8(0.7),0.5f0+N0f8(0.3))
@test @inferred5(mapc(+, HSVA(0.1,0.8,0.3,0.5), HSVA(0.5,0.5,0.5,0.3))) == HSVA(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.3)
@test_throws ArgumentError mapc(min, RGB{N0f8}(0.2,0.8,0.7), BGR{N0f8}(0.5,0.2,0.99))


# issue #52
@test AGray{BigFloat}(0.5,0.25) == AGray{BigFloat}(0.5,0.25)
@test RGBA{BigFloat}(0.5, 0.25, 0.5, 0.5) == RGBA{BigFloat}(0.5, 0.25, 0.5, 0.5)

for (a, b) in ((Gray(1.0), Gray(1)),
               (GrayA(0.8, 0.6), AGray(0.8, 0.6)),
               (RGB(1, 0.5, 0), BGR(1, 0.5, 0)),
               (RGBA(1, 0.5, 0, 0.8), ABGR(1, 0.5, 0, 0.8)))
    @test a == b
    @test hash(a) == hash(b)
end
for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 0.9)),)
    @test a != b
    @test hash(a) != hash(b)
end
# It's not obvious whether we want these to compare as equal, but
# whatever happens, you want hashing and equality-testing to yield the
# same result
for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 1)),)
    @test (a == b) == (hash(a) == hash(b))
end

### Test deprecations
mktemp() do tmpfile, io
    redirect_stderr(io) do
        @test convert(UInt32, RGB24(1,1,1))    == 0x00ffffff
        @test convert(UInt32, ARGB32(1,1,1,0)) == 0x00ffffff
        @test convert(UInt32, Gray24(1))    == 0x00ffffff
        @test convert(UInt32, AGray32(1,0)) == 0x00ffffff
        @test RGB24(1,1,1)    == 0x00ffffff
        @test ARGB32(1,1,1,0) == 0x00ffffff
        @test Gray24(1)    == 0x00ffffff
        @test AGray32(1,0) == 0x00ffffff
        @test RGB24(0x00ffffff)  === RGB24(1,1,1)
        @test ARGB32(0x00ffffff) === ARGB32(1,1,1,0)
        @test Gray24(0x00ffffff)  === Gray24(1)
        @test AGray32(0x00ffffff) === AGray32(1,0)
        @test RGB24[0x00000000] == [RGB24(0)]
        @test RGB24[0x00000000,0x00808080] == [RGB24(0), RGB24(0.5)]
        @test RGB24[0x00000000,0x00808080,0x00ffffff] == [RGB24(0), RGB24(0.5), RGB24(1)]
        @test RGB24[0x00000000,0x00808080,0x00ffffff,0x000000ff] == [RGB24(0), RGB24(0.5), RGB24(1), RGB24(0,0,1)]
    end
    close(io)
    Base.JLOptions().depwarn==1 && @test sum(x->contains(x, "WARNING"), readlines(tmpfile)) == 16
end


nothing
