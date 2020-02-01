using ColorTypes, FixedPointNumbers
using Test


@testset "compatibility tests for ARGB32/AGray32" begin
    # cf. PR #146
    @test ARGB32 <: AlphaColor{RGB24, N0f8, 4}
    @test ARGB32 <: AbstractARGB
    @test !(ARGB32 <: AbstractRGBA)
    @test AGray32 <: AlphaColor{Gray24, N0f8, 2}
    @test AGray32 <: AbstractAGray
    @test !(AGray32 <: AbstractGrayA)
    @test supertype(ARGB32) === AlphaColor{RGB24, N0f8, 4} # v0.9 or earlier
    @test supertype(ARGB32) === AbstractARGB{RGB24, N0f8}
    @test supertype(AGray32) === AlphaColor{Gray24, N0f8, 2} # v0.9 or earlier
    @test supertype(AGray32) === AbstractAGray{Gray24, N0f8}
end

### Prevent future commits from unexporting abstract types
@testset "abstract typealiases" begin
    dispatcher2(::Colorant) = error("Colorant")
    dispatcher2(::AbstractGray) = :AbstractGray
    dispatcher2(::Color3)       = :Color3
    dispatcher2(::TransparentGray) = :TransparentGray
    dispatcher2(::Transparent3)    = :Transparent3
    dispatcher2(::TransparentRGB)  = :TransparentRGB

    @test dispatcher2(Gray(0.2))   == :AbstractGray
    @test dispatcher2(Gray24(0.2)) == :AbstractGray
    @test dispatcher2(RGB(1.0,1.0,1.0)) == :Color3
    @test dispatcher2(HSV(100,0.6,0.4)) == :Color3
    @test dispatcher2(GrayA(0.2,0.5))   == :TransparentGray
    @test dispatcher2(AGray(0.2,0.5))   == :TransparentGray
    @test dispatcher2(AGray32(0.2,0.5)) == :TransparentGray
    @test dispatcher2(HSVA(100,0.6,0.4,0.5)) == :Transparent3
    @test dispatcher2(AHSV(100,0.6,0.4,0.5)) == :Transparent3
    @test dispatcher2(RGBA(1.0,1.0,1.0,0.5))   == :TransparentRGB
    @test dispatcher2(ARGB(1.0,1.0,1.0,0.5))   == :TransparentRGB
    @test dispatcher2(ARGB32(0.5,1.0,1.0,1.0)) == :TransparentRGB

    dispatcher3(::TransparentGray) = error("TransparentGray")
    dispatcher3(::Transparent3)    = error("Transparent3")
    dispatcher3(::TransparentRGB)  = error("TransparentRGB")
    dispatcher3(::AbstractAGray) = :AbstractAGray
    dispatcher3(::AbstractGrayA) = :AbstractGrayA
    dispatcher3(::AbstractARGB) = :AbstractARGB
    dispatcher3(::AbstractRGBA) = :AbstractRGBA

    @test dispatcher3(GrayA(0.2,0.5))   == :AbstractGrayA
    @test dispatcher3(AGray(0.2,0.5))   == :AbstractAGray
    @test dispatcher3(AGray32(0.2,0.5)) == :AbstractAGray
    @test dispatcher3(RGBA(1.0,1.0,1.0,0.5))   == :AbstractRGBA
    @test dispatcher3(ARGB(1.0,1.0,1.0,0.5))   == :AbstractARGB
    @test dispatcher3(ARGB32(0.5,1.0,1.0,1.0)) == :AbstractARGB

    normeddispatcher(::Colorant) = false
    normeddispatcher(::ColorantNormed) = true
    @test normeddispatcher(RGB(1.0,1.0,1.0)) == false
    @test normeddispatcher(Gray{Bool}(1)) == false
    @test normeddispatcher(RGB{N0f8}(1.0,1.0,1.0)) == true
    @test normeddispatcher(ARGB32(1.0,1.0,1.0)) == true
end

