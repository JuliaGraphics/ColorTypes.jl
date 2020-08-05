using ColorTypes
using ColorTypes.FixedPointNumbers
using Test
using ColorTypes: ColorTypeResolutionError

# dummy types
struct C2{T <: Real} <: Color{T,2}
    c1::T; c2::T;
end
struct C2A{T} <: ColorAlpha{C2{T},T,3}
    c1::T; c2::T; alpha::T
end
struct C4{T} <: Color{T,4}
    c1::T; c2::T; c3::T; c4::T
end
struct AC4{T} <: AlphaColor{C4{T},T,5}
    alpha::T; c1::T; c2::T; c3::T; c4::T
    AC4{T}(c1, c2, c3, c4, alpha=1) where T = new{T}(alpha, c1, c2, c3, c4)
end

struct StrangeGray{Something,T <: Integer} <: AbstractGray{Normed{T}}
    val::T
    function StrangeGray{T}(g::Normed{T,f}) where {T,f}
        f == sizeof(T) || error()
        new{:X,T}(reinterpret(g))
    end
end
ColorTypes.gray(g::StrangeGray{X,T}) where {X, T} = reinterpret(Normed{T,sizeof(T)}, g.val)

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

@testset "compN" begin
    g = Gray{Float32}(0.5)
    @test comp1(g) === 0.5f0
    @test_throws ArgumentError comp2(g)
    @test_throws ArgumentError comp3(g)
    @test_throws ArgumentError comp4(g)
    @test_throws ArgumentError comp5(g)
    argb32 = ARGB32(1, 0.5, 0, 0.8)
    @test comp1(argb32) === 1N0f8
    @test comp2(argb32) === 0.5N0f8
    @test comp3(argb32) === 0N0f8
    @test comp4(argb32) === 0.8N0f8
    @test_throws ArgumentError comp5(argb32)
    agray32 = AGray32(0.2, 0.8)
    @test comp1(agray32) === 0.2N0f8
    @test comp2(agray32) === 0.8N0f8
    xrgb = XRGB(1, 0.5, 0)
    @test comp1(xrgb) === 1.0
    @test comp2(xrgb) === 0.5
    @test comp3(xrgb) === 0.0
    ret = @test_throws ArgumentError comp4(xrgb)
    @test occursin("3-component color XRGB{Float64} with `comp4`", ret.value.msg)
    ahsv = AHSV(100f0, 0.4f0, 0.6f0, 0.8f0)
    @test comp1(ahsv) === 100f0
    @test comp2(ahsv) === 0.4f0
    @test comp3(ahsv) === 0.6f0
    @test comp4(ahsv) === 0.8f0
    ac4 = AC4{Float32}(0.1, 0.2, 0.3, 0.4, 0.5)
    @test comp1(ac4) === 0.1f0
    @test comp2(ac4) === 0.2f0
    @test comp3(ac4) === 0.3f0
    @test comp4(ac4) === 0.4f0
    @test comp5(ac4) === 0.5f0
end

@testset "color" begin
    @test color(RGB(1, 0.5, 0)) === RGB{Float64}(1, 0.5, 0)
    @test color(RGBA{N0f8}(1, 0.5, 0, 0.8)) === RGB{N0f8}(1, 0.5, 0)
    @test color(ARGB{Float32}(1, 0.5, 0, 0.8)) === RGB{Float32}(1, 0.5, 0)
    @test color(RGB24(1, 0.5, 0)) === RGB24(1, 0.5, 0)
    @test color(ARGB32(1, 0.5, 0, 0.8)) === RGB24(1, 0.5, 0)

    @test color(HSV(100, 0.4, 0.6)) === HSV{Float64}(100, 0.4, 0.6)
    @test color(HSVA(100, 0.4, 0.6, 0.8)) === HSV{Float64}(100, 0.4, 0.6)
    @test color(AHSV{Float32}(100, 0.4, 0.6, 0.8)) === HSV{Float32}(100, 0.4, 0.6)

    @test color(Gray(0.2)) === Gray{Float64}(0.2)
    @test color(GrayA{N0f8}(0.2, 0.8)) === Gray{N0f8}(0.2)
    @test color(AGray{Float32}(0.2, 0.8)) === Gray{Float32}(0.2)
    @test color(Gray24(0.2)) === Gray24(0.2)
    @test color(AGray32(0.2, 0.8)) === Gray24(0.2)

    @test color(C2A{Float64}(0.1, 0.2, 0.8)) === C2{Float64}(0.1, 0.2)
    @test color(AC4{Float32}(0.1, 0.2, 0.3, 0.4, 0.8)) === C4{Float32}(0.1, 0.2, 0.3, 0.4)
