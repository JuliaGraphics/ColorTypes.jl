using ColorTypes, FixedPointNumbers
using Test

@testset "RGB accessors" begin

    # This also checks that the constructor order is the same, even if the
    # storage order is not (e.g. RGB vs BGR)
    Crgb = filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
    @testset "accessors for $C and its transparent color" for C in Crgb
        rgb = C(1, 0.5, 0)
        @test alpha(rgb) === 1.0
        @test red(rgb)   === rgb.r === 1.0
        @test green(rgb) === rgb.g === 0.5
        @test blue(rgb)  === rgb.b === 0.0

        argb = alphacolor(C)(1, 0.5, 0, 0.8)
        rgba = coloralpha(C)(1, 0.5, 0, 0.8)

        @test alpha(argb) === argb.alpha === 0.8
        @test red(argb)   === argb.r === 1.0
        @test green(argb) === argb.g === 0.5
        @test blue(argb)  === argb.b === 0.0

        @test alpha(rgba) === rgba.alpha === 0.8
        @test red(rgba)   === rgba.r === 1.0
        @test green(rgba) === rgba.g === 0.5
        @test blue(rgba)  === rgba.b === 0.0
    end
    @testset "accessors for RGB24 and ARGB32" begin
        rgb24 = RGB24(1, 0.5, 0)
        @test alpha(rgb24) === 1.0N0f8
        @test red(rgb24)   === 1.0N0f8
        @test green(rgb24) === 0.5N0f8
        @test blue(rgb24)  === 0.0N0f8

        argb32 = ARGB32(1, 0.5, 0, 0.8)
        @test alpha(argb32) === 0.8N0f8
        @test red(argb32)   === 1.0N0f8
        @test green(argb32) === 0.5N0f8
        @test blue(argb32)  === 0.0N0f8
    end

    @test_throws MethodError red(HSV(100, 0.6, 0.4))
end

@testset "alpha" begin
    @test alpha(RGB24(0.2, 0.3, 0.4)) === 1N0f8
    @test alpha(ARGB32(0.2, 0.3, 0.4, 0.8)) === 0.8N0f8
    @test alpha(HSV(100, 0.4, 0.6)) === 1.0
    @test alpha(HSVA(100, 0.4, 0.6, 0.8)) === 0.8
    @test alpha(AHSV{Float32}(100, 0.4, 0.6, 0.8)) === 0.8f0
end

@testset "gray" begin
    @test gray(Gray(0.2)) === 0.2
    @test gray(GrayA(0.2, 0.8)) === 0.2
    @test gray(AGray{Float32}(0.2, 0.8)) === 0.2f0
    @test gray(Gray24(0.2)) === N0f8(0.2)
    @test gray(AGray32(0.2, 0.8)) === N0f8(0.2)
    @test gray(Gray{Bool}(1)) === true
    @test gray(Gray{Bool}(0)) === false

    @testset "gray for Real" begin
        @test gray(1) === 1
        @test gray(0.8) === 0.8
        @test gray(0.8N0f8) === 0.8N0f8
        @test gray(true) === true
        @test gray(false) === false
    end
    @test_throws MethodError gray(HSVA(100, 0.4, 0.6, 0.8))
end

@testset "chroma" begin
    for C in [Lab, DIN99, DIN99o, DIN99d, Luv]
        @test chroma(C(60, -40, 30)) ≈ 50.0
    end
    @test chroma(LCHab(60, 40, 30)) ≈ 40.0
    @test chroma(LCHuv(60, 40, 30)) ≈ 40.0
    @test chroma(LabA(60, -40, 30, 0.5)) ≈ 50.0
    @test chroma(ALab(60, -40, 30, 0.5)) ≈ 50.0
    @inferred chroma(LCHab(60, 40, 30))
    @inferred chroma(LCHuv(6f1, 4f1, 3f1))
    @inferred chroma(LabA(60, -40, 30, 0.5))
    @test_throws MethodError chroma(HSV(30, 0.4, 0.6))
end

