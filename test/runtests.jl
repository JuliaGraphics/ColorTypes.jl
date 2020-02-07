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

## operations

@test eltype(broadcast(RGB, [BGR(1,0,0)])) == RGB{N0f8}
addred(x1::AbstractRGB, x2::AbstractRGB) = red(x1) + red(x2)
@test addred.([RGB(1,0,0)], RGB(1.0,0,0)) == [2]

@test @inferred(mapc(sqrt, Gray{N0f8}(0.04))) == Gray(sqrt(N0f8(0.04)))
@test @inferred(mapc(sqrt, AGray{N0f8}(0.04, 0.4))) == AGray(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
@test @inferred(mapc(sqrt, GrayA{N0f8}(0.04, 0.4))) == GrayA(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
@test @inferred(mapc(x->2x, RGB{N0f8}(0.04,0.2,0.3))) == RGB(map(x->2*N0f8(x), (0.04,0.2,0.3))...)
@test @inferred(mapc(sqrt, RGBA{N0f8}(0.04,0.2,0.3,0.7))) == RGBA(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7))...)
@test @inferred(mapc(x->1.5f0x, RGBA{N0f8}(0.04,0.2,0.3,0.4))) == RGBA(map(x->1.5f0*N0f8(x), (0.04,0.2,0.3,0.4))...)

@test @inferred(mapc(max, Gray{N0f8}(0.2), Gray{N0f8}(0.3))) == Gray{N0f8}(0.3)
@test @inferred(mapc(-, AGray{Float32}(0.3), AGray{Float32}(0.2))) == AGray{Float32}(0.3f0-0.2f0,0.0)
@test @inferred(mapc(min, RGB{N0f8}(0.2,0.8,0.7), RGB{N0f8}(0.5,0.2,0.99))) == RGB{N0f8}(0.2,0.2,0.7)
@test @inferred(mapc(+, RGBA{N0f8}(0.2,0.8,0.7,0.3), RGBA{Float32}(0.5,0.2,0.99,0.5))) == RGBA(0.5f0+N0f8(0.2),0.2f0+N0f8(0.8),0.99f0+N0f8(0.7),0.5f0+N0f8(0.3))
@test @inferred(mapc(+, HSVA(0.1,0.8,0.3,0.5), HSVA(0.5,0.5,0.5,0.3))) == HSVA(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.3)
@test_throws ArgumentError mapc(min, RGB{N0f8}(0.2,0.8,0.7), BGR{N0f8}(0.5,0.2,0.99))
@test @inferred(mapc(abs, -2)) == 2

@test @inferred(reducec(+, 0.0, Gray(0.3))) === 0.3
@test @inferred(reducec(+, 1.0, Gray(0.3))) === 1.3
@test @inferred(reducec(+, 0, Gray(0.3))) === 0.3
@test @inferred(reducec(+, 0.0, AGray(0.3, 0.8))) === 0.3 + 0.8
@test @inferred(reducec(+, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3 + 0.8) + 0.5
@test @inferred(reducec(+, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3 + 0.8) + 0.5) + 0.7
@test @inferred(reducec(&, true, Gray(true)))
@test !(@inferred(reducec(&, false, Gray(true))))
@test !(@inferred(reducec(&, true, Gray(false))))

@test @inferred(reducec(+, 0.0, 0.3)) === 0.3
@test @inferred(reducec(+, 0, 0.3)) === 0.3
@test @inferred(reducec(&, true, true))
@test !(@inferred(reducec(&, false, true)))
@test !(@inferred(reducec(&, true, false)))

@test @inferred(mapreducec(x->x^2, +, 0.0, Gray(0.3))) === 0.3^2
@test @inferred(mapreducec(x->x^2, +, 1.0, Gray(0.3))) === 1 + 0.3^2
@test @inferred(mapreducec(x->x^2, +, 0, Gray(0.3))) === 0.3^2
@test @inferred(mapreducec(x->x^2, +, 0.0, AGray(0.3, 0.8))) === 0.3^2 + 0.8^2
@test @inferred(mapreducec(x->x^2, +, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3^2 + 0.8^2) + 0.5^2
@test @inferred(mapreducec(x->x^2, +, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3^2 + 0.8^2) + 0.5^2) + 0.7^2
@test !(@inferred(mapreducec(x->!x, &, true, Gray(true))))
@test !(@inferred(mapreducec(x->!x, &, false, Gray(true))))
@test @inferred(mapreducec(x->!x, &, true, Gray(false)))
@test !@inferred(mapreducec(x->!x, &, false, Gray(false)))

@test @inferred(mapreducec(x->x^2, +, 0.0, 0.3)) === 0.3^2
@test @inferred(mapreducec(x->x^2, +, 1.0, 0.3)) === 1 + 0.3^2
@test @inferred(mapreducec(x->x^2, +, 0, 0.3)) === 0.3^2
@test !(@inferred(mapreducec(x->!x, &, true, true)))
@test !(@inferred(mapreducec(x->!x, &, false, true)))
@test @inferred(mapreducec(x->!x, &, true, false))
@test !@inferred(mapreducec(x->!x, &, false, false))

end # ColorTypes