end

@testset "to_top" begin
    @test ColorTypes.to_top(RGB{N0f8}) === Colorant{N0f8,3}
    @test ColorTypes.to_top(RGB24) === Colorant{N0f8,3}
    @test ColorTypes.to_top(Gray24) === Colorant{N0f8,1}
    @test ColorTypes.to_top(HSVA{Float32}) === Colorant{Float32,4}
    @test_throws MethodError ColorTypes.to_top(RGB)

    # for instances
    @test ColorTypes.to_top(RGB(1, 0.5, 0)) === Colorant{Float64,3}
    @test ColorTypes.to_top(AGray32(.8)) === Colorant{N0f8,2}
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
end

@testset "eltype_supported/issupported" begin
    @test Fractional <: @inferred(ColorTypes.eltypes_supported(RGB))
    @test N0f8 <: @inferred(ColorTypes.eltypes_supported(RGB(1,0,0)))
    @test @inferred(ColorTypes.issupported(Gray, Bool))
    @test @inferred(!ColorTypes.issupported(AGray, Bool))

    @test @inferred(ColorTypes.eltypes_supported(C2{Float32})) === Real
    @test_broken @inferred(ColorTypes.eltypes_supported(C2A)) === Real

    @test @inferred(ColorTypes.eltypes_supported(TransparentColor)) === Any

    ST = @inferred(ColorTypes.eltypes_supported(StrangeGray{:X}))
    @test ST == (Normed{T} where T <: Integer) # This is not a "strict" result.
    @test comp1(StrangeGray{UInt16}(1N14f2)) isa ST
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
    @test @inferred(color_type(Color{Float16})) === Color{Float16}
    @test @inferred(color_type(Color{Float16,2})) === Color{Float16,2}

    @test @inferred(color_type(AlphaColor)) === Color
    @test @inferred(color_type(AlphaColor{Gray{Float16},Float16}))   === Gray{Float16}
    @test @inferred(color_type(AlphaColor{Gray{Float16},Float16,2})) === Gray{Float16}
    @test @inferred(color_type(AlphaColor{RGB{N0f8},Float16,2}))     === RGB{N0f8} # inconsistent source

    @test @inferred(color_type(ColorAlpha)) === Color
    @test @inferred(color_type(ColorAlpha{Gray{Float16},Float16}))   === Gray{Float16}
    @test @inferred(color_type(ColorAlpha{Gray{Float16},Float16,2})) === Gray{Float16}
    @test @inferred(color_type(ColorAlpha{RGB{N0f8},Float16,2}))     === RGB{N0f8} # inconsistent source

    @test @inferred(color_type(TransparentColor)) === Color
    @test @inferred(color_type(TransparentColor{RGB})) === RGB
    @test @inferred(color_type(TransparentColor{RGB,Float64})) === RGB
    @test @inferred(color_type(TransparentColor{RGB{Float64},Float64})) === RGB{Float64}
    @test @inferred(color_type(TransparentColor{Gray,T,2} where T)) == Gray
    @test @inferred(color_type(TransparentColor{Gray{T},T,2} where T)) === Gray{T} where T

    @test @inferred(color_type(Colorant)) === Color
    @test @inferred(color_type(Colorant{N0f8})) === Color{N0f8}
    @test @inferred(color_type(Colorant{N0f8,2})) === Color{N0f8,2}
    @test @inferred(color_type(Colorant{T,2} where T)) == Color{T,2} where T

    @test @inferred(color_type(N0f8)) === Gray{N0f8}

    # for instances
    @test @inferred(color_type(RGB{N0f8}(1,0,0))) === RGB{N0f8}
    @test @inferred(color_type(ARGB(1.0,0.8,0.6,0.4))) === RGB{Float64}
    @test @inferred(color_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) === RGB{Float32}
    @test @inferred(color_type(1N0f8)) === Gray{N0f8}
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

    @test @inferred(base_color_type(AbstractGrayA)) === AbstractGray
    @test @inferred(base_color_type(AbstractAGray)) === AbstractGray
    @test @inferred(base_color_type(TransparentGray)) === AbstractGray

    @test @inferred(base_color_type(Color3)) === Color3
    @test @inferred(base_color_type(Transparent3)) === Color3

    @test @inferred(base_color_type(Color)) === Color
    @test @inferred(base_color_type(Color{Float16})) === Color
    @test @inferred(base_color_type(Color{Float16,2})) == Color{T,2} where T

    @test @inferred(base_color_type(AlphaColor)) === Color
    @test @inferred(base_color_type(AlphaColor{Gray{Float16},Float16}))   === Gray
    @test @inferred(base_color_type(AlphaColor{Gray{Float16},Float16,2})) === Gray
    @test @inferred(base_color_type(AlphaColor{RGB{N0f8},Float16,2}))     === RGB # inconsistent source

    @test @inferred(base_color_type(ColorAlpha)) === Color
    @test @inferred(base_color_type(ColorAlpha{Gray{Float16},Float16}))   === Gray
    @test @inferred(base_color_type(ColorAlpha{Gray{Float16},Float16,2})) === Gray
    @test @inferred(base_color_type(ColorAlpha{RGB{N0f8},Float16,2}))     === RGB # inconsistent source

    @test @inferred(base_color_type(TransparentColor)) === Color
    @test @inferred(base_color_type(TransparentColor{RGB})) === RGB
    @test @inferred(base_color_type(TransparentColor{RGB,Float64})) === RGB
    @test @inferred(base_color_type(TransparentColor{RGB{Float64},Float64})) === RGB
    @test @inferred(base_color_type(TransparentColor{Gray,T,2} where T)) == Gray
    @test @inferred(base_color_type(TransparentColor{Gray{T},T,2} where T)) == Gray

    @test @inferred(base_color_type(Colorant)) === Color
    @test @inferred(base_color_type(Colorant{N0f8})) === Color
    @test @inferred(base_color_type(Colorant{N0f8,2})) == Color{T,2} where T
    @test @inferred(base_color_type(Colorant{T,2} where T)) == Color{T,2} where T

    @test @inferred(base_color_type(N0f8)) === Gray

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
    @test @inferred(base_colorant_type(AbstractRGBA)) === ColorAlpha{C,T,4} where C<:AbstractRGB{T} where T
    @test @inferred(base_colorant_type(AbstractARGB)) === AlphaColor{C,T,4} where C<:AbstractRGB{T} where T
    @test @inferred(base_colorant_type(AbstractRGB{N0f8})) === AbstractRGB
    @test @inferred(base_colorant_type(AbstractRGBA{RGB,Float32})) === ColorAlpha{RGB{T},T,4} where T
    @test @inferred(base_colorant_type(AbstractARGB{RGB{Float64},Float64})) === AlphaColor{RGB{T},T,4} where T
    @test @inferred(base_colorant_type(TransparentRGB)) === TransparentColor{C,T,4} where C<:AbstractRGB{T} where T

    @test @inferred(base_colorant_type(AbstractGrayA)) === ColorAlpha{C,T,2} where C<:AbstractGray{T} where T
    @test @inferred(base_colorant_type(AbstractAGray)) === AlphaColor{C,T,2} where C<:AbstractGray{T} where T
    @test @inferred(base_colorant_type(TransparentGray)) === TransparentColor{C,T,2} where C<:AbstractGray{T} where T

    @test @inferred(base_colorant_type(Color3)) === Color3
    @test @inferred(base_colorant_type(Transparent3)) === TransparentColor{C,T,4} where C<:Color{T,3} where T

    @test @inferred(base_colorant_type(Color)) === Color
    @test @inferred(base_colorant_type(Color{Float16})) === Color
    @test @inferred(base_colorant_type(Color{Float16,2})) == Color{T,2} where T

    @test @inferred(base_colorant_type(AlphaColor)) === AlphaColor
    @test @inferred(base_colorant_type(AlphaColor{Gray{Float16},Float16}))   == AlphaColor{Gray{T},T} where T
    @test @inferred(base_colorant_type(AlphaColor{Gray{Float16},Float16,2})) == AlphaColor{Gray{T},T,2} where T
    @test @inferred(base_colorant_type(AlphaColor{RGB{N0f8},Float16,2}))     == AlphaColor{RGB{T},T,2} where T # inconsistent source

    @test @inferred(base_colorant_type(ColorAlpha)) === ColorAlpha
    @test @inferred(base_colorant_type(ColorAlpha{Gray{Float16},Float16}))   == ColorAlpha{Gray{T},T} where T
    @test @inferred(base_colorant_type(ColorAlpha{Gray{Float16},Float16,2})) == ColorAlpha{Gray{T},T,2} where T
    @test @inferred(base_colorant_type(ColorAlpha{RGB{N0f8},Float16,2}))     == ColorAlpha{RGB{T},T,2} where T # inconsistent source

    @test @inferred(base_colorant_type(TransparentColor)) === TransparentColor
    @test @inferred(base_colorant_type(TransparentColor{RGB})) == TransparentColor{RGB{T},T} where T
    @test @inferred(base_colorant_type(TransparentColor{RGB,Float64})) == TransparentColor{RGB{T},T} where T
    @test @inferred(base_colorant_type(TransparentColor{RGB{Float64},Float64})) == TransparentColor{RGB{T},T} where T
    @test @inferred(base_colorant_type(TransparentColor{Gray,T,2} where T)) == TransparentColor{Gray{T},T,2} where T
    @test @inferred(base_colorant_type(TransparentColor{Gray{T},T,2} where T)) == TransparentColor{Gray{T},T,2} where T

    @test @inferred(base_colorant_type(Colorant)) === Colorant
    @test @inferred(base_colorant_type(Colorant{N0f8})) === Colorant
    @test @inferred(base_colorant_type(Colorant{N0f8,2})) == Colorant{T,2} where T
    @test @inferred(base_colorant_type(Colorant{T,2} where T)) == Colorant{T,2} where T

    @test @inferred(base_colorant_type(N0f8)) === Gray

    # for instances
    @test @inferred(base_colorant_type(RGB{N0f8}(1,0,0))) === RGB
    @test @inferred(base_colorant_type(ARGB(1.0,0.8,0.6,0.4))) === ARGB
    @test @inferred(base_colorant_type(RGBA{Float32}(1.0,0.8,0.6,0.4))) === RGBA
    @test @inferred(base_colorant_type(1N0f8)) === Gray
