using ColorTypes, FixedPointNumbers
using Test

@testset "rgb promotions" begin
    @test        promote( RGB{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === ( RGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8),  RGB{Float64}(0.3,0.8,0.1))
    @test_broken promote( RGB{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test_broken promote( RGB{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test_broken promote(RGBA{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test_broken promote(RGBA{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test_broken promote(ARGB{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test_broken promote(ARGB{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))

    @test        promote( RGB24(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === ( RGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8),  RGB{Float64}(0.3,0.8,0.1))
    @test_broken promote( RGB24(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test_broken promote( RGB24(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test_broken promote(ARGB32(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test_broken promote(ARGB32(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))

    @test        promote( RGB24(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === ( RGB{N0f8}(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1))
    @test_broken promote( RGB24(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1)) === (RGBA{N0f8}(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1))
    @test_broken promote( RGB24(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{N0f8}(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1))
    @test_broken promote(ARGB32(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === (ARGB{N0f8}(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1))
    @test_broken promote(ARGB32(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{N0f8}(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1))

    @test_broken promote(RGBX{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (RGBX{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBX{Float64}(0.3,0.8,0.1))
    @test_broken promote(RGBX{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test_broken promote(RGBX{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test_broken promote(XRGB{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (XRGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), XRGB{Float64}(0.3,0.8,0.1))
    @test_broken promote(XRGB{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test_broken promote(XRGB{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))

    @test_broken promote(RGBX(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === (RGBX{Float64}(0.2,0.3,0.4), RGBX{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test_broken promote(RGBX(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1)) === (RGBA{Float64}(0.2,0.3,0.4), RGBA{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test_broken promote(RGBX(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{Float64}(0.2,0.3,0.4), ARGB{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test_broken promote(XRGB(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === (XRGB{Float64}(0.2,0.3,0.4), XRGB{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test_broken promote(XRGB(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1)) === (RGBA{Float64}(0.2,0.3,0.4), RGBA{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test_broken promote(XRGB(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{Float64}(0.2,0.3,0.4), ARGB{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
end

@testset "hsv promotions" begin
    @test_broken promote( HSV{Float32}(100,0.3,0.4),  HSV(200,0.8,0.1)) === ( HSV{Float64}(100,0.3f0,0.4f0),  HSV{Float64}(200,0.8,0.1))
    @test_broken promote( HSV{Float32}(100,0.3,0.4), HSVA(200,0.8,0.1)) === (HSVA{Float64}(100,0.3f0,0.4f0), HSVA{Float64}(200,0.8,0.1))
    @test_broken promote( HSV{Float32}(100,0.3,0.4), AHSV(200,0.8,0.1)) === (AHSV{Float64}(100,0.3f0,0.4f0), AHSV{Float64}(200,0.8,0.1))
    @test_broken promote(HSVA{Float32}(100,0.3,0.4),  HSV(200,0.8,0.1)) === (HSVA{Float64}(100,0.3f0,0.4f0), HSVA{Float64}(200,0.8,0.1))
    @test_broken promote(HSVA{Float32}(100,0.3,0.4), HSVA(200,0.8,0.1)) === (HSVA{Float64}(100,0.3f0,0.4f0), HSVA{Float64}(200,0.8,0.1))
    @test_broken promote(AHSV{Float32}(100,0.3,0.4),  HSV(200,0.8,0.1)) === (AHSV{Float64}(100,0.3f0,0.4f0), AHSV{Float64}(200,0.8,0.1))
    @test_broken promote(AHSV{Float32}(100,0.3,0.4), AHSV(200,0.8,0.1)) === (AHSV{Float64}(100,0.3f0,0.4f0), AHSV{Float64}(200,0.8,0.1))
end

@testset "gray promotions" begin
    @test        promote( Gray{N0f8}(0.2),  Gray(0.3)) === ( Gray{Float64}(0.2N0f8),  Gray{Float64}(0.3))
    @test_broken promote( Gray{N0f8}(0.2), GrayA(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test_broken promote( Gray{N0f8}(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test_broken promote(GrayA{N0f8}(0.2),  Gray(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test_broken promote(GrayA{N0f8}(0.2), GrayA(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test_broken promote(AGray{N0f8}(0.2),  Gray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test_broken promote(AGray{N0f8}(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))

    @test        promote( Gray24(0.2),  Gray(0.3)) === ( Gray{Float64}(0.2N0f8),  Gray{Float64}(0.3))
    @test_broken promote( Gray24(0.2), GrayA(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test_broken promote( Gray24(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test_broken promote(AGray32(0.2),  Gray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test_broken promote(AGray32(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test        promote( Gray24(0.2),  Gray{N0f8}(0.3)) === ( Gray{N0f8}(0.2),  Gray{N0f8}(0.3))
    @test_broken promote( Gray24(0.2), GrayA{N0f8}(0.3)) === (GrayA{N0f8}(0.2), GrayA{N0f8}(0.3))
    @test_broken promote( Gray24(0.2), AGray{N0f8}(0.3)) === (AGray{N0f8}(0.2), AGray{N0f8}(0.3))
    @test_broken promote(AGray32(0.2),  Gray{N0f8}(0.3)) === (AGray{N0f8}(0.2), AGray{N0f8}(0.3))
    @test_broken promote(AGray32(0.2), AGray{N0f8}(0.3)) === (AGray{N0f8}(0.2), AGray{N0f8}(0.3))
end

@testset "rgb conversions with abstract types" begin
    c = RGB(1, 0.6, 0)
    @test convert(Colorant, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(Colorant{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test_broken convert(Colorant{Float32,3}, c) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(Color{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test convert(Color{Float32}, c) === RGB{Float32}(1, 0.6, 0)
    @test convert(AbstractRGB, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test_throws ErrorException convert(TransparentColor, c)
    @test_throws ErrorException convert(TransparentColor{RGB{N0f8}}, c)
    @test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8}, c)
    @test_throws ErrorException convert(TransparentColor{RGB{N0f8},N0f8,2}, c)
    @test convert(AlphaColor, c) === ARGB{Float64}(1, 0.6, 0, 1)
    @test_broken convert(AlphaColor{RGB{N0f8}}, c) === ARGB{N0f8}(1, 0.6, 0, 1)
    @test convert(AlphaColor{RGB{N0f8},N0f8}, c) === ARGB{N0f8}(1, 0.6, 0, 1)
    @test convert(AlphaColor{RGB{N0f8},N0f8,4}, c) === ARGB{N0f8}(1, 0.6, 0, 1)
    @test convert(ColorAlpha, c) === RGBA{Float64}(1, 0.6, 0, 1)
    @test_broken convert(ColorAlpha{RGB{N0f8}}, c) === RGBA{N0f8}(1, 0.6, 0, 1)
    @test convert(ColorAlpha{RGB{N0f8},N0f8}, c) === RGBA{N0f8}(1, 0.6, 0, 1)
    @test convert(ColorAlpha{RGB{N0f8},N0f8,4}, c) === RGBA{N0f8}(1, 0.6, 0, 1)

    ac = ARGB(1, 0.6, 0, 0.8)
    @test convert(Colorant, ac) === ARGB{Float64}(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, ac) === ARGB{N0f8}(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, ac) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, ac) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB, ac) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB{N0f8}, ac) === RGB{N0f8}(1, 0.6, 0)
    @test convert(TransparentColor, ac) == ARGB{Float64}(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, ac) === ARGB{Float64}(1, 0.6, 0, 0.8) # issue #126
    @test convert(ColorAlpha, ac) === RGBA{Float64}(1, 0.6, 0, 0.8) # issue #126

    ca = RGBA(1, 0.6, 0, 0.8)
    @test convert(Colorant, ca) === RGBA{Float64}(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, ca) === RGBA{N0f8}(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, ca) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, ca) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB, ca) === RGB{Float64}(1, 0.6, 0)
    @test_broken convert(AbstractRGB{N0f8}, ca) === RGB{N0f8}(1, 0.6, 0)
    @test convert(TransparentColor, ca) == RGBA{Float64}(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, ca) === ARGB{Float64}(1, 0.6, 0, 0.8) # issue #126
    @test convert(ColorAlpha, ca) === RGBA{Float64}(1, 0.6, 0, 0.8) # issue #126

    rgb24 = RGB24(1, 0.6, 0)
    @test convert(Colorant, rgb24) === RGB24(1, 0.6, 0)
    @test convert(Colorant{N0f8}, rgb24) === RGB24(1, 0.6, 0)
    @test_broken convert(Colorant{Float32,3}, rgb24) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, rgb24) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB, rgb24) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, rgb24) === RGB24(1, 0.6, 0)
    @test_throws ErrorException convert(TransparentColor, rgb24)
    @test convert(AlphaColor, rgb24) === ARGB32(1, 0.6, 0, 1)
    @test_throws MethodError convert(ColorAlpha, rgb24)

    argb32 = ARGB32(1, 0.6, 0, 0.8)
    @test convert(Colorant, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, argb32) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, argb32) === RGB24(1, 0.6, 0)
    @test_broken convert(AbstractRGB, argb32) === RGB24(1, 0.6, 0)
    @test_broken convert(AbstractRGB{N0f8}, argb32) === RGB24(1, 0.6, 0)
    @test convert(TransparentColor, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test_throws MethodError convert(ColorAlpha, argb32)

    @test convert(AbstractARGB{RGB,N0f8}, c, 0.2) === ARGB{N0f8}(1, 0.6, 0, 0.2)
    @test convert(AbstractRGBA{RGB,N0f8}, c, 0.2) === RGBA{N0f8}(1, 0.6, 0, 0.2)
    @test_broken convert(AbstractARGB{RGB24,N0f8}, rgb24, 0.2) === ARGB32(1, 0.6, 0, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, ac, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, ca, 0.2)
    @test_throws ErrorException convert(AbstractARGB{RGB,N0f8}, rgb24, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, argb32, 0.2)
end

@testset "gray conversions with abstract types" begin
    c = Gray(0.4)
    @test convert(Colorant, c) === Gray{Float64}(0.4)
    @test convert(Colorant{N0f8}, c) === Gray{N0f8}(0.4)
    @test_broken convert(Colorant{Float32,1}, c) === Gray{Float32}(0.4)
    @test convert(Color, c) === Gray{Float64}(0.4)
    @test_throws ErrorException convert(TransparentColor, c)
    @test convert(AlphaColor, c) === AGray{Float64}(0.4, 1)
    @test convert(ColorAlpha, c) === GrayA{Float64}(0.4, 1)

    ac = AGray(0.4, 0.8)
    @test convert(Colorant, ac) === AGray{Float64}(0.4, 0.8)
    @test convert(Colorant{N0f8}, ac) === AGray{N0f8}(0.4, 0.8)
    @test_broken convert(Colorant{Float32,1}, ac) === Gray{Float32}(0.4, 0.8)
    @test convert(Color, ac) === Gray{Float64}(0.4)
    @test convert(TransparentColor, ac) == AGray{Float64}(0.4, 0.8)
    @test convert(AlphaColor, ac) === AGray{Float64}(0.4, 0.8)
    @test convert(ColorAlpha, ac) === GrayA{Float64}(0.4, 0.8)

    ca = GrayA(0.4, 0.8)
    @test convert(Colorant, ca) === GrayA{Float64}(0.4, 0.8)
    @test convert(Colorant{N0f8}, ca) === GrayA{N0f8}(0.4, 0.8)
    @test_broken convert(Colorant{Float32,1}, ca) === Gray{Float32}(0.4)
    @test convert(Color, ca) === Gray{Float64}(0.4)
    @test convert(TransparentColor, ca) == GrayA{Float64}(0.4, 0.8)
    @test convert(AlphaColor, ca) === AGray{Float64}(0.4, 0.8)
    @test convert(ColorAlpha, ca) === GrayA{Float64}(0.4, 0.8)

    gray24 = Gray24(0.4)
    @test convert(Colorant, gray24) === Gray24(0.4)
    @test convert(Colorant{N0f8}, gray24) === Gray24(0.4)
    @test_broken convert(Colorant{Float32,1}, gray24) === Gray{Float32}(0.4)
    @test convert(Color, gray24) === Gray24(0.4)
    @test_throws ErrorException convert(TransparentColor, gray24)
    @test convert(AlphaColor, gray24) === AGray32(0.4, 1)
    @test_throws MethodError convert(ColorAlpha, gray24) # TODO: need docs

    agray32 = AGray32(0.4, 0.8)
    @test convert(Colorant, agray32) === AGray32(0.4, 0.8)
    @test convert(Colorant{N0f8}, agray32) === AGray32(0.4, 0.8)
    @test_broken convert(Colorant{Float32,1}, agray32) === Gray{Float32}(0.4)
    @test convert(Color, agray32) === Gray24(0.4)
    @test convert(TransparentColor, agray32) === AGray32(0.4, 0.8)
    @test convert(AlphaColor, agray32) === AGray32(0.4, 0.8)
    @test_throws MethodError convert(ColorAlpha, agray32) # TODO: need docs

    @test convert(AbstractAGray{Gray,N0f8}, c, 0.2) === AGray{N0f8}(0.4, 0.2)
    @test convert(AbstractGrayA{Gray,N0f8}, c, 0.2) === GrayA{N0f8}(0.4, 0.2)
    # the following is ok, but not consistent with the case of RGB24
    @test convert(AbstractAGray{Gray,N0f8}, gray24, 0.2) === AGray{N0f8}(0.4, 0.2)
    @test_broken convert(AbstractAGray{Gray24,N0f8}, gray24, 0.2) === AGray32(0.4, 0.2)
    @test_throws MethodError convert(AbstractAGray{Gray,N0f8}, ac, 0.2)
    @test_throws MethodError convert(AbstractAGray{Gray,N0f8}, ca, 0.2)
    @test_throws MethodError convert(AbstractAGray{Gray,N0f8}, agray32, 0.2)
end

@testset "conversions from/to real numbers" begin
    @test convert(Float64, Gray(0.6)) === 0.6
    @test Float32(Gray(0.6)) === 0.6f0
    @test float(Gray(0.6)) === 0.6
    @test real(Gray(0.6)) === 0.6

    @test convert(N0f8, Gray24(0.6)) === N0f8(0.6)
    @test convert(Float64, Gray24(0.6)) === 0.6

    @test convert(Gray, 0.6) === Gray{Float64}(0.6)
    @test convert(Gray, 0.6f0) === Gray{Float32}(0.6)
    @test convert(Gray, 0.6N0f8) === Gray{N0f8}(0.6)
    @test convert(Gray, true) === Gray{Bool}(1)
    @test convert(Gray, false) === Gray{Bool}(0)
    @test convert(Gray, 1) === Gray{N0f8}(1)

    @test convert(Gray{N0f16}, 0.6) === Gray{N0f16}(0.6)
    @test convert(Gray{N0f16}, 0.6f0) === Gray{N0f16}(0.6)
    @test convert(Gray{N0f16}, 0.6N0f8) === Gray{N0f16}(0.6)

    @test convert(GrayA{N0f8}, 0.6) === GrayA{N0f8}(0.6, 1)
    @test convert(AGray{N0f8}, 0.6) === AGray{N0f8}(0.6, 1)

    @test convert(Gray24, 0.6) === Gray24(0.6)
    @test convert(Gray24, 0.6f0) === Gray24(0.6)
    @test convert(Gray24, 0.6N0f8) === Gray24(0.6)

    @test convert(AGray32, 0.6) === AGray32(0.6, 1)
    @test convert(AGray32, 0.6f0) === AGray32(0.6, 1)
    @test convert(AGray32, 0.6N0f8) === AGray32(0.6, 1)
    @test convert(AGray32, 0.6, 0.8) === AGray32(0.6, 0.8)
    @test convert(AGray32, 0, 1) === AGray32(0, 1)

    @test_throws MethodError convert(Colorant, 0.6)
    @test_throws MethodError convert(Color, 0.6)
    @test_throws ErrorException convert(Color{N0f8,1}, 0.6)

    @test_throws MethodError convert(GrayA, 0.6, 0.8)
    @test_throws MethodError convert(AGray, 0, 1)

    @test convert(Gray, 2.0) === Gray{Float64}(2.0)
    @test_throws ArgumentError convert(Gray, 2)

    @test convert(RGB24, 0.6) === RGB24(0.6, 0.6, 0.6)
    @test convert(ARGB32, 0.6) === ARGB32(0.6, 0.6, 0.6, 1)

    @test_throws MethodError convert(RGB, 0.6)
end

@testset "conversions from rgb to rgb" begin
    Crgb = filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
    Ctransparent = unique(vcat(coloralpha.(Crgb), alphacolor.(Crgb)))
    @testset "$C conversions" for C in Crgb
        @test convert(C, C{Float64}(1,0.6,0)) === C{Float64}(1,0.6,0)
        @test convert(C{N0f8}, C{Float64}(1,0.6,0)) === C{N0f8}(1,0.6,0)
        @test convert(C, RGB24(1,0.6,0)) === C{N0f8}(1,0.6,0)
        @test convert(RGB24, C(1,0.6,0)) === RGB24(1,0.6,0)
        @test convert(C, ARGB32(1,0.6,0,0.8)) === C{N0f8}(1,0.6,0)
        @test convert(ARGB32, C(1,0.6,0)) === ARGB32(1,0.6,0)
        @test_broken convert(ARGB32, C(1,0.6,0), 0.2) === ARGB32(1,0.6,0,0.2)
    end
    @testset "$C conversions" for C in Ctransparent
        @test convert(C, C{Float64}(1,0.6,0,0.8)) === C{Float64}(1,0.6,0,0.8)
        @test convert(C{N0f8}, C{Float64}(1,0.6,0,0.8)) === C{N0f8}(1,0.6,0,0.8)
        @test convert(C, RGB24(1,0.6,0)) === C{N0f8}(1,0.6,0,1)
        @test_broken convert(C, RGB24(1,0.6,0), 0.2) === C{N0f8}(1,0.6,0,0.2)
        @test convert(RGB24, C(1,0.6,0,0.8)) === RGB24(1,0.6,0)
        @test convert(C, ARGB32(1,0.6,0,0.8)) === C{N0f8}(1,0.6,0,0.8)
        @test convert(ARGB32, C(1,0.6,0,0.8)) === ARGB32(1,0.6,0,0.8)
    end
    @test convert(RGB24, RGB24(1,0.6,0)) === RGB24(1,0.6,0)
    @test convert(ARGB32, RGB24(1,0.6,0)) === ARGB32(1,0.6,0,1)
    @test convert(ARGB32, RGB24(1,0.6,0), 0.2) === ARGB32(1,0.6,0,0.2)
    @test convert(RGB24, ARGB32(1,0.6,0,0.8)) === RGB24(1,0.6,0)
    @test convert(ARGB32, ARGB32(1,0.6,0,0.8)) === ARGB32(1,0.6,0,0.8)
end

@testset "conversions from gray to gray" begin
    @testset "Gray conversions" begin
        @test convert(Gray, Gray{Float64}(0.4)) === Gray{Float64}(0.4)
        @test convert(Gray{N0f8}, Gray{Float64}(0.4)) === Gray{N0f8}(0.4)
        @test convert(Gray, Gray24(0.4)) === Gray{N0f8}(0.4)
        @test convert(Gray24, Gray(0.4)) === Gray24(0.4)
        @test convert(Gray, AGray32(0.4,0.8)) === Gray{N0f8}(0.4)
        @test convert(AGray32, Gray(0.4)) === AGray32(0.4)
        @test convert(AGray32, Gray(0.4), 0.2) === AGray32(0.4, 0.2)
    end
    @testset "$C conversions" for C in (AGray, GrayA)
        @test convert(C, C{Float64}(0.4,0.8)) === C{Float64}(0.4,0.8)
        @test convert(C{N0f8}, C{Float64}(0.4,0.8)) === C{N0f8}(0.4,0.8)
        @test convert(C, Gray24(0.4)) === C{N0f8}(0.4,1)
        @test convert(C, Gray24(0.4), 0.2) === C{N0f8}(0.4,0.2)
        @test convert(Gray24, C(0.4,0.8)) === Gray24(0.4)
        @test convert(C, AGray32(0.4,0.8)) === C{N0f8}(0.4,0.8)
        @test convert(AGray32, C(0.4,0.8)) === AGray32(0.4,0.8)
    end
    @test convert(Gray24, Gray24(0.4)) === Gray24(0.4)
    @test convert(AGray32, Gray24(0.4)) === AGray32(0.4,1)
    @test convert(AGray32, Gray24(0.4), 0.2) === AGray32(0.4,0.2)
    @test convert(Gray24, AGray32(0.4,0.8)) === Gray24(0.4)
    @test convert(AGray32, AGray32(0.4,0.8)) === AGray32(0.4,0.8)
end

@testset "conversions from hsv to hsv" begin
    @testset "HSV conversions" begin
        @test convert(HSV, HSV{Float64}(100,0.4,0.6)) === HSV{Float64}(100,0.4,0.6)
        @test convert(HSV{Float32}, HSV{Float64}(100,0.4,0.6)) === HSV{Float32}(100,0.4,0.6)
        @test convert(HSV, HSVA{Float64}(100,0.4,0.6,0.8)) === HSV{Float64}(100,0.4,0.6)
        @test convert(HSV, AHSV{Float32}(100,0.4,0.6,0.8)) === HSV{Float32}(100,0.4,0.6)
    end
    @testset "$C conversions" for C in (AHSV, HSVA)
        @test convert(C, HSVA{Float64}(100,0.4,0.6,0.8)) === C{Float64}(100,0.4,0.6,0.8)
        @test convert(C, AHSV{Float32}(100,0.4,0.6,0.8)) === C{Float32}(100,0.4,0.6,0.8)
        @test convert(C{Float32}, HSVA{Float64}(100,0.4,0.6,0.8)) === C{Float32}(100,0.4,0.6,0.8)
        @test convert(C{Float32}, AHSV{Float32}(100,0.4,0.6,0.8)) === C{Float32}(100,0.4,0.6,0.8)
        @test convert(C, HSV{Float64}(100,0.4,0.6)) === C{Float64}(100,0.4,0.6,1)
        @test convert(C, HSV{Float32}(100,0.4,0.6), 0.2) === C{Float32}(100,0.4,0.6,0.2)
    end
end

@testset "conversions between different spaces" begin
    @test_throws ErrorException convert(HSV, RGB(1,0,1))
    @test_throws ErrorException convert(AHSV, RGB(1,0,1), 0.5)

    # issue #144
    @test_throws ErrorException convert(RGB24, Gray24(0.8))
    @test_throws ErrorException convert(RGB, Gray(0.8))
end

@testset "alphacolor/coloralpha for instances" begin
    Cp3 = ColorTypes.parametric3
    @testset "alphacolor/coloralpha: $C" for C in Cp3
        cf64, cf32 = C{Float64}(1, 0.6, 0), C{Float32}(1, 0.6, 0)
        for f in (alphacolor, coloralpha)
            A = f(C)
            @test f(cf64) === A{Float64}(1, 0.6, 0, 1)
            @test f(cf64, 0.8) === A{Float64}(1, 0.6, 0, 0.8)
            @test f(cf32, 0.8) === A{Float32}(1, 0.6, 0, 0.8)
            @test f(cf32, 0.8N0f8) === A{Float32}(1, 0.6, 0, 0.8N0f8)
        end
    end
    Ct3 = unique(vcat(coloralpha.(Cp3), alphacolor.(Cp3)))
    @testset "alphacolor/coloralpha: $C" for C in Ct3
        cf64, cf32 = C{Float64}(1, 0.6, 0, 0.4), C{Float32}(1, 0.6, 0, 0.4)
        for f in (alphacolor, coloralpha)
            A = f(C)
            @test f(cf64) === A{Float64}(1, 0.6, 0, 0.4)
            @test f(cf64, 0.8) === A{Float64}(1, 0.6, 0, 0.8)
            @test f(cf32, 0.8) === A{Float32}(1, 0.6, 0, 0.8)
            @test f(cf32, 0.8N0f8) === A{Float32}(1, 0.6, 0, 0.8N0f8)
        end
    end
    @testset "alphacolor/coloralpha: $C" for C in (Gray, AGray, GrayA)
        cf64 = C === Gray ? Gray(0.6)   : C{Float64}(0.6, 0.4)
        cf32 = C === Gray ? Gray(0.6f0) : C{Float32}(0.6, 0.4)
        for f in (alphacolor, coloralpha)
            A = f(C)
            @test f(cf64) === A{Float64}(0.6, C === Gray ? 1 : 0.4)
            @test f(cf64, 0.8) === A{Float64}(0.6, 0.8)
            @test f(cf32, 0.8) === A{Float32}(0.6, 0.8)
            @test f(cf32, 0.8N0f8) === A{Float32}(0.6, 0.8N0f8)
        end
    end

    @test alphacolor(RGB{N0f8}(1,0.6,0), 0.8) === ARGB{N0f8}(1,0.6,0,0.8)
    @test coloralpha(RGB{N0f8}(1,0.6,0), 0.8) === RGBA{N0f8}(1,0.6,0,0.8)

    @test alphacolor(RGB24(1,0.6,0)) === ARGB32(1,0.6,0, 1)
    @test alphacolor(RGB24(1,0.6,0), 0.8) === ARGB32(1,0.6,0, 0.8)
    @test_throws MethodError coloralpha(RGB24(1,0.6,0))
    @test_throws MethodError coloralpha(RGB24(1,0.6,0), 0.8)

    @test alphacolor(ARGB32(1,0.6,0)) === ARGB32(1,0.6,0, 1)
    @test alphacolor(ARGB32(1,0.6,0), 0.8) === ARGB32(1,0.6,0, 0.8)
    @test_throws MethodError coloralpha(ARGB32(1,0.6,0))
    @test_throws MethodError coloralpha(ARGB32(1,0.6,0), 0.8)

    @test alphacolor(Gray24(0.6)) === AGray32(0.6, 1)
    @test alphacolor(Gray24(0.6), 0.8) === AGray32(0.6, 0.8)
    @test_throws MethodError coloralpha(Gray24(0.6))
    @test_throws MethodError coloralpha(Gray24(0.6), 0.8)

    @test alphacolor(AGray32(0.6)) === AGray32(0.6, 1)
    @test alphacolor(AGray32(0.6), 0.8) === AGray32(0.6, 0.8)
    @test_throws MethodError coloralpha(AGray32(0.6))
    @test_throws MethodError coloralpha(AGray32(0.6), 0.8)
end


### Prevent ambiguous definitions

# Certain types, like Gray24, reinterpret a UInt32 as having a
# particular color meaning. The problem with defining `convert`
# methods is that a UInt32 has a value, e.g., 0 = black and 1 = white.
# Users who want to interpret a UInt32 as a bit pattern should
# explicitly use `reinterpret`.
@testset "bit pattern ambiguities" begin
    @test_throws MethodError convert(UInt32, RGB24(1,1,1))
    @test_throws MethodError convert(UInt32, ARGB32(1,1,1,0))
    @test convert(UInt32, Gray24(1)) === UInt32(1)
    @test_throws InexactError convert(UInt32, Gray24(0.5))
    @test_throws MethodError convert(UInt32, AGray32(1,0))
    @test !(RGB24(1,1,1) == 0x00ffffff)
    @test !(ARGB32(1,1,1,0) == 0x00ffffff)
    @test Gray24(1) == 1
    @test !(Gray24(1) == 0x00ffffff)
    @test !(AGray32(1,0) == 0x00ffffff)
    @test_throws ArgumentError RGB24(0x00ffffff)
    @test_throws ArgumentError ARGB32(0x00ffffff)
    @test_throws ArgumentError Gray24(0x00ffffff)
    @test_throws ArgumentError AGray32(0x00ffffff)
    @test_throws ArgumentError RGB24[0x00000000,0x00808080]
    @test_throws ArgumentError RGB24[0x00000000,0x00808080,0x00ffffff]
    @test_throws ArgumentError RGB24[0x00000000,0x00808080,0x00ffffff,0x000000ff]
end