@testset "hue" begin
    @test hue(HSV(30, 0.4, 0.6)) ≈ 30.0
    @test hue(HSL(30, 0.4, 0.6)) ≈ 30.0
    @test hue(HSI(30, 0.4, 0.6)) ≈ 30.0
    for C in [Lab, DIN99, DIN99o, DIN99d, Luv]
        @test hue(C(60, -30, 30)) ≈ 135.0
    end
    @test hue(LCHab(60, 40, 30)) ≈ 30.0
    @test hue(LCHuv(60, 40, 30)) ≈ 30.0
    @test hue(LabA(60, -30, 30, 0.5)) ≈ 135.0
    @test hue(ALab(60, -30, 30, 0.5)) ≈ 135.0
    @inferred hue(LCHab(60, -30, 30))
    @inferred hue(LCHuv(6f1, -3f1, 3f1))
    @inferred hue(LabA(60, -30, 30, 0.5))
    @test hue(HSV(999, 0.4, 0.6)) == 999 # without normalization
end

@testset "length" begin
    @test length(RGB) == 3
    @test length(XRGB) == 3
    @test length(ARGB) == 4
    @test length(RGB24) == 3
    @test length(ARGB32) == 4
    @test length(Gray) == 1
    @test length(Gray24) == 1
    @test length(AGray32) == 2
    @test length(AGray{Float32}) == 2

    @test length(ARGB(1.0,0.8,0.6,0.4)) == 4
end

@testset "eltype" begin
    @test @inferred(eltype(Color{N0f8})) === N0f8
    @test @inferred(eltype(RGB{Float32})) === Float32
    @test @inferred(eltype(RGBA{Float64})) === Float64
    @test @inferred(eltype(RGB24)) === N0f8
    # @test eltype(RGB) == TypeVar(:T, Fractional)
    @inferred(eltype(RGB))      # just test that it doesn't error

    # for instances
    @test @inferred(eltype(RGB{N0f8}(1,0,0))) === N0f8
    @test @inferred(eltype(RGB(0x01,0x00,0x00))) === N0f8
    @test @inferred(eltype(RGB(1.0,0,0))) === Float64
    @test @inferred(eltype(ARGB(1.0,0.8,0.6,0.4))) === Float64
    @test @inferred(eltype(RGBA{Float32}(1.0,0.8,0.6,0.4))) === Float32
    @test @inferred(eltype(RGB24(1,0.5,0))) === N0f8
    @test @inferred(eltype(ARGB32(1,0.5,0,0.8))) === N0f8

    @test @inferred(eltype(Gray(1))) === N0f8
    @test @inferred(eltype(Gray(1.0))) === Float64
    @test @inferred(eltype(Gray24(0.8))) === N0f8
    @test @inferred(eltype(AGray32(0.8))) === N0f8

    @test @inferred(eltype(HSV(30,1,0))) === Float32
    @test @inferred(eltype(HSV(30,1.0,0.0))) === Float64

    # eltypes_supported
    @test N0f8 <: ColorTypes.eltypes_supported(RGB(1,0,0))
end

@testset "color_type" begin
    @test @inferred(color_type(RGB)) === RGB
    @test @inferred(color_type(RGBA)) === RGB
    @test @inferred(color_type(ARGB)) === RGB
    @test @inferred(color_type(RGB{N0f8})) === RGB{N0f8}
    @test @inferred(color_type(RGBA{Float32})) === RGB{Float32}
    @test @inferred(color_type(ARGB{Float64})) === RGB{Float64}
    @test @inferred(color_type(RGB24)) === RGB24
    @test @inferred(color_type(ARGB32)) === RGB24

    @test @inferred(color_type(BGR)) === BGR
    @test @inferred(color_type(XRGB)) === XRGB
    @test @inferred(color_type(RGBX)) === RGBX

    @test @inferred(color_type(Gray)) === Gray
    @test @inferred(color_type(GrayA)) == Gray{<:ColorTypes.Fractional} # FIXME
    @test @inferred(color_type(AGray)) == Gray{<:ColorTypes.Fractional} # FIXME
    @test_broken @inferred(color_type(GrayA)) === Gray
    @test_broken @inferred(color_type(AGray)) === Gray
    @test @inferred(color_type(Gray{N0f8})) === Gray{N0f8}
    @test @inferred(color_type(GrayA{Float32})) === Gray{Float32}
    @test @inferred(color_type(AGray{Float64})) === Gray{Float64}
    @test @inferred(color_type(Gray24)) === Gray24
    @test @inferred(color_type(AGray32)) === Gray24

    @test @inferred(color_type(HSV)) === HSV
    @test @inferred(color_type(HSVA)) === HSV
    @test @inferred(color_type(AHSV)) === HSV
    @test @inferred(color_type(HSV{Float16})) === HSV{Float16}
    @test @inferred(color_type(HSVA{Float32})) === HSV{Float32}
    @test @inferred(color_type(AHSV{Float64})) === HSV{Float64}

    @test @inferred(color_type(AbstractRGB)) === AbstractRGB
    @test @inferred(color_type(AbstractRGBA)) === AbstractRGB
    @test @inferred(color_type(AbstractARGB)) === AbstractRGB
    @test @inferred(color_type(AbstractRGB{N0f8})) === AbstractRGB{N0f8}
    @test @inferred(color_type(AbstractRGBA{RGB,Float32})) === RGB
    @test @inferred(color_type(AbstractARGB{RGB{Float64},Float64})) === RGB{Float64}
    @test @inferred(color_type(TransparentRGB)) === AbstractRGB

    @test @inferred(color_type(AbstractGrayA)) === AbstractGray
    @test @inferred(color_type(AbstractAGray)) === AbstractGray
    @test @inferred(color_type(TransparentGray)) === AbstractGray

    @test @inferred(color_type(Color3)) === Color3
    @test @inferred(color_type(Transparent3)) === Color3
    @test @inferred(color_type(Color)) === Color
    @test @inferred(color_type(TransparentColor)) === Color
    @test @inferred(color_type(TransparentColor{RGB})) === RGB
    @test @inferred(color_type(TransparentColor{RGB,Float64})) === RGB
    @test @inferred(color_type(TransparentColor{RGB{Float64},Float64})) === RGB{Float64}
    @test_throws MethodError color_type(Colorant{N0f8})

    @test_throws MethodError color_type(N0f8) === Gray{N0f8}

    # for instances
    @test @inferred(color_type(RGB{N0f8}(1,0,0))) === RGB{N0f8}
    @test @inferred(color_type(ARGB(1.0,0.8,0.6,0.4))) === RGB{Float64}
    @test @inferred(color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) === RGB{Float32}
    @test_throws MethodError color_type(1N0f8) === 1N0f8