end

@testset "floattype" begin
    @test @inferred(floattype(RGBA{Float32})) === RGBA{Float32}
    @test @inferred(floattype(BGR{N0f8})    ) === BGR{Float32}
    @test @inferred(floattype(Gray{N0f8})   ) === Gray{Float32}
    @test @inferred(floattype(Gray{Bool})   ) === Gray{Float32}
    @test @inferred(floattype(N0f8)         ) === Float32
    @test @inferred(floattype(Bool)         ) === Float32
    @test @inferred(floattype(Float32)      ) === Float32
    @test @inferred(floattype(Float64)      ) === Float64

    @test @inferred(floattype(ARGB32)) == ARGB{Float32}
    @test @inferred(floattype(AGray32)) == AGray{Float32}
    @test @inferred(floattype(RGB24)) == RGB{Float32}
    @test @inferred(floattype(Gray24)) == Gray{Float32}

    @test_throws MethodError @inferred(floattype(RGB))

    @test_throws MethodError @inferred(floattype(RGB{N0f8}(1,0,0)))
end

@testset "parametric_colorant" begin
    @test parametric_colorant(RGB{Float32}) === RGB{Float32}
    @test parametric_colorant(RGB)          === RGB
    @test parametric_colorant(BGR{Float32}) === BGR{Float32}
    @test parametric_colorant(RGB24)        === RGB{N0f8}
    @test parametric_colorant(Gray24)       === Gray{N0f8}
    @test parametric_colorant(ARGB32)       === ARGB{N0f8}
    @test parametric_colorant(AGray32)      === AGray{N0f8}
