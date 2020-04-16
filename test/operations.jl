using ColorTypes
using ColorTypes.FixedPointNumbers
using Test

@testset "rand" begin
    @testset "rand($T)" for T in (
            Gray{N0f8}, Gray{N2f6}, Gray{N0f16}, Gray{N2f14}, Gray{N0f32}, Gray{N2f30},
            Gray{Float16}, Gray{Float32}, Gray{Float64},
            RGB{N0f8}, RGB{N2f6}, RGB{N0f16}, RGB{N2f14}, RGB{N0f32}, RGB{N2f30},
            RGB{Float16}, RGB{Float32}, RGB{Float64},
            AGray{Float32}, GrayA{Float64},
            RGBA{Float32}, ARGB{N0f16}, XRGB{N0f8}, RGBX{Float64},
            BGR{Float16}, ABGR{N0f32}, BGRA{N2f14},
            Gray, AGray, GrayA,
            RGB, ARGB, RGBA, BGR, ABGR, BGRA, XRGB, RGBX,
            HSV, HSL, Lab, LCHab, YIQ)
        a = rand(T)
        @test all(x->x[2]<=getfield(a,x[1])<=x[3],
                    zip(ColorTypes.colorfields(T),gamutmin(T),gamutmax(T)))
        @test isa(a, T)
        a = rand(T, (3, 5))
        if isconcretetype(T)
            @test isa(a, Array{T,2})
        end
        for el in a
            @test all(x->x[2]<=getfield(el,x[1])<=x[3],
                        zip(ColorTypes.colorfields(T),gamutmin(T),gamutmax(T)))
        end
        @test eltype(a) <: T
        @test size(a) == (3,5)
        ap = a'
        @test ap[1,1] == a[1,1]
    end
    @testset "rand($T)" for T in (Gray24, AGray32)
        a = rand(T)
        b = a.color
        @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
        @test isa(a, T)
        a = rand(T,3,5)
        for el in a
            b = el.color
            @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
        end
        @test eltype(a) <: T
        @test size(a) == (3,5)
    end
    @test_broken rand(RGB24)
    @test_broken rand(ARGB32)
end

@testset "mapc" begin
    @test @inferred(mapc(sqrt, Gray{N0f8}(0.04))) === Gray(sqrt(N0f8(0.04)))
    @test @inferred(mapc(sqrt, AGray{N0f8}(0.04, 0.4))) === AGray(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
    @test @inferred(mapc(sqrt, GrayA{N0f8}(0.04, 0.4))) === GrayA(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
    @test @inferred(mapc(x->2x, RGB{N0f8}(0.04,0.2,0.3))) === RGB(map(x->2*N0f8(x), (0.04,0.2,0.3))...)
    @test @inferred(mapc(sqrt, RGBA{N0f8}(0.04,0.2,0.3,0.7))) === RGBA(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7))...)
    @test @inferred(mapc(x->1.5f0x, RGBA{N0f8}(0.04,0.2,0.3,0.4))) === RGBA(map(x->1.5f0*N0f8(x), (0.04,0.2,0.3,0.4))...)

    @test @inferred(mapc(max, Gray{N0f8}(0.2), Gray{N0f8}(0.3))) === Gray{N0f8}(0.3)
    @test @inferred(mapc(-, AGray{Float32}(0.3), AGray{Float32}(0.2))) === AGray{Float32}(0.3f0-0.2f0,0.0)
    @test @inferred(mapc(min, RGB{N0f8}(0.2,0.8,0.7), RGB{N0f8}(0.5,0.2,0.99))) === RGB{N0f8}(0.2,0.2,0.7)
    @test @inferred(mapc(+, RGBA{N0f8}(0.2,0.8,0.7,0.3), RGBA{Float32}(0.5,0.2,0.99,0.5))) === RGBA(0.5f0+N0f8(0.2),0.2f0+N0f8(0.8),0.99f0+N0f8(0.7),0.5f0+N0f8(0.3))
    @test @inferred(mapc(+, HSVA(0.1,0.8,0.3,0.5), HSVA(0.5,0.5,0.5,0.3))) === HSVA(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.3)
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
