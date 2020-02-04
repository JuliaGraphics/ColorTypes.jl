using ColorTypes, FixedPointNumbers
using Test

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

@testset "conversions between different spaces" begin
    @test_throws ErrorException convert(HSV, RGB(1,0,1))
    @test_throws ErrorException convert(AHSV, RGB(1,0,1), 0.5)

    # issue #144
    @test_throws ErrorException convert(RGB24, Gray24(0.8))
    @test_throws ErrorException convert(RGB, Gray(0.8))
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