end

@testset "ccolor" begin
    @test @inferred(ccolor(Colorant, XRGB{N0f8})) === XRGB{N0f8}
    @test @inferred(ccolor(Colorant{N0f8}, RGBX{Float32})) === RGBX{N0f8}
    @test @inferred(ccolor(Colorant{N0f8,3}, BGR{N0f8})) === BGR{N0f8}

    @test_throws ColorTypeResolutionError ccolor(AbstractRGB, HSV{Float32})
    @test_throws ColorTypeResolutionError ccolor(AbstractRGB{N0f8}, HSV{Float32})
    @test @inferred(ccolor(AbstractRGB, RGB24)) === RGB24
    @test_throws ErrorException ccolor(AbstractRGB{Float32}, RGB24)

    @test @inferred(ccolor(RGB, RGB)) === RGB
    @test @inferred(ccolor(RGB, HSV)) === RGB
    @test @inferred(ccolor(Gray, Gray)) === Gray
    @test @inferred(ccolor(Gray, HSV)) === Gray

    @test @inferred(ccolor(RGB{Float32}, HSV{Float32})) === RGB{Float32}
    @test @inferred(ccolor(RGB{N0f8}, HSV{Float32})) === RGB{N0f8}
    @test @inferred(ccolor(RGB, HSV{Float32})) === RGB{Float32}

    @test @inferred(ccolor(ARGB{Float32}, HSV{Float32})) === ARGB{Float32}
    @test @inferred(ccolor(ARGB{N0f8}, HSV{Float32})) === ARGB{N0f8}
    @test @inferred(ccolor(ARGB, HSV{Float32})) === ARGB{Float32}

    @test @inferred(ccolor(RGB{Float32}, AHSV{Float32})) === RGB{Float32}
    @test @inferred(ccolor(RGB{N0f8}, AHSV{Float32})) === RGB{N0f8}
    @test @inferred(ccolor(RGB, AHSV{Float32})) === RGB{Float32}

    @test @inferred(ccolor(RGBA{Float32}, AHSV{Float32})) === RGBA{Float32}
    @test @inferred(ccolor(RGBA{N0f8}, AHSV{Float32})) === RGBA{N0f8}
    @test @inferred(ccolor(RGBA, AHSV{Float32})) === RGBA{Float32}

    @test @inferred(ccolor(HSV{Float32}, RGB{N0f8})) === HSV{Float32}
    @test @inferred(ccolor(HSV, RGB{N0f8})) === HSV{Float32}

    @test @inferred(ccolor(Gray{N0f8}, Bool)) === Gray{N0f8}
    @test @inferred(ccolor(Gray, Bool)) === Gray{Bool}
    @test @inferred(ccolor(Gray, Int)) === Gray{N0f8}
    @test @inferred(ccolor(Gray, Float32)) === Gray{Float32}

    @test @inferred(ccolor(RGB{N0f8}, Bool)) === RGB{N0f8}
    @test @inferred(ccolor(RGB, Bool)) === RGB{N0f8}
    @test @inferred(ccolor(RGB, Int)) === RGB{N0f8}
    @test @inferred(ccolor(RGB, Float32)) === RGB{Float32}

    @test_throws ColorTypeResolutionError ccolor(HSV, Int)

    @test @inferred(ccolor(RGB24, HSV{Float32})) === RGB24
    @test @inferred(ccolor(ARGB32, HSV{Float32})) === ARGB32
    @test @inferred(ccolor(Gray24, HSV{Float32})) === Gray24
    @test @inferred(ccolor(AGray32, HSV{Float32})) === AGray32

    @test @inferred(ccolor(RGB{N0f8}, RGB24)) === RGB{N0f8}
    @test @inferred(ccolor(ARGB{N0f8}, ARGB32)) === ARGB{N0f8}
    @test @inferred(ccolor(Gray{N0f8}, Gray24)) === Gray{N0f8}
    @test @inferred(ccolor(AGray{N0f8}, AGray32)) === AGray{N0f8}

    @test @inferred(ccolor(TransparentColor, AHSV{Float32})) === AHSV{Float32}

    # Ambiguous storage order, choose AlphaColor or ColorAlpha
    @test_throws ColorTypeResolutionError ccolor(TransparentColor, HSV{Float32})
    @test_throws ColorTypeResolutionError ccolor(TransparentColor{RGB}, HSV{Float32})
    @test_throws ColorTypeResolutionError ccolor(TransparentColor{RGB,Float64}, HSV{Float32})
    @test_throws ColorTypeResolutionError ccolor(TransparentColor{RGB{Float64},Float64}, HSV{Float32})
    @test_throws ColorTypeResolutionError ccolor(TransparentColor{RGB{Float64},Float64,4}, HSV{Float32})

    @test @inferred(ccolor(AlphaColor, RGB)) === ARGB
    @test @inferred(ccolor(AlphaColor, RGB{N0f8})) === ARGB{N0f8}
    @test @inferred(ccolor(AlphaColor, RGB24)) === ARGB32
    @test @inferred(ccolor(AbstractARGB, RGB)) === ARGB
    @test @inferred(ccolor(AbstractARGB, RGB{N0f8})) === ARGB{N0f8}
    @test @inferred(ccolor(AbstractARGB, RGB24)) === ARGB32

    for C in filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
        @test @inferred(ccolor(RGB24, C)) === RGB24
        @test @inferred(ccolor(ARGB32, C)) === ARGB32
        @test @inferred(ccolor(Gray24, C)) === Gray24
        @test @inferred(ccolor(AGray32, C)) === AGray32
    end

    @test_throws MethodError ccolor(RGB, RGB{N0f8}(1,0,0))
