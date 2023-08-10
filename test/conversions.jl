using ColorTypes
using ColorTypes.FixedPointNumbers
using Test
using ColorTypes: ColorTypeResolutionError

@isdefined(CustomTypes) || include("customtypes.jl")
using .CustomTypes

@testset "rgb promotions" begin
    @test promote( RGB{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === ( RGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8),  RGB{Float64}(0.3,0.8,0.1))
    @test promote( RGB{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test promote( RGB{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test promote(RGBA{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test promote(RGBA{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test promote(ARGB{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test promote(ARGB{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))

    @test promote( RGB24(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === ( RGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8),  RGB{Float64}(0.3,0.8,0.1))
    @test promote( RGB24(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test promote( RGB24(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test promote(ARGB32(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test promote(ARGB32(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))

    @test promote( RGB24(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === ( RGB{N0f8}(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1))
    @test promote( RGB24(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1)) === (RGBA{N0f8}(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1))
    @test promote( RGB24(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{N0f8}(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1))
    @test promote(ARGB32(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === (ARGB{N0f8}(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1))
    @test promote(ARGB32(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{N0f8}(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1))

    @test promote(RGBX{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (RGBX{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBX{Float64}(0.3,0.8,0.1))
    @test promote(RGBX{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test promote(RGBX{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))
    @test promote(XRGB{N0f8}(0.2,0.3,0.4),  RGB(0.3,0.8,0.1)) === (XRGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), XRGB{Float64}(0.3,0.8,0.1))
    @test promote(XRGB{N0f8}(0.2,0.3,0.4), RGBA(0.3,0.8,0.1)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGBA{Float64}(0.3,0.8,0.1))
    @test promote(XRGB{N0f8}(0.2,0.3,0.4), ARGB(0.3,0.8,0.1)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), ARGB{Float64}(0.3,0.8,0.1))

    @test promote(RGBX(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === (RGBX{Float64}(0.2,0.3,0.4), RGBX{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test promote(RGBX(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1)) === (RGBA{Float64}(0.2,0.3,0.4), RGBA{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test promote(RGBX(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{Float64}(0.2,0.3,0.4), ARGB{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test promote(XRGB(0.2,0.3,0.4),  RGB{N0f8}(0.3,0.8,0.1)) === (XRGB{Float64}(0.2,0.3,0.4), XRGB{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test promote(XRGB(0.2,0.3,0.4), RGBA{N0f8}(0.3,0.8,0.1)) === (RGBA{Float64}(0.2,0.3,0.4), RGBA{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))
    @test promote(XRGB(0.2,0.3,0.4), ARGB{N0f8}(0.3,0.8,0.1)) === (ARGB{Float64}(0.2,0.3,0.4), ARGB{Float64}(0.3N0f8,0.8N0f8,0.1N0f8))

    @test promote(RGB24(0.2,0.3,0.4), ARGB32(0.3,0.8,0.1)) === (ARGB32(0.2,0.3,0.4), ARGB32(0.3,0.8,0.1))

    @test promote_type(RGB, RGB) === RGB
    @test promote_type(RGB, RGB{Float16}) === RGB

    @test promote_type(RGB, RGBA) === RGBA
    @test promote_type(ARGB, RGB) === ARGB
    @test promote_type(RGB, RGBA{Float16}) === RGBA
    @test promote_type(ARGB, RGB{Float16}) === ARGB

    @test promote_type(RGBA, RGBA) === RGBA
    @test promote_type(ARGB, ARGB) === ARGB
    @test promote_type(ARGB, RGBA) === ARGB
    @test promote_type(RGBA, RGBA{Float16}) === RGBA
    @test promote_type(ARGB, ARGB{Float16}) === ARGB
    @test promote_type(ARGB, RGBA{Float16}) === ARGB

    @test promote_type(RGB, RGB24) === RGB
    @test promote_type(BGR, RGB24) === RGB
    @test promote_type(XRGB, RGB24) === XRGB
    @test promote_type(RGBX, RGB24) === RGBX
    @test promote_type(RGB, ARGB32) === ARGB
    @test promote_type(BGR, ARGB32) === ARGB
    @test promote_type(XRGB, ARGB32) === ARGB
    @test promote_type(RGBX, ARGB32) === ARGB

    @test promote_type(RGB, BGR) === RGB
    @test promote_type(RGB, BGR{Float16}) === RGB
    @test promote_type(BGR, RGB{Float16}) === RGB

    @test promote_type(RGB, RGBX) === RGBX
    @test promote_type(XRGB, RGB) === XRGB
    @test promote_type(RGB, RGBX{Float16}) === RGBX
    @test promote_type(XRGB, RGB{Float16}) === XRGB

    @test promote_type(AbstractRGB, RGB{Float16}) === RGB
    @test promote_type(RGB, AbstractRGB{Float16}) === RGB
    @test promote_type(AbstractRGB{Float16}, RGB{Float16}) === RGB{Float16}
    @test promote_type(AbstractRGB{Float16}, RGB24) === RGB{Float32}
end

@testset "hsv promotions" begin
    @test promote( HSV{Float32}(100,0.3,0.4),  HSV(200,0.8,0.1)) === ( HSV{Float64}(100,0.3f0,0.4f0),  HSV{Float64}(200,0.8,0.1))
    @test promote( HSV{Float32}(100,0.3,0.4), HSVA(200,0.8,0.1)) === (HSVA{Float64}(100,0.3f0,0.4f0), HSVA{Float64}(200,0.8,0.1))
    @test promote( HSV{Float32}(100,0.3,0.4), AHSV(200,0.8,0.1)) === (AHSV{Float64}(100,0.3f0,0.4f0), AHSV{Float64}(200,0.8,0.1))
    @test promote(HSVA{Float32}(100,0.3,0.4),  HSV(200,0.8,0.1)) === (HSVA{Float64}(100,0.3f0,0.4f0), HSVA{Float64}(200,0.8,0.1))
    @test promote(HSVA{Float32}(100,0.3,0.4), HSVA(200,0.8,0.1)) === (HSVA{Float64}(100,0.3f0,0.4f0), HSVA{Float64}(200,0.8,0.1))
    @test promote(AHSV{Float32}(100,0.3,0.4),  HSV(200,0.8,0.1)) === (AHSV{Float64}(100,0.3f0,0.4f0), AHSV{Float64}(200,0.8,0.1))
    @test promote(AHSV{Float32}(100,0.3,0.4), AHSV(200,0.8,0.1)) === (AHSV{Float64}(100,0.3f0,0.4f0), AHSV{Float64}(200,0.8,0.1))

    @test promote_type(HSV, HSV) === HSV
    @test promote_type(HSV, HSV{Float16}) === HSV

    @test promote_type(HSV, HSVA) === HSVA
    @test promote_type(AHSV, HSV) === AHSV
    @test promote_type(HSV, HSVA{Float16}) === HSVA
    @test promote_type(AHSV, HSV{Float16}) === AHSV
end

@testset "gray promotions" begin
    @test promote( Gray{N0f8}(0.2),  Gray(0.3)) === ( Gray{Float64}(0.2N0f8),  Gray{Float64}(0.3))
    @test promote( Gray{N0f8}(0.2), GrayA(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test promote( Gray{N0f8}(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test promote(GrayA{N0f8}(0.2),  Gray(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test promote(GrayA{N0f8}(0.2), GrayA(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test promote(AGray{N0f8}(0.2),  Gray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test promote(AGray{N0f8}(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))

    @test promote( Gray24(0.2),  Gray(0.3)) === ( Gray{Float64}(0.2N0f8),  Gray{Float64}(0.3))
    @test promote( Gray24(0.2), GrayA(0.3)) === (GrayA{Float64}(0.2N0f8), GrayA{Float64}(0.3))
    @test promote( Gray24(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test promote(AGray32(0.2),  Gray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test promote(AGray32(0.2), AGray(0.3)) === (AGray{Float64}(0.2N0f8), AGray{Float64}(0.3))
    @test promote( Gray24(0.2),  Gray{N0f8}(0.3)) === ( Gray{N0f8}(0.2),  Gray{N0f8}(0.3))
    @test promote( Gray24(0.2), GrayA{N0f8}(0.3)) === (GrayA{N0f8}(0.2), GrayA{N0f8}(0.3))
    @test promote( Gray24(0.2), AGray{N0f8}(0.3)) === (AGray{N0f8}(0.2), AGray{N0f8}(0.3))
    @test promote(AGray32(0.2),  Gray{N0f8}(0.3)) === (AGray{N0f8}(0.2), AGray{N0f8}(0.3))
    @test promote(AGray32(0.2), AGray{N0f8}(0.3)) === (AGray{N0f8}(0.2), AGray{N0f8}(0.3))

    @test promote(AGray32(0.2), Gray24(0.3)) === (AGray32(0.2N0f8), AGray32(0.3))

    @test promote_type(Gray, Gray) === Gray
    @test promote_type(Gray, Gray{Float16}) === Gray

    @test promote_type(Gray, GrayA) === GrayA
    @test promote_type(AGray, Gray) === AGray
    @test promote_type(Gray, GrayA{Float16}) === GrayA
    @test promote_type(AGray, Gray{Float16}) === AGray

    @test promote_type(AGray, Gray{Bool}) === AGray

    @test promote_type(Gray, Gray24) === Gray
    @test promote_type(Gray, AGray32) === AGray

    @test promote_type(AbstractGray, Gray{Float16}) === Gray
    @test promote_type(Gray, AbstractGray{Float16}) === Gray
    @test promote_type(AbstractGray{Float16}, Gray{Float16}) === Gray{Float16}
    @test promote_type(AbstractGray{Float16}, Gray24) === Gray{Float32}
end

@testset "rgb and gray promotions" begin
    @test promote( RGB(0.2,0.3,0.4),  Gray(0.8)) === (RGB{Float64}(0.2,0.3,0.4), RGB{Float64}(0.8,0.8,0.8))
    @test promote( RGB(0.2,0.3,0.4), GrayA(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote( RGB(0.2,0.3,0.4), AGray(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(RGBA(0.2,0.3,0.4),  Gray(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote(RGBA(0.2,0.3,0.4), GrayA(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote(RGBA(0.2,0.3,0.4), AGray(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB(0.2,0.3,0.4),  Gray(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB(0.2,0.3,0.4), GrayA(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB(0.2,0.3,0.4), AGray(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8,0.8,0.8,1))

    @test promote( RGB{N0f8}(0.2,0.3,0.4),  Gray(0.8)) === (RGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGB{Float64}(0.8,0.8,0.8))
    @test promote( RGB{N0f8}(0.2,0.3,0.4), GrayA(0.8)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote( RGB{N0f8}(0.2,0.3,0.4), AGray(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(RGBA{N0f8}(0.2,0.3,0.4),  Gray(0.8)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote(RGBA{N0f8}(0.2,0.3,0.4), GrayA(0.8)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote(RGBA{N0f8}(0.2,0.3,0.4), AGray(0.8)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB{N0f8}(0.2,0.3,0.4),  Gray(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB{N0f8}(0.2,0.3,0.4), GrayA(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB{N0f8}(0.2,0.3,0.4), AGray(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))

    @test promote( RGB(0.2,0.3,0.4),  Gray{N0f8}(0.8)) === (RGB{Float64}(0.2,0.3,0.4), RGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8))
    @test promote( RGB(0.2,0.3,0.4), GrayA{N0f8}(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote( RGB(0.2,0.3,0.4), AGray{N0f8}(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(RGBA(0.2,0.3,0.4),  Gray{N0f8}(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(RGBA(0.2,0.3,0.4), GrayA{N0f8}(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(RGBA(0.2,0.3,0.4), AGray{N0f8}(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(ARGB(0.2,0.3,0.4),  Gray{N0f8}(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(ARGB(0.2,0.3,0.4), GrayA{N0f8}(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(ARGB(0.2,0.3,0.4), AGray{N0f8}(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))

    @test promote( RGB24(0.2,0.3,0.4),  Gray(0.8)) === (RGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8), RGB{Float64}(0.8,0.8,0.8))
    @test promote( RGB24(0.2,0.3,0.4), GrayA(0.8)) === (RGBA{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), RGBA{Float64}(0.8,0.8,0.8,1))
    @test promote( RGB24(0.2,0.3,0.4), AGray(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB32(0.2,0.3,0.4),  Gray(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB32(0.2,0.3,0.4), GrayA(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))
    @test promote(ARGB32(0.2,0.3,0.4), AGray(0.8)) === (ARGB{Float64}(0.2N0f8,0.3N0f8,0.4N0f8,1), ARGB{Float64}(0.8,0.8,0.8,1))

    @test promote( RGB(0.2,0.3,0.4),  Gray24(0.8)) === (RGB{Float64}(0.2,0.3,0.4), RGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8))
    @test promote( RGB(0.2,0.3,0.4), AGray32(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(RGBA(0.2,0.3,0.4),  Gray24(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(RGBA(0.2,0.3,0.4), AGray32(0.8)) === (RGBA{Float64}(0.2,0.3,0.4,1), RGBA{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(ARGB(0.2,0.3,0.4),  Gray24(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))
    @test promote(ARGB(0.2,0.3,0.4), AGray32(0.8)) === (ARGB{Float64}(0.2,0.3,0.4,1), ARGB{Float64}(0.8N0f8,0.8N0f8,0.8N0f8,1))

    @test promote( RGB24(0.2,0.3,0.4),  Gray24(0.8)) === (RGB24(0.2,0.3,0.4), RGB24(0.8,0.8,0.8))
    @test promote( RGB24(0.2,0.3,0.4), AGray32(0.8)) === (ARGB32(0.2,0.3,0.4,1), ARGB32(0.8,0.8,0.8,1))
    @test promote(ARGB32(0.2,0.3,0.4),  Gray24(0.8)) === (ARGB32(0.2,0.3,0.4,1), ARGB32(0.8,0.8,0.8,1))
    @test promote(ARGB32(0.2,0.3,0.4), AGray32(0.8)) === (ARGB32(0.2,0.3,0.4,1), ARGB32(0.8,0.8,0.8,1))

    @test promote(RGB(0.2,0.3,0.4), Gray{Bool}(1)) === (RGB{Float64}(0.2,0.3,0.4), RGB{Float64}(1,1,1))
    @test promote(RGB{N0f8}(0.2,0.3,0.4), Gray{Bool}(1)) === (RGB{N0f8}(0.2,0.3,0.4), RGB{N0f8}(1,1,1))

    @test promote_type(RGB, Gray) === RGB
    @test promote_type(RGB, Gray{Float16}) === RGB
    @test promote_type(Gray, RGB{Float16}) === RGB

    @test promote_type(RGB, GrayA) === RGBA
    @test promote_type(AGray, RGB) === ARGB
    @test promote_type(RGB, GrayA{Float16}) === RGBA
    @test promote_type(AGray, RGB{Float16}) === ARGB

    @test promote_type(Gray, RGBA) === RGBA
    @test promote_type(ARGB, Gray) === ARGB
    @test promote_type(Gray, RGBA{Float16}) === RGBA
    @test promote_type(ARGB, Gray{Float16}) === ARGB

    @test promote_type(RGB, Gray{Bool}) === RGB
    @test promote_type(ARGB, Gray{Bool}) === ARGB
    @test promote_type(RGBA, Gray{Bool}) === RGBA

    @test promote_type(RGB, Gray24) === RGB
    @test promote_type(RGBA, Gray24) === RGBA
    @test promote_type(ARGB, AGray32) === ARGB
    @test promote_type(RGB24, Gray) === RGB
    @test promote_type(RGB24, GrayA) === RGBA
    @test promote_type(ARGB32, Gray) === ARGB
    @test promote_type(ARGB32, GrayA) === ARGB

    @test promote_type(AbstractRGB, Gray{Float16}) === RGB
    @test promote_type(RGB, AbstractGray{Float16}) === RGB
    @test promote_type(AbstractRGB{Float16}, Gray{Float16}) === RGB{Float16}
    @test promote_type(AbstractRGB{Float16}, Gray24) === RGB{Float32}

    @test promote_type(AbstractGray, RGB{Float16}) === RGB
    @test promote_type(Gray, AbstractRGB{Float16}) === RGB
    @test promote_type(AbstractGray{Float16}, RGB{Float16}) === RGB{Float16}
    @test promote_type(AbstractGray{Float16}, RGB24) === RGB{Float32}

    @test promote_type(AbstractRGB, AGray{Float16}) === ARGB
    @test promote_type(RGB, AbstractAGray{Gray{Float16},Float16}) === ARGB
    @test promote_type(AbstractRGB{Float16}, AGray{Float16}) === ARGB{Float16}
    @test promote_type(AbstractRGB{Float16}, AGray32) === ARGB{Float32}

    @test promote_type(AbstractGray, ARGB{Float16}) === ARGB
    @test promote_type(Gray, AbstractARGB{RGB{Float16},Float16}) === ARGB
    @test promote_type(AbstractGray{Float16}, ARGB{Float16}) === ARGB{Float16}
    @test promote_type(AbstractGray{Float16}, ARGB32) === ARGB{Float32}

    @test promote_type(AbstractARGB, AGray{Float16}) === ARGB
    @test promote_type(ARGB, AbstractAGray{Gray{Float16},Float16}) === ARGB
    @test promote_type(AbstractARGB{RGB{Float16},Float16}, AGray{Float16}) === ARGB{Float16}
    @test promote_type(AbstractARGB{RGB{Float16},Float16}, AGray32) === ARGB{Float32}
end

@testset "hsv and gray promotions" begin
    @test promote_type( HSV{Float16},  Gray{N0f8}) === HSV{Float32}
    @test promote_type( HSV{Float16}, GrayA{N0f8}) === HSVA{Float32}
    @test promote_type( HSV{Float16}, AGray{N0f8}) === AHSV{Float32}
    @test promote_type(HSVA{Float16},  Gray{N0f8}) === HSVA{Float32}
    @test promote_type(HSVA{Float16}, GrayA{N0f8}) === HSVA{Float32}
    @test promote_type(HSVA{Float16}, AGray{N0f8}) === HSVA{Float32}
    @test promote_type(AHSV{Float16},  Gray{N0f8}) === AHSV{Float32}
    @test promote_type(AHSV{Float16}, GrayA{N0f8}) === AHSV{Float32}
    @test promote_type(AHSV{Float16}, AGray{N0f8}) === AHSV{Float32}

    @test promote_type( HSV{Float16},  Gray24) === HSV{Float32}
    @test promote_type( HSV{Float16}, AGray32) === AHSV{Float32}
    @test promote_type(HSVA{Float16},  Gray24) === HSVA{Float32}
    @test promote_type(HSVA{Float16}, AGray32) === HSVA{Float32}
    @test promote_type(AHSV{Float16},  Gray24) === AHSV{Float32}
    @test promote_type(AHSV{Float16}, AGray32) === AHSV{Float32}

    @test promote_type(HSV{Float64}, Gray{Bool}) === HSV{Float64}
    @test promote_type(HSV{Float32}, Gray{Bool}) === HSV{Float32}

    @test promote_type(HSV, Gray) === HSV
    @test promote_type(HSV, Gray{Float16}) === HSV
    @test promote_type(Gray, HSV{Float16}) === HSV

    @test promote_type(HSV, GrayA) === HSVA
    @test promote_type(AGray, HSV) === AHSV
    @test promote_type(HSV, GrayA{Float16}) === HSVA
    @test promote_type(AGray, HSV{Float16}) === AHSV

    @test promote_type(Gray, HSVA) === HSVA
    @test promote_type(AHSV, Gray) === AHSV
    @test promote_type(Gray, HSVA{Float16}) === HSVA
    @test promote_type(AHSV, Gray{Float16}) === AHSV

    @test promote_type(GrayA, HSVA) === HSVA
    @test promote_type(AHSV, AGray) === AHSV
    @test promote_type(AGray, HSVA) === HSVA
    @test promote_type(AHSV, GrayA) === AHSV

    @test promote_type( HSV,  Gray24) === HSV
    @test promote_type( HSV, AGray32) === AHSV
    @test promote_type(HSVA,  Gray24) === HSVA
    @test promote_type(HSVA, AGray32) === HSVA
    @test promote_type(AHSV,  Gray24) === AHSV
    @test promote_type(AHSV, AGray32) === AHSV
end

# promotions between different color spaces
@testset "rgb and hsv promotions" begin
    # the current implementation is like `typejoin`.
    @test promote_type( RGB{Float64},  HSV{Float64}) == Color3{Float64}
    @test promote_type( RGB{Float64}, HSVA{Float64}) == ColorAlpha{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type( RGB{Float64}, AHSV{Float64}) == AlphaColor{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type(RGBA{Float64},  HSV{Float64}) == ColorAlpha{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type(RGBA{Float64}, HSVA{Float64}) == ColorAlpha{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type(RGBA{Float64}, AHSV{Float64}) == AlphaColor{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type(ARGB{Float64},  HSV{Float64}) == AlphaColor{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type(ARGB{Float64}, HSVA{Float64}) == AlphaColor{C,Float64,4} where {C<:Color3{Float64}}
    @test promote_type(ARGB{Float64}, AHSV{Float64}) == AlphaColor{C,Float64,4} where {C<:Color3{Float64}}

    @test promote_type( RGB{N0f8},  HSV{Float16}) == Color3{Float32}
    @test promote_type( RGB{N0f8}, HSVA{Float16}) == ColorAlpha{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type( RGB{N0f8}, AHSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(RGBA{N0f8},  HSV{Float16}) == ColorAlpha{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(RGBA{N0f8}, HSVA{Float16}) == ColorAlpha{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(RGBA{N0f8}, AHSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(ARGB{N0f8},  HSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(ARGB{N0f8}, HSVA{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(ARGB{N0f8}, AHSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}

    @test promote_type( RGB24,  HSV{Float16}) == Color3{Float32}
    @test promote_type( RGB24, HSVA{Float16}) == ColorAlpha{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type( RGB24, AHSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(ARGB32,  HSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(ARGB32, HSVA{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}
    @test promote_type(ARGB32, AHSV{Float16}) == AlphaColor{C,Float32,4} where {C<:Color3{Float32}}

    @test promote_type(RGB, HSV) == Color3
    @test promote_type(RGB, HSV{Float16}) == Color3
    @test promote_type(HSV, RGB{Float16}) == Color3

    @test promote_type(RGB, HSVA) == ColorAlpha{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(AHSV, RGB) == AlphaColor{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(RGB, HSVA{Float16}) == ColorAlpha{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(AHSV, RGB{Float16}) == AlphaColor{C,T,4} where {T, C<:Color3{T}}

    @test promote_type(HSV, RGBA) == ColorAlpha{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(ARGB, HSV) == AlphaColor{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(HSV, RGBA{Float16}) == ColorAlpha{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(ARGB, HSV{Float16}) == AlphaColor{C,T,4} where {T, C<:Color3{T}}

    @test promote_type(HSVA, RGBA) == ColorAlpha{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(ARGB, AHSV) == AlphaColor{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(HSVA, RGBA{Float16}) == ColorAlpha{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(ARGB, AHSV{Float16}) == AlphaColor{C,T,4} where {T, C<:Color3{T}}

    @test promote_type(AHSV, RGBA) == AlphaColor{C,T,4} where {T, C<:Color3{T}} # != Transparent3
    @test promote_type(ARGB, HSVA) == AlphaColor{C,T,4} where {T, C<:Color3{T}} # != Transparent3
    @test promote_type(AHSV, RGBA{Float16}) == AlphaColor{C,T,4} where {T, C<:Color3{T}} # != Transparent3
    @test promote_type(ARGB, HSVA{Float16}) == AlphaColor{C,T,4} where {T, C<:Color3{T}} # != Transparent3

    @test promote_type(RGB24, HSV) == Color3
    @test promote_type(RGB24, HSVA{Float16}) == ColorAlpha{C,Float32,4} where C<:Color3{Float32}
    @test promote_type(ARGB32, HSV) == AlphaColor{C,T,4} where {T, C<:Color3{T}}
    @test promote_type(ARGB32, HSVA{Float16}) == AlphaColor{C,Float32,4} where C<:Color3{Float32}
end

@testset "promotions with abstract types" begin
    @test promote_type(Colorant, RGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(Colorant{N0f8}, RGB{Float64}) == AlphaColor{C,Float64} where {C<:Color{Float64}}
    @test promote_type(Colorant{Float32,3}, RGB{Float64}) == AlphaColor{C,Float64,4} where C<:Color{Float64,3}
    @test promote_type(Color, RGB{Float64}) === Color
    @test promote_type(Color{N0f8}, RGB{Float64}) === Color{Float64}
    @test promote_type(Color{Float32,3}, RGB{Float64}) === Color{Float64,3}
    @test promote_type(AbstractRGB, RGB{Float64}) === RGB
    @test promote_type(AbstractRGB{N0f8}, RGB{Float64}) === RGB{Float64}
    @test promote_type(TransparentColor, RGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(TransparentColor{RGB{N0f8}}, RGB{Float64}) === ARGB
    @test promote_type(TransparentColor{RGB{N0f8},N0f8}, RGB{Float64}) === ARGB{Float64}
    @test promote_type(TransparentColor{RGB{N0f8},N0f8,4}, RGB{Float64}) === ARGB{Float64}
    @test promote_type(AlphaColor, RGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(AlphaColor{RGB{N0f8}}, RGB{Float64}) === ARGB
    @test promote_type(AlphaColor{RGB{N0f8},N0f8}, RGB{Float64}) === ARGB{Float64}
    @test promote_type(AlphaColor{RGB{N0f8},N0f8,4}, RGB{Float64}) === ARGB{Float64}
    @test promote_type(ColorAlpha, RGB{Float64}) === ColorAlpha{C,T} where {T, C<:Color{T}}
    @test promote_type(ColorAlpha{RGB{N0f8}}, RGB{Float64}) === RGBA
    @test promote_type(ColorAlpha{RGB{N0f8},N0f8}, RGB{Float64}) === RGBA{Float64}
    @test promote_type(ColorAlpha{RGB{N0f8},N0f8,4}, RGB{Float64}) === RGBA{Float64}

    @test promote_type(Colorant, ARGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(Colorant{N0f8}, ARGB{Float64}) == AlphaColor{C,Float64} where C<:Color{Float64}
    @test_broken promote_type(Colorant{Float32,4}, ARGB{Float64}) == AlphaColor{C,Float64,4} where C<:Color3{Float64}
    @test promote_type(Color, ARGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(AbstractRGB, ARGB{Float64}) === ARGB
    @test promote_type(AbstractRGB{N0f8}, ARGB{Float64}) === ARGB{Float64}
    @test promote_type(TransparentColor, ARGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(AlphaColor, ARGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(ColorAlpha, ARGB{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}

    @test promote_type(Colorant, RGBA{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(Colorant{N0f8}, RGBA{Float64}) == AlphaColor{C,Float64} where C<:Color{Float64}
    @test promote_type(Colorant{Float32,3}, RGBA{Float64}) == AlphaColor{C,Float64,4} where C<:Color3{Float64}
    @test promote_type(Color, RGBA{Float64}) == ColorAlpha{C,T} where {T, C<:Color{T}}
    @test promote_type(AbstractRGB, RGBA{Float64}) === RGBA
    @test promote_type(AbstractRGB{N0f8}, RGBA{Float64}) === RGBA{Float64}
    @test promote_type(TransparentColor, RGBA{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(AlphaColor, RGBA{Float64}) == AlphaColor{C,T} where {T, C<:Color{T}}
    @test promote_type(ColorAlpha, RGBA{Float64}) == ColorAlpha{C,T} where {T, C<:Color{T}}
end


@testset "rgb conversions with abstract types" begin
    c = RGB(1, 0.6, 0)
    @test convert(Colorant, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(Colorant{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test convert(Colorant{Float32,3}, c) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(Color{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test convert(Color{Float32,3}, c) === RGB{Float32}(1, 0.6, 0)
    @test convert(AbstractRGB, c) === RGB{Float64}(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, c) === RGB{N0f8}(1, 0.6, 0)
    @test_throws ColorTypeResolutionError convert(TransparentColor, c)
    @test_throws ColorTypeResolutionError convert(TransparentColor{RGB{N0f8}}, c)
    @test_throws ColorTypeResolutionError convert(TransparentColor{RGB{N0f8},N0f8}, c)
    @test_throws ColorTypeResolutionError convert(TransparentColor{RGB{N0f8},N0f8,4}, c)
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
    @test convert(AbstractRGB, ac) === RGB{Float64}(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, ac) === RGB{N0f8}(1, 0.6, 0)
    @test convert(TransparentColor, ac) === ARGB{Float64}(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, ac) === ARGB{Float64}(1, 0.6, 0, 0.8) # issue #126
    @test convert(ColorAlpha, ac) === RGBA{Float64}(1, 0.6, 0, 0.8) # issue #126

    ca = RGBA(1, 0.6, 0, 0.8)
    @test convert(Colorant, ca) === RGBA{Float64}(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, ca) === RGBA{N0f8}(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, ca) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, ca) === RGB{Float64}(1, 0.6, 0)
    @test convert(AbstractRGB, ca) === RGB{Float64}(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, ca) === RGB{N0f8}(1, 0.6, 0)
    @test convert(TransparentColor, ca) === RGBA{Float64}(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, ca) === ARGB{Float64}(1, 0.6, 0, 0.8) # issue #126
    @test convert(ColorAlpha, ca) === RGBA{Float64}(1, 0.6, 0, 0.8) # issue #126

    rgb24 = RGB24(1, 0.6, 0)
    @test convert(Colorant, rgb24) === RGB24(1, 0.6, 0)
    @test convert(Colorant{N0f8}, rgb24) === RGB24(1, 0.6, 0)
    @test_broken convert(Colorant{Float32,3}, rgb24) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, rgb24) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB, rgb24) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, rgb24) === RGB24(1, 0.6, 0)
    @test_throws ColorTypeResolutionError convert(TransparentColor, rgb24)
    @test convert(AlphaColor, rgb24) === ARGB32(1, 0.6, 0, 1)
    @test_throws MethodError convert(ColorAlpha, rgb24)

    argb32 = ARGB32(1, 0.6, 0, 0.8)
    @test convert(Colorant, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test convert(Colorant{N0f8}, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test_broken convert(Colorant{Float32,3}, argb32) === RGB{Float32}(1, 0.6, 0)
    @test convert(Color, argb32) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB, argb32) === RGB24(1, 0.6, 0)
    @test convert(AbstractRGB{N0f8}, argb32) === RGB24(1, 0.6, 0)
    @test convert(TransparentColor, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test convert(AlphaColor, argb32) === ARGB32(1, 0.6, 0, 0.8)
    @test_throws MethodError convert(ColorAlpha, argb32)

    @test convert(AbstractARGB{RGB,N0f8}, c, 0.2) === ARGB{N0f8}(1, 0.6, 0, 0.2)
    @test convert(AbstractRGBA{RGB,N0f8}, c, 0.2) === RGBA{N0f8}(1, 0.6, 0, 0.2)
    @test convert(AbstractARGB{RGB,N0f8}, rgb24, 0.2) === ARGB{N0f8}(1, 0.6, 0, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, ac, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, ca, 0.2)
    @test_throws MethodError convert(AbstractARGB{RGB,N0f8}, argb32, 0.2)
    @test convert(AbstractARGB{RGB24,N0f8}, rgb24, 0.2) === ARGB32(1, 0.6, 0, 0.2)
end

@testset "gray conversions with abstract types" begin
    c = Gray(0.4)
    @test convert(Colorant, c) === Gray{Float64}(0.4)
    @test convert(Colorant{N0f8}, c) === Gray{N0f8}(0.4)
    @test convert(Colorant{Float32,1}, c) === Gray{Float32}(0.4)
    @test convert(Color, c) === Gray{Float64}(0.4)
    @test_throws ColorTypeResolutionError convert(TransparentColor, c)
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
    @test_throws ColorTypeResolutionError convert(TransparentColor, gray24)
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
    @test convert(AbstractAGray{Gray24,N0f8}, gray24, 0.2) === AGray32(0.4, 0.2)
    @test_throws MethodError convert(AbstractAGray{Gray,N0f8}, ac, 0.2)
    @test_throws MethodError convert(AbstractAGray{Gray,N0f8}, ca, 0.2)
    @test_throws MethodError convert(AbstractAGray{Gray,N0f8}, agray32, 0.2)
end

@testset "conversions from/to real numbers" begin
    @test convert(Float64, Gray(0.6)) === 0.6
    @test Float32(Gray(0.6)) === 0.6f0
    @test float(Gray(0.6)) === 0.6
    @test real(Gray(0.6)) === 0.6
    @test real(Gray{Float16}) === Float16

    @test convert(N0f8, Gray24(0.6)) === N0f8(0.6)
    @test convert(Float64, Gray24(0.6)) === 0.6
    @test Float32(Gray24(0.6)) === 0.6f0
    @test float(Gray24(0.6)) === 0.6
    @test real(Gray24(0.6)) === N0f8(0.6)
    @test real(Gray24) === N0f8

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

    @test_throws MethodError real(Gray) # should be a concrete type
    @test_throws MethodError real(AGray(1.0))
    @test_throws MethodError real(GrayA{Float32})

    @test_throws ColorTypeResolutionError convert(Colorant, 0.6)
    @test_throws ColorTypeResolutionError convert(Color, 0.6)
    @test_throws MethodError convert(Color{N0f8,1}, 0.6)

    @test convert(GrayA, 0.6, 0.8) === GrayA{Float64}(0.6, 0.8)
    @test convert(AGray, 0, 1) === AGray{N0f8}(0, 1)

    @test convert(Gray, 2.0) === Gray{Float64}(2.0)
    @test_throws ArgumentError convert(Gray, 2)

    @test convert(RGB24, 0.6) === RGB24(0.6, 0.6, 0.6)
    @test convert(ARGB32, 0.6) === ARGB32(0.6, 0.6, 0.6, 1)
    @test convert(ARGB32, 0.6, 0.8) === ARGB32(0.6, 0.6, 0.6, 0.8)

    @test convert(RGB, 0.6) === RGB(0.6, 0.6, 0.6)
    @test convert(BGR, 0.6N0f8) === BGR{N0f8}(0.6, 0.6, 0.6)
    @test convert(ARGB, 0.6) === ARGB(0.6, 0.6, 0.6, 1)
    @test convert(RGBA, 0.6N0f8) === RGBA{N0f8}(0.6, 0.6, 0.6, 1)

    @test convert(ARGB, 0.6f0, 0.8f0) === ARGB{Float32}(0.6, 0.6, 0.6, 0.8)
    @test convert(RGBA{Float32}, 0.6, 0.8) === RGBA{Float32}(0.6, 0.6, 0.6, 0.8)

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
        @test convert(ARGB32, C(1,0.6,0), 0.2) === ARGB32(1,0.6,0,0.2)
    end
    @testset "$C conversions" for C in Ctransparent
        @test convert(C, C{Float64}(1,0.6,0,0.8)) === C{Float64}(1,0.6,0,0.8)
        @test convert(C{N0f8}, C{Float64}(1,0.6,0,0.8)) === C{N0f8}(1,0.6,0,0.8)
        @test convert(C, RGB24(1,0.6,0)) === C{N0f8}(1,0.6,0,1)
        @test convert(C, RGB24(1,0.6,0), 0.2) === C{N0f8}(1,0.6,0,0.2)
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

@testset "conversions in the same color space" begin
    @test convert(Cyanotype{Float32}, Cyanotype{Float64}(0.8)) === Cyanotype{Float32}(0.8)

    @test convert(C2, C2{Float64}(0.4,0.6)) === C2{Float64}(0.4,0.6)
    @test convert(C2{Float32}, C2{Float64}(0.4,0.6)) === C2{Float32}(0.4,0.6)
    @test convert(C2, C2A{Float64}(0.4,0.6,0.5)) === C2{Float64}(0.4,0.6)
    @test convert(C2A, C2A{Float32}(0.4,0.6,0.5)) === C2A{Float32}(0.4,0.6,0.5)
    @test convert(C2A, C2{Float64}(0.4,0.6)) === C2A{Float64}(0.4,0.6,1.0)
    @test convert(C2A, C2{Float32}(0.4,0.6), 0.25) === C2A{Float32}(0.4,0.6,0.25)

    @test convert(CMYK, CMYK{Float64}(0.2,0.4,0.6,0.8)) === CMYK{Float64}(0.2,0.4,0.6,0.8)
    @test convert(CMYK{Float32}, CMYK{Float64}(0.2,0.4,0.6,0.8)) === CMYK{Float32}(0.2,0.4,0.6,0.8)
    @test convert(CMYK, ACMYK{Float64}(0.2,0.4,0.6,0.8,0.5)) === CMYK{Float64}(0.2,0.4,0.6,0.8)
    @test convert(ACMYK, ACMYK{Float32}(0.2,0.4,0.6,0.8,0.5)) === ACMYK{Float32}(0.2,0.4,0.6,0.8,0.5)
    @test convert(ACMYK, CMYK{Float64}(0.2,0.4,0.6,0.8)) === ACMYK{Float64}(0.2,0.4,0.6,0.8,1.0)
    @test convert(ACMYK, CMYK{Float32}(0.2,0.4,0.6,0.8), 0.25) === ACMYK{Float32}(0.2,0.4,0.6,0.8,0.25)
end

@testset "conversions from gray to rgb" begin
    Crgb = filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
    Ctransparent = unique(vcat(coloralpha.(Crgb), alphacolor.(Crgb)))
    @testset "$C conversions" for C in Crgb
        @test convert(C,  Gray{N0f8}(0.4)    ) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C, GrayA{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C, AGray{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8},  Gray{N0f8}(0.4)    ) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8}, GrayA{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8}, AGray{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{Float32},  Gray{N0f8}(0.4)    ) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8)
        @test convert(C{Float32}, GrayA{N0f8}(0.4,0.8)) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8)
        @test convert(C{Float32}, AGray{N0f8}(0.4,0.8)) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8)
        @test convert(C{N0f8},  Gray{Float32}(0.4)    ) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8}, GrayA{Float32}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8}, AGray{Float32}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C,  Gray24(0.4)    ) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C, AGray32(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8},  Gray24(0.4)    ) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{N0f8}, AGray32(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4)
        @test convert(C{Float32},  Gray24(0.4)    ) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8)
        @test convert(C{Float32}, AGray32(0.4,0.8)) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8)
    end
    @testset "$C conversions" for C in Ctransparent
        @test convert(C,  Gray{N0f8}(0.4)    ) === C{N0f8}(0.4,0.4,0.4,1)
        @test convert(C,  Gray{N0f8}(0.4),0.2) === C{N0f8}(0.4,0.4,0.4,0.2)
        @test convert(C, GrayA{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C, AGray{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C{N0f8},  Gray{N0f8}(0.4)    ) === C{N0f8}(0.4,0.4,0.4,1)
        @test convert(C{N0f8},  Gray{N0f8}(0.4),0.2) === C{N0f8}(0.4,0.4,0.4,0.2)
        @test convert(C{N0f8}, GrayA{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C{N0f8}, AGray{N0f8}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C{Float32},  Gray{N0f8}(0.4)    ) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,1)
        @test convert(C{Float32},  Gray{N0f8}(0.4),0.2) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,0.2)
        @test convert(C{Float32}, GrayA{N0f8}(0.4,0.8)) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,0.8N0f8)
        @test convert(C{Float32}, AGray{N0f8}(0.4,0.8)) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,0.8N0f8)
        @test convert(C{N0f8},  Gray{Float32}(0.4)    ) === C{N0f8}(0.4,0.4,0.4,1)
        @test convert(C{N0f8},  Gray{Float32}(0.4),0.2) === C{N0f8}(0.4,0.4,0.4,0.2)
        @test convert(C{N0f8}, GrayA{Float32}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C{N0f8}, AGray{Float32}(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C,  Gray24(0.4)    ) === C{N0f8}(0.4,0.4,0.4,1)
        @test convert(C,  Gray24(0.4),0.2) === C{N0f8}(0.4,0.4,0.4,0.2)
        @test convert(C, AGray32(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C{N0f8},  Gray24(0.4)    ) === C{N0f8}(0.4,0.4,0.4,1)
        @test convert(C{N0f8},  Gray24(0.4),0.2) === C{N0f8}(0.4,0.4,0.4,0.2)
        @test convert(C{N0f8}, AGray32(0.4,0.8)) === C{N0f8}(0.4,0.4,0.4,0.8)
        @test convert(C{Float32},  Gray24(0.4)    ) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,1)
        @test convert(C{Float32},  Gray24(0.4),0.2) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,0.2)
        @test convert(C{Float32}, AGray32(0.4,0.8)) === C{Float32}(0.4N0f8,0.4N0f8,0.4N0f8,0.8N0f8)
    end
    @testset "RGB24 conversions" begin
        @test convert(RGB24,  Gray{N0f8}(0.4)    ) === RGB24(0.4,0.4,0.4)
        @test convert(RGB24, GrayA{N0f8}(0.4,0.8)) === RGB24(0.4,0.4,0.4)
        @test convert(RGB24, AGray{Float32}(0.4,0.8)) === RGB24(0.4,0.4,0.4)
        @test convert(RGB24,  Gray24(0.4)    ) === RGB24(0.4,0.4,0.4)
        @test convert(RGB24, AGray32(0.4,0.8)) === RGB24(0.4,0.4,0.4)
    end
    @testset "ARGB32 conversions" begin
        @test convert(ARGB32,  Gray{N0f8}(0.4)    ) === ARGB32(0.4,0.4,0.4,1)
        @test convert(ARGB32,  Gray{N0f8}(0.4),0.2) === ARGB32(0.4,0.4,0.4,0.2)
        @test convert(ARGB32, GrayA{N0f8}(0.4,0.8)) === ARGB32(0.4,0.4,0.4,0.8)
        @test convert(ARGB32, AGray{Float32}(0.4,0.8)) === ARGB32(0.4,0.4,0.4,0.8)
        @test convert(ARGB32,  Gray24(0.4)    ) === ARGB32(0.4,0.4,0.4,1)
        @test convert(ARGB32,  Gray24(0.4),0.2) === ARGB32(0.4,0.4,0.4,0.2)
        @test convert(ARGB32, AGray32(0.4,0.8)) === ARGB32(0.4,0.4,0.4,0.8)
    end
end

@testset "conversions from rgb to gray" begin
    # The rules are defined in Colors.jl, but we want to make sure it calls
    # the `convert` method.
    # Issue #277
    msg = "No conversion of RGB{N0f8}(0.0, 0.0, 0.0) to Gray{Float32} has been defined"
    @test_throws ErrorException(msg) Gray{Float32}(RGB())
end

@testset "conversions between different spaces" begin
    @test_throws ErrorException convert(HSV, RGB(1,0,1))
    @test_throws ErrorException convert(AHSV, RGB(1,0,1), 0.5)
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

@testset "reinterpret" begin
    @test reinterpret(UInt32, RGB24()) === 0x00000000
    @test reinterpret(UInt32, ARGB32()) === 0xff000000
    @test reinterpret(UInt32, Gray24()) === 0x00000000
    @test reinterpret(UInt32, AGray32()) === 0xff000000

    @test reinterpret(UInt32, RGB24(0.071,0.204,0.337)) === 0x00123456
    @test reinterpret(UInt32, ARGB32(0.071,0.204,0.337,0.671)) === 0xab123456
    @test reinterpret(UInt32, Gray24(0.071)) === 0x00121212
    @test reinterpret(UInt32, AGray32(0.071, 0.671)) === 0xab121212

    @test reinterpret(RGB24, 0x00123456) === RGB24(0.071,0.204,0.337)
    @test reinterpret(RGB24, 0xdc123456) ==  RGB24(0.071,0.204,0.337)
    @test reinterpret(RGB24, 0x00123456) !== reinterpret(RGB24, 0xdc123456)
    @test reinterpret(UInt32, reinterpret(RGB24, 0xdc123456)) === 0xdc123456

    @test reinterpret(ARGB32, 0xab123456) === ARGB32(0.071,0.204,0.337,0.671)

    @test reinterpret(Gray24, 0x00121212) === Gray24(0.071)
    @test reinterpret(Gray24, 0xdc121212) ==  Gray24(0.071)
    @test reinterpret(Gray24, 0x00121212) !== reinterpret(Gray24, 0xdc121212)
    @test reinterpret(UInt32, reinterpret(Gray24, 0xdc121212)) === 0xdc121212
    # the following behavior is undefined, so this is just for the regression test.
    @test reinterpret(Gray24, 0xdc00ff12) ==  Gray24(0.071)
    @test reinterpret(UInt32, reinterpret(Gray24, 0xdc00ff12)) === 0xdc00ff12

    @test reinterpret(AGray32, 0xab121212) === AGray32(0.071, 0.671)
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
    @test reinterpret(UInt32,   RGB24(0x000001)) === 0x00ffffff
    @test reinterpret(UInt32,  ARGB32(0x000000)) === 0xff000000
    @test reinterpret(UInt32,  Gray24(0x000000)) === 0x00000000
    @test reinterpret(UInt32, AGray32(0x000001)) === 0xffffffff
    ret = @test_throws ArgumentError RGB24(0x00ffffff)
    @test occursin("Use `reinterpret(RGB24, 0x00ffffff)`", ret.value.msg)
    ret = @test_throws ArgumentError ARGB32(0x00ffffff)
    @test occursin("Use `reinterpret(ARGB32, 0x00ffffff)`", ret.value.msg)
    ret = @test_throws ArgumentError Gray24(0x00ffffff)
    @test occursin("Use `reinterpret(Gray24, 0x00ffffff)`", ret.value.msg)
    ret = @test_throws ArgumentError AGray32(0x00ffffff)
    @test occursin("Use `reinterpret(AGray32, 0x00ffffff)`", ret.value.msg)
    c = 0x123456
    ret = @test_throws ArgumentError RGB24(c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF)
    @test !occursin("Use `reinterpret(RGB24", ret.value.msg)
    @test occursin("(0x00000012, 0x00000034, 0x00000056) are integers", ret.value.msg)
    @test_throws ArgumentError RGB24[0x00000000,0x00808080]
    @test_throws ArgumentError RGB24[0x00000000,0x00808080,0x00ffffff]
    @test_throws ArgumentError RGB24[0x00000000,0x00808080,0x00ffffff,0x000000ff]
end
