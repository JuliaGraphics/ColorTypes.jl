using ColorTypes
using ColorTypes.FixedPointNumbers
using ColorTypes.Random
using Test

# dummy type
struct C5{T} <: Color{T,5}
    c1::T; c2::T; c3::T; c4::T; c5::T
end

@testset "rand" begin
    function all_in_range(c::C) where {C}
        all(((f, gmin, gmax),) -> gmin <= getfield(c, f) <= gmax,
            zip(ColorTypes.colorfields(C), gamutmin(C), gamutmax(C)))
    end
    eltypes = (N0f8, N2f6, N0f16, N2f14, N0f32, N2f30, Float16, Float32, Float64)
    @testset "rand($C)" for C in (
            (Gray{T} for T in eltypes)...,
            (RGB{T} for T in eltypes)...,
            AGray{Float32}, GrayA{Float64},
            ARGB{Float32}, RGBA{N0f16}, XRGB{N0f8}, RGBX{Float64},
            BGR{Float16}, ABGR{N0f32}, BGRA{N2f14},
            HSV{Float32}, HSL{Float64}, ALab{Float32}, LCHabA{Float16},
            Gray, AGray, GrayA,
            RGB, ARGB, RGBA, BGR, ABGR, BGRA, XRGB, RGBX,
            HSV, HSL, Lab, LCHab, YIQ,
            AHSV, HSLA)
        if C <: Transparent3 && !(C <: TransparentRGB)
            @test_broken rand(C)
            continue
        end
        CC = isconcretetype(C) ? C : C{Float64}
        c = rand(C)
        @test c isa CC
        @test all_in_range(c)
        a = rand(C, (3, 5))
        @test a isa Array{CC,2}
        @test eltype(a) === CC
        @test size(a) == (3, 5)
        @test all(all_in_range, a)
        ap = a'
        @test ap[1, 1] == a[1, 1]
    end
    @testset "rand($C)" for C in (Gray24, AGray32)
        c = rand(C)
        b = c.color
        @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
        @test c isa C
        a = rand(C, 3, 5)
        for el in a
            b = el.color
            @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
        end
        @test eltype(a) === C
        @test size(a) == (3, 5)
    end
    @test_broken rand(RGB24)
    @test_broken rand(ARGB32)
    @test_broken rand(MersenneTwister(), RGB{N0f8})
    @test_broken rand!(Gray{Float32}[0.0, 0.1])
    @test_broken all(all_in_range, rand(ARGB{Q3f12}, 10, 10))
    @test_broken all_in_range(LCHab(50, 10, 359))
    @test_broken all_in_range(YIQ(0.5, 0.59, 0.0))
    @test_broken !all_in_range(YIQ(0.5, 0.0, -0.53))
end

@testset "mapc" begin
    @test @inferred(mapc(sqrt, Gray{N0f8}(0.04))) === Gray(sqrt(N0f8(0.04)))
    @test @inferred(mapc(sqrt, AGray{N0f8}(0.04, 0.4))) === AGray(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
    @test @inferred(mapc(sqrt, GrayA{N0f8}(0.04, 0.4))) === GrayA(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
    @test @inferred(mapc(x->2x, RGB{N0f8}(0.04,0.2,0.3))) === RGB(map(x->2*N0f8(x), (0.04,0.2,0.3))...)
    @test @inferred(mapc(sqrt, RGBA{N0f8}(0.04,0.2,0.3,0.7))) === RGBA(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7))...)
    @test @inferred(mapc(x->1.5f0x, RGBA{N0f8}(0.04,0.2,0.3,0.4))) === RGBA(map(x->1.5f0*N0f8(x), (0.04,0.2,0.3,0.4))...)
    @test @inferred(mapc(sqrt, C5{N0f8}(0.04,0.2,0.3,0.7,0.1))) === C5(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7,0.1))...)

    @test @inferred(mapc(max, Gray{N0f8}(0.2), Gray{N0f8}(0.3))) === Gray{N0f8}(0.3)
    @test @inferred(mapc(-, AGray{Float32}(0.3), AGray{Float32}(0.2))) === AGray{Float32}(0.3f0-0.2f0,0.0)
    @test @inferred(mapc(min, RGB{N0f8}(0.2,0.8,0.7), RGB{N0f8}(0.5,0.2,0.99))) === RGB{N0f8}(0.2,0.2,0.7)
    @test @inferred(mapc(+, RGBA{N0f8}(0.2,0.8,0.7,0.3), RGBA{Float32}(0.5,0.2,0.99,0.5))) === RGBA(0.5f0+N0f8(0.2),0.2f0+N0f8(0.8),0.99f0+N0f8(0.7),0.5f0+N0f8(0.3))
    @test @inferred(mapc(+, HSVA(0.1,0.8,0.3,0.5), HSVA(0.5,0.5,0.5,0.3))) === HSVA(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.3)
    @test @inferred(mapc(+, C5(0.1,0.8,0.3,0.5,0.2), C5(0.5,0.5,0.5,0.5,0.5))) === C5(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.5,0.2+0.5)

    @test_throws ArgumentError mapc(min, RGB{N0f8}(0.2,0.8,0.7), BGR{N0f8}(0.5,0.2,0.99))
    @test @inferred(mapc(abs, -2)) === 2
end

@testset "reducec" begin
    @test @inferred(reducec(+, 0.0, Gray(0.3))) === 0.3
    @test @inferred(reducec(+, 1.0, Gray(0.3))) === 1.3
    @test @inferred(reducec(+, 0, Gray(0.3))) === 0.3
    @test @inferred(reducec(+, 0.0, AGray(0.3, 0.8))) === 0.3 + 0.8
    @test @inferred(reducec(+, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3 + 0.8) + 0.5
    @test @inferred(reducec(+, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3 + 0.8) + 0.5) + 0.7
    @test @inferred(reducec(+, 0.0, C5(0.3, 0.8, 0.5, 0.7, 0.2))) === (((0.3 + 0.8) + 0.5) + 0.7) + 0.2
    @test @inferred(reducec(&, true, Gray(true)))
    @test !(@inferred(reducec(&, false, Gray(true))))
    @test !(@inferred(reducec(&, true, Gray(false))))

    @test @inferred(reducec(+, 0.0, 0.3)) === 0.3
    @test @inferred(reducec(+, 0, 0.3)) === 0.3
    @test @inferred(reducec(&, true, true))
    @test !(@inferred(reducec(&, false, true)))
    @test !(@inferred(reducec(&, true, false)))
end

@testset "mapreducec" begin
    @test @inferred(mapreducec(x->x^2, +, 0.0, Gray(0.3))) === 0.3^2
    @test @inferred(mapreducec(x->x^2, +, 1.0, Gray(0.3))) === 1 + 0.3^2
    @test @inferred(mapreducec(x->x^2, +, 0, Gray(0.3))) === 0.3^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, AGray(0.3, 0.8))) === 0.3^2 + 0.8^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3^2 + 0.8^2) + 0.5^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3^2 + 0.8^2) + 0.5^2) + 0.7^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, C5(0.3, 0.8, 0.5, 0.7, 0.2))) === (((0.3^2 + 0.8^2) + 0.5^2) + 0.7^2) + 0.2^2

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
end