end

@testset "comparisons" begin
    Cp3 = ColorTypes.parametric3
    for C in unique(vcat(Cp3, coloralpha.(Cp3), alphacolor.(Cp3)))
        @test C{Float64}(1,0,0) == C{Float32}(1,0,0)
        @test C{Float32}(1,0,0) != C{Float32}(1,0,0.1)
    end

    for (a, b) in ((Gray(1.0), Gray(1)),
                   (GrayA(0.8, 0.6), AGray(0.8, 0.6)),
                   (RGB(1, 0.5, 0), BGR(1, 0.5, 0)),
                   (RGBA(1, 0.5, 0, 0.8), ABGR(1, 0.5, 0, 0.8)),
                   (Gray(0.8N0f8), Gray24(0.8)))
        local a, b
        @test a !== b
        @test a == b
        @test hash(a) == hash(b)
    end
    for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 0.9)),
                   (RGB(0.5, 0.5, 0.5), Gray(0.5)),
                   (HSV(0, 0, 0.5), HSV(100, 0, 0.5)), # grays
                   (Lab(70, 0, 60), LCHab(70, 60, 90)))
        local a, b
        @test a != b
        @test hash(a) != hash(b)
    end
    # It's not obvious whether we want these to compare as equal, but
    # whatever happens, you want hashing and equality-testing to yield the
    # same result
    for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 1)),
                   (HSV(100, 0.4, 0.6), AHSV(100, 0.4, 0.6, 1)))
        local a, b
        @test (a == b) == (hash(a) == hash(b))
    end
