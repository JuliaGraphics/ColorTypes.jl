using ColorTypes, FixedPointNumbers
using Test

@testset "ColorTypes" begin

@test isempty(detect_ambiguities(ColorTypes, Base, Core))

@testset "conversions" begin
    include("conversions.jl")
end

@testset "operations" begin
    include("operations.jl")
end

@testset "show" begin
    include("show.jl")
end

@testset "traits" begin
    include("traits.jl")
end

@testset "types" begin
    include("types.jl")
end

@test ColorTypes.to_top(AGray32(.8)) == ColorTypes.Colorant{FixedPointNumbers.Normed{UInt8,8},2}

# This tests the same thing as the last, but in a user-observable way
let a = Array{Gray}(undef, 1)
    a[1] = Gray(0)
    a[1] = 1
    @test a[1] === Gray(1)
end

for C in ColorTypes.parametric3
    @test eltype(C{Float32}) == Float32
    et = (C <: AbstractRGB) ? N0f8 : Float32
    @test color_type(C(1,0,0)) == C{et}
    @test color_type(C) == C
    @test color_type(C{Float32}) == C{Float32}
    @test eltype(C{Float32}(1,0,0)) == Float32
end

@testset "Test some Gray stuff" begin
    c = Gray(0.8)
    ac = convert(AGray, c)
    @test ac === AGray{Float64}(0.8, 1.0)
    ac = AGray(c)
    @test ac === AGray{Float64}(0.8, 1.0)
    ac = AGray{Float64}(c)
    @test ac === AGray{Float64}(0.8, 1.0)
    ca = GrayA{Float64}(ac)
    @test ca === GrayA{Float64}(0.8, 1.0)

    @test color(ac) == Gray(0.8)
end

# Transparency
for C in setdiff(ColorTypes.parametric3, [XRGB,RGBX])
    for A in (alphacolor(C), coloralpha(C))
        @test eltype(A{Float32}) == Float32
        @test color_type(A) == C
        @test color_type(A{Float32}) == C{Float32}
        @test eltype(A(1,0.8,0.6,0.4)) == Float64
        c = A{Float64}(1,0.8,0.6,0.4)
        @test color_type(c) == C{Float64}
        cc = color(c)
        @test cc == C{Float64}(1,0.8,0.6)
        @test A(cc) == A{Float64}(1,0.8,0.6,1)
        @test A(cc, 0.4)  == c
        @test A(cc, 0x01) == A{Float64}(1,0.8,0.6,1)
        @test A{Float32}(cc, 0x01) == A{Float32}(1,0.8,0.6,1)
        @test C(c         ) == C{Float64}(1,0.8,0.6)
        @test C{Float32}(c) == C{Float32}(1,0.8,0.6)
        @test convert(A, cc) == A{Float64}(1,0.8,0.6,1)
        @test A(cc) === A{Float64}(1,0.8,0.6,1)
        @test A{Float64}(cc) === A{Float64}(1,0.8,0.6,1)
        @test convert(A, cc, 0.4)  == c
        @test convert(A, cc, 0x01) == A{Float64}(1,0.8,0.6,1)
        @test convert(A{Float32}, cc, 0x01) == A{Float32}(1,0.8,0.6,1)
        @test convert(C,          c) == C{Float64}(1,0.8,0.6)
        @test convert(C{Float32}, c) == C{Float32}(1,0.8,0.6)
        @test C{Float32}(c) === C{Float32}(1,0.8,0.6)
    end
end
ac = reinterpret(ARGB32, rand(UInt32))
c = convert(RGB24, ac)
@test color(c) == c
@test color(ac) == c

# if the test below fails, please extend the list of types at the call to
# make_alpha in types.jl (this is the price of making that list explicit)
@test Set(ColorTypes.ctypes) ==
Set([DIN99d, DIN99o, DIN99, HSI, HSL, HSV, LCHab, LCHuv,
     LMS, Lab, Luv, XYZ, YCbCr, YIQ, xyY, BGR, RGB, Gray])


@test eltype(broadcast(RGB, [BGR(1,0,0)])) == RGB{N0f8}
addred(x1::AbstractRGB, x2::AbstractRGB) = red(x1) + red(x2)
@test addred.([RGB(1,0,0)], RGB(1.0,0,0)) == [2]

end # ColorTypes
