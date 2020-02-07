using ColorTypes, FixedPointNumbers
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
