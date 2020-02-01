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