end

@testset "BigFloat comparisons" begin
    # issue #52
    @test AGray{BigFloat}(0.5,0.25) == AGray{BigFloat}(0.5,0.25)
    @test RGBA{BigFloat}(0.5, 0.25, 0.5, 0.5) == RGBA{BigFloat}(0.5, 0.25, 0.5, 0.5)
end

@testset "isapprox" begin
    @test Gray(0.8) ≈ Gray(0.8)
    @test Gray(0.8) ≈ Gray(0.8 + eps())
    @test Gray(0.8) ≈ Gray(0.8 - eps())
    @test !(Gray(0.8) ≈ Gray(0.80000002))
    @test Gray(0.8f0) ≈ Gray(0.80000002)
    @test Gray(0.8N0f8) ≈ Gray24(0.8)

    @test Gray(0.8) ≈ 0.8 + eps()
    @test 0.8 + eps() ≈ Gray(0.8)

    @test GrayA(0.8, 0.4) ≈ GrayA(0.8 + eps(), 0.4)
    @test GrayA(0.8, 0.4) ≈ GrayA(0.8, 0.4 + eps())
    @test GrayA(0.8, 0.4) ≈ GrayA(0.8 + eps(), 0.4 + eps())

    @test RGB(0.2, 0.8, 0.4) ≈ RGB(0.2, 0.8 + eps(), 0.4)
    @test RGBA(0.2, 0.8, 0.4, 0.2) ≈ RGBA(0.2, 0.8 + eps(), 0.4, 0.2 - eps())

    c_n0f8 = RGB{N0f8}(0.2, 0.69, 0.4)
    c_f32 = RGB{Float32}(0.2, 0.69, 0.4)
    @test c_n0f8 != c_f32 && c_n0f8 ≈ c_f32

    c1 = RGB(0.2, 0.8, 0.4)
    c2 = RGB(0.2, 0.7, 0.4)
    @test c1 ≈ c2 atol=0.11
    @test !isapprox(c1, c2; atol=0.09)
    @test c1 ≈ RGBX(0.2, 0.8, 0.4)
    @test !(c1 ≈ HSV(140.0f0,0.75f0,0.8f0))  # the latter comes from convert when using Colors
    @test !(HSV(0,0,0.5) ≈ HSV(100,0,0.5))
    @test HSVA(100,0.4,0.6,0.8) ≈ HSVA{Float32}(100,0.4,0.6,0.8)