end

@testset "base_color_type" begin
    @test @inferred(base_color_type(RGB)) === RGB
    @test @inferred(base_color_type(RGBA)) === RGB
    @test @inferred(base_color_type(ARGB)) === RGB
    @test @inferred(base_color_type(RGB{N0f8})) === RGB
    @test @inferred(base_color_type(RGBA{Float32})) === RGB
    @test @inferred(base_color_type(ARGB{Float64})) === RGB
    @test @inferred(base_color_type(RGB24)) === RGB24
    @test @inferred(base_color_type(ARGB32)) === RGB24

    @test @inferred(base_color_type(BGR)) === BGR
    @test @inferred(base_color_type(BGR{N0f8})) === BGR
    @test @inferred(base_color_type(XRGB)) === XRGB
    @test @inferred(base_color_type(RGBX)) === RGBX

    @test @inferred(base_color_type(Gray)) === Gray
    @test @inferred(base_color_type(GrayA)) === Gray
    @test @inferred(base_color_type(AGray)) === Gray
    @test @inferred(base_color_type(Gray{N0f8})) === Gray
    @test @inferred(base_color_type(GrayA{Float32})) === Gray
    @test @inferred(base_color_type(AGray{Float64})) === Gray
    @test @inferred(base_color_type(Gray24)) === Gray24
    @test @inferred(base_color_type(AGray32)) === Gray24

    @test @inferred(base_color_type(HSV)) === HSV
    @test @inferred(base_color_type(HSVA)) === HSV
    @test @inferred(base_color_type(AHSV)) === HSV
    @test @inferred(base_color_type(HSV{Float16})) === HSV
    @test @inferred(base_color_type(HSVA{Float32})) === HSV
    @test @inferred(base_color_type(AHSV{Float64})) === HSV

    @test @inferred(base_color_type(AbstractRGB)) === AbstractRGB
    @test @inferred(base_color_type(AbstractRGBA)) === AbstractRGB
    @test @inferred(base_color_type(AbstractARGB)) === AbstractRGB
    @test @inferred(base_color_type(AbstractRGB{N0f8})) === AbstractRGB
    @test @inferred(base_color_type(AbstractRGBA{RGB,Float32})) === RGB
    @test @inferred(base_color_type(AbstractARGB{RGB{Float64},Float64})) === RGB
    @test @inferred(base_color_type(TransparentRGB)) === AbstractRGB

    @test_broken @inferred(base_color_type(AbstractGrayA)) === AbstractGray
    @test_broken @inferred(base_color_type(AbstractAGray)) === AbstractGray
    @test_broken @inferred(base_color_type(TransparentGray)) === AbstractGray

    @test_broken @inferred(base_color_type(Color3)) === Color3
    @test_broken @inferred(base_color_type(Transparent3)) === Color3
    @test @inferred(base_color_type(Color)) === Color
    @test @inferred(base_color_type(TransparentColor)) === Color
    @test @inferred(base_color_type(TransparentColor{RGB})) === RGB
    @test @inferred(base_color_type(TransparentColor{RGB,Float64})) === RGB
    @test @inferred(base_color_type(TransparentColor{RGB{Float64},Float64})) === RGB
    @test_throws MethodError color_type(Colorant{N0f8})

    @test_broken base_color_type(N0f8) === Gray

    # for instances
    @test @inferred(base_color_type(RGB{N0f8}(1,0,0))) === RGB
    @test @inferred(base_color_type(ARGB(1.0,0.8,0.6,0.4))) === RGB
    @test @inferred(base_color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) === RGB
    @test @inferred(base_color_type(1N0f8)) === Gray