@testset "colorfields" begin
    @test ColorTypes.colorfields(RGB) == (:r, :g, :b)
    @test ColorTypes.colorfields(RGBA) == (:r, :g, :b, :alpha)
    @test ColorTypes.colorfields(ARGB) == (:r, :g, :b, :alpha)
    @test ColorTypes.colorfields(RGB{N0f8}) == (:r, :g, :b)
    @test ColorTypes.colorfields(RGBA{Float32}) == (:r, :g, :b, :alpha)
    @test ColorTypes.colorfields(ARGB{Float64}) == (:r, :g, :b, :alpha)
    @test ColorTypes.colorfields(RGB24) == (:color,)
    @test ColorTypes.colorfields(ARGB32) == (:color, :alpha)

    @test ColorTypes.colorfields(BGR) == (:r, :g, :b)
    @test ColorTypes.colorfields(XRGB) == (:r, :g, :b)
    @test ColorTypes.colorfields(RGBX) == (:r, :g, :b)

    @test ColorTypes.colorfields(Gray) == (:val,)
    @test ColorTypes.colorfields(GrayA) == (:val, :alpha)
    @test ColorTypes.colorfields(AGray) == (:val, :alpha)
    @test ColorTypes.colorfields(Gray24) == (:color,)
    @test ColorTypes.colorfields(AGray32) == (:color, :alpha)

    @test ColorTypes.colorfields(HSV) == (:h, :s, :v)
    @test ColorTypes.colorfields(HSVA) == (:h, :s, :v, :alpha)
    @test ColorTypes.colorfields(AHSV) == (:h, :s, :v, :alpha)

    @test_throws ArgumentError ColorTypes.colorfields(AbstractRGB)
    @test_throws MethodError ColorTypes.colorfields(N0f8)

    # for instances
    @test ColorTypes.colorfields(RGB{N0f8}(1,0,0)) == (:r, :g, :b)
    @test ColorTypes.colorfields(ARGB(1.0,0.8,0.6,0.4)) == (:r, :g, :b, :alpha)
    @test ColorTypes.colorfields(RGBA{Float32}(1.0,0.8,0.6,0.4)) == (:r, :g, :b, :alpha)
    @test_throws MethodError ColorTypes.colorfields(1N0f8)
end

@testset "coloralpha for types" begin
    @test @inferred(coloralpha(RGB)) === RGBA
    @test @inferred(coloralpha(RGBA)) === RGBA
    @test @inferred(coloralpha(ARGB)) === RGBA
    @test @inferred(coloralpha(RGB{N0f8})) === RGBA
    @test @inferred(coloralpha(RGBA{Float32})) === RGBA
    @test @inferred(coloralpha(ARGB{Float64})) === RGBA
    @test_throws MethodError coloralpha(RGB24)
    @test_throws MethodError coloralpha(ARGB32)

    @test @inferred(coloralpha(BGR)) === BGRA
    @test @inferred(coloralpha(BGR{N0f8})) === BGRA
    @test @inferred(coloralpha(XRGB)) === RGBA
    @test @inferred(coloralpha(RGBX)) === RGBA

    @test @inferred(coloralpha(Gray)) === GrayA
    @test @inferred(coloralpha(GrayA)) === GrayA
    @test @inferred(coloralpha(AGray)) === GrayA
    @test @inferred(coloralpha(Gray{N0f8})) === GrayA
    @test @inferred(coloralpha(GrayA{Float32})) === GrayA
    @test @inferred(coloralpha(AGray{Float64})) === GrayA
    @test_throws MethodError coloralpha(Gray24)
    @test_throws MethodError coloralpha(AGray32)

    @test @inferred(coloralpha(HSV)) === HSVA
    @test @inferred(coloralpha(HSVA)) === HSVA
    @test @inferred(coloralpha(AHSV)) === HSVA
    @test @inferred(coloralpha(HSV{Float16})) === HSVA
    @test @inferred(coloralpha(HSVA{Float32})) === HSVA
    @test @inferred(coloralpha(AHSV{Float64})) === HSVA

    @test_throws MethodError coloralpha(AbstractRGB)
    @test_throws MethodError coloralpha(N0f8)
end

@testset "alphacolor for types" begin
    @test @inferred(alphacolor(RGB)) === ARGB
    @test @inferred(alphacolor(RGBA)) === ARGB
    @test @inferred(alphacolor(ARGB)) === ARGB
    @test @inferred(alphacolor(RGB{N0f8})) === ARGB
    @test @inferred(alphacolor(RGBA{Float32})) === ARGB
    @test @inferred(alphacolor(ARGB{Float64})) === ARGB
    @test @inferred(alphacolor(RGB24)) === ARGB32
    @test @inferred(alphacolor(ARGB32)) === ARGB32

    @test @inferred(alphacolor(BGR)) === ABGR
    @test @inferred(alphacolor(BGR{N0f8})) === ABGR
    @test @inferred(alphacolor(XRGB)) === ARGB
    @test @inferred(alphacolor(RGBX)) === ARGB

    @test @inferred(alphacolor(Gray)) === AGray
    @test @inferred(alphacolor(GrayA)) === AGray
    @test @inferred(alphacolor(AGray)) === AGray
    @test @inferred(alphacolor(Gray{N0f8})) === AGray
    @test @inferred(alphacolor(GrayA{Float32})) === AGray
    @test @inferred(alphacolor(AGray{Float64})) === AGray
    @test @inferred(alphacolor(Gray24)) === AGray32
    @test @inferred(alphacolor(AGray32)) === AGray32

    @test @inferred(alphacolor(HSV)) === AHSV
    @test @inferred(alphacolor(HSVA)) === AHSV
    @test @inferred(alphacolor(AHSV)) === AHSV
    @test @inferred(alphacolor(HSV{Float16})) === AHSV
    @test @inferred(alphacolor(HSVA{Float32})) === AHSV
    @test @inferred(alphacolor(AHSV{Float64})) === AHSV

    @test_throws MethodError alphacolor(AbstractRGB)
    @test_throws MethodError alphacolor(N0f8)
end