end

@testset "isless" begin
    @test Gray(0.8) < Gray(0.9)
    @test Gray(0.8) <= Gray(0.9)
    @test Gray(0.9) <= Gray(0.9)
    @test Gray(0.9) > Gray(0.8)
    @test Gray(0.9) >= Gray(0.8)
    @test Gray(0.9) >= Gray(0.9)

    @test Gray(0.8f0) < Gray(0.9f0)
    @test Gray(0.8f0) <= Gray(0.9f0)
    @test Gray(0.9f0) <= Gray(0.9f0)
    @test Gray(0.9f0) > Gray(0.8f0)
    @test Gray(0.9f0) >= Gray(0.8f0)
    @test Gray(0.9f0) >= Gray(0.9f0)

    @test Gray(0.8N0f8) < Gray(0.9N0f8)
    @test Gray(0.8N0f8) <= Gray(0.9N0f8)
    @test Gray(0.9N0f8) <= Gray(0.9N0f8)
    @test Gray(0.9N0f8) > Gray(0.8N0f8)
    @test Gray(0.9N0f8) >= Gray(0.8N0f8)
    @test Gray(0.9N0f8) >= Gray(0.9N0f8)

    @test Gray(0.8) < Gray(0.9f0)
    @test Gray(0.8) <= Gray(0.9f0)
    # @test Gray(0.9) <= Gray(0.9f0) is not true due to approximation
    @test Gray(0.9) > Gray(0.8f0)
    @test Gray(0.9) >= Gray(0.8f0)
    @test Gray(0.9) >= Gray(0.9f0)

    @test Gray(0.8f0) < Gray(0.9N0f8)
    @test Gray(0.8f0) <= Gray(0.9N0f8)
    @test Gray(0.9f0) <= Gray(0.9N0f8)
    @test Gray(0.9f0) > Gray(0.8N0f8)
    @test Gray(0.9f0) >= Gray(0.8N0f8)
    # @test Gray(0.9f0) >= Gray(0.9N0f8) is not true, since 0.9N0f8 = 0.902

    # transparent gray doesn't support comparison
    @test_throws MethodError GrayA(0.8, 0.4) < GrayA(0.9, 0.4)
    @test_throws MethodError GrayA(0.8, 0.4) <= GrayA(0.9, 0.4)
    @test_throws MethodError GrayA(0.9, 0.4) > GrayA(0.8, 0.4)
    @test_throws MethodError GrayA(0.9, 0.4) >= GrayA(0.8, 0.4)
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