end

@testset "base_colorant_type" begin
    @test @inferred(base_colorant_type(RGB)) === RGB
    @test @inferred(base_colorant_type(RGBA)) === RGBA
    @test @inferred(base_colorant_type(ARGB)) === ARGB
    @test @inferred(base_colorant_type(RGB{N0f8})) === RGB
    @test @inferred(base_colorant_type(RGBA{Float32})) === RGBA
    @test @inferred(base_colorant_type(ARGB{Float64})) === ARGB
    @test @inferred(base_colorant_type(RGB24)) === RGB24
    @test @inferred(base_colorant_type(ARGB32)) === ARGB32

    @test @inferred(base_colorant_type(BGR)) === BGR
    @test @inferred(base_colorant_type(BGR{N0f8})) === BGR
    @test @inferred(base_colorant_type(XRGB)) === XRGB
    @test @inferred(base_colorant_type(RGBX)) === RGBX

    @test @inferred(base_colorant_type(Gray)) === Gray
    @test @inferred(base_colorant_type(GrayA)) === GrayA
    @test @inferred(base_colorant_type(AGray)) === AGray
    @test @inferred(base_colorant_type(Gray{N0f8})) === Gray
    @test @inferred(base_colorant_type(GrayA{Float32})) === GrayA
    @test @inferred(base_colorant_type(AGray{Float64})) === AGray
    @test @inferred(base_colorant_type(Gray24)) === Gray24
    @test @inferred(base_colorant_type(AGray32)) === AGray32

    @test @inferred(base_colorant_type(HSV)) === HSV
    @test @inferred(base_colorant_type(HSVA)) === HSVA
    @test @inferred(base_colorant_type(AHSV)) === AHSV
    @test @inferred(base_colorant_type(HSV{Float16})) === HSV
    @test @inferred(base_colorant_type(HSVA{Float32})) === HSVA
    @test @inferred(base_colorant_type(AHSV{Float64})) === AHSV

    @test @inferred(base_colorant_type(AbstractRGB)) === AbstractRGB
    @test @inferred(base_colorant_type(AbstractRGBA)) === ColorAlpha # FIXME
    @test @inferred(base_colorant_type(AbstractARGB)) === AlphaColor # FIXME
    @test_broken @inferred(base_colorant_type(AbstractRGBA)) === AbstractRGBA
    @test_broken @inferred(base_colorant_type(AbstractARGB)) === AbstractARGB
    @test @inferred(base_colorant_type(AbstractRGB{N0f8})) === AbstractRGB
    @test @inferred(base_colorant_type(AbstractRGBA{RGB,Float32})) === ColorAlpha # FIXME
    @test @inferred(base_colorant_type(AbstractARGB{RGB{Float64},Float64})) === AlphaColor # FIXME
    @test_broken @inferred(base_colorant_type(AbstractRGBA{RGB,Float32})) === RGBA
    @test_broken @inferred(base_colorant_type(AbstractARGB{RGB{Float64},Float64})) === ARGB
    @test @inferred(base_colorant_type(TransparentRGB)) === TransparentColor # FIXME
    @test_broken @inferred(base_colorant_type(TransparentRGB)) === TransparentRGB

    @test_broken @inferred(base_colorant_type(AbstractGrayA)) === AbstractGrayA
    @test_broken @inferred(base_colorant_type(AbstractAGray)) === AbstractAGray
    @test_broken @inferred(base_colorant_type(TransparentGray)) === TransparentGray

    @test_broken @inferred(base_colorant_type(Color3)) === Color3
    @test_broken @inferred(base_colorant_type(Transparent3)) === Transparent3
    @test @inferred(base_colorant_type(Color)) === Color
    @test @inferred(base_colorant_type(TransparentColor)) === TransparentColor
    @test @inferred(base_colorant_type(TransparentColor{RGB})) === TransparentColor # FIXME
    @test @inferred(base_colorant_type(TransparentColor{RGB,Float64})) === TransparentColor # FIXME
    @test @inferred(base_colorant_type(TransparentColor{RGB{Float64},Float64})) === TransparentColor # FIXME
    @test_broken @inferred(base_colorant_type(TransparentColor{RGB})) === TransparentRGB
    @test_broken @inferred(base_colorant_type(TransparentColor{RGB,Float64})) === TransparentRGB
    @test_broken @inferred(base_colorant_type(TransparentColor{RGB{Float64},Float64})) === TransparentRGB
    @test_throws MethodError color_type(Colorant{N0f8})

    @test_broken @inferred(base_colorant_type(N0f8)) === Gray

    # for instances
    @test @inferred(base_colorant_type(RGB{N0f8}(1,0,0))) === RGB
    @test @inferred(base_colorant_type(ARGB(1.0,0.8,0.6,0.4))) === ARGB
    @test @inferred(base_colorant_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) === RGBA
    @test_broken @inferred(base_colorant_type(1N0f8)) === Gray
