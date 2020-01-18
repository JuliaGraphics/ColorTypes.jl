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