end

# TODO: move `colorant_string` to `show.jl`
@testset "colorant_string" begin
    @test ColorTypes.colorant_string(Union{}) == "Union{}"
    @test ColorTypes.colorant_string(RGB{N0f8}) == "RGB"
    @test ColorTypes.colorant_string(HSV{Float32}) == "HSV"
    @test ColorTypes.colorant_string(RGB24) == "RGB24"
    @test ColorTypes.colorant_string(ARGB32) == "ARGB32"
    @test ColorTypes.colorant_string(Gray24) == "Gray24"
    @test ColorTypes.colorant_string(AGray32) == "AGray32"
    @test ColorTypes.colorant_string(RGB) == "RGB"
    @test_throws MethodError ColorTypes.colorant_string(Float32)
end

# TODO: move `colorant_string_with_eltype` to `show.jl`
@testset "colorant_string_with_eltype" begin
    @test ColorTypes.colorant_string_with_eltype(Union{}) == "Union{}"
    @test ColorTypes.colorant_string_with_eltype(RGB{N0f8}) == "RGB{N0f8}"
    @test ColorTypes.colorant_string_with_eltype(HSV{Float32}) == "HSV{Float32}"
    @test ColorTypes.colorant_string_with_eltype(RGB24) == "RGB24"
    @test ColorTypes.colorant_string_with_eltype(ARGB32) == "ARGB32"
    @test ColorTypes.colorant_string_with_eltype(Gray24) == "Gray24"
    @test ColorTypes.colorant_string_with_eltype(AGray32) == "AGray32"
    @test_broken ColorTypes.colorant_string_with_eltype(RGB) != "RGB{Any}" # TODO: define the appropriate expression
    @test ColorTypes.colorant_string_with_eltype(RGB{Union{}}) == "RGB{Union{}}"
    @test_throws MethodError ColorTypes.colorant_string_with_eltype(Float32)
end

@testset "identities for Gray" begin
    @test oneunit(Gray{N0f8}) === Gray{N0f8}(1)
    @test zero(Gray{N0f8}) === Gray{N0f8}(0)
    @test oneunit(Gray) === Gray{N0f8}(1)
    @test zero(Gray) === Gray{N0f8}(0)

    @test_throws MethodError oneunit(Gray24)
    @test_throws MethodError zero(Gray24)
    @test_throws MethodError oneunit(AGray32)
    @test_throws MethodError zero(AGray32)
    @test_throws MethodError oneunit(AGray{N0f8})
    @test_throws MethodError zero(AGray{N0f8})
    @test_throws MethodError oneunit(GrayA{Float32})
    @test_throws MethodError zero(GrayA{Float32})

    @test_throws MethodError oneunit(RGB{N0f8})
    @test_throws MethodError zero(RGB{N0f8})

    g = Gray{Float32}(0.8)
    @test_throws MethodError oneunit(g)
    @test_throws MethodError zero(g)

    @test_broken one(Gray{Float32}) * g == g * one(Gray{Float32}) == g
end
