using ColorTypes
using ColorTypes.FixedPointNumbers
using ColorTypes.Random
using Test

@isdefined(CustomTypes) || include("customtypes.jl")
using .CustomTypes

@testset "iterators" begin
    @testset "ComponentIterator" begin
        argb_comps = ColorTypes.comps(ARGB(1.0f0, 0.5f0, 0.0f0))
        @test Iterators.IteratorSize(typeof(argb_comps)) === Iterators.HasLength()
        @test Iterators.IteratorEltype(typeof(argb_comps)) === Iterators.HasEltype()
        @test length(argb_comps) == 4
        @test eltype(typeof(argb_comps)) === Float32
        @test axes(argb_comps) === (Base.OneTo(4),)
        @test ndims(typeof(argb_comps)) == 1
        a = []
        for v in argb_comps
            push!(a, v)
        end
        @test all(a .=== (1.0f0, 0.5f0, 0.0f0, 1.0f0))
        @test argb_comps[3] === 0.0f0
        @test_throws BoundsError argb_comps[5]
        @test_throws MethodError argb_comps[4] = 0.0f0 # read-only
        @test argb_comps[2:2:4] === (0.5f0, 1.0f0)
        @test argb_comps[:] === argb_comps
        @test firstindex(argb_comps) == 1
        @test lastindex(argb_comps) == 4
        @test Base.BroadcastStyle(typeof(argb_comps)) === Base.Broadcast.Style{Tuple}()
        @test argb_comps .* 0.5 === (0.5, 0.25, 0.0, 0.5)
        @test argb_comps .+ (1:4) == Float32[2.0f0, 2.5f0, 3.0f0, 5.0f0]
        @test argb_comps ./ (1, 2, 3, 4) === (1.0f0, 0.25f0, 0.0f0, 0.25f0)
    end
end

@testset "comparisons" begin
    Cp3 = ColorTypes.parametric3
    for C in unique(vcat(Cp3, coloralpha.(Cp3), alphacolor.(Cp3)))
        @test C{Float64}(1,0,0) == C{Float32}(1,0,0)
        @test C{Float32}(1,0,0) != C{Float32}(1,0,0.1)
        @test isequal(C{Float64}(1,0,0), C{Float32}(1,0,0))
        @test !isequal(C{Float32}(1,0,0), C{Float32}(1,0,0.1))
    end

    for (a, b) in ((Gray(1.0), Gray(1)),
                   (GrayA(0.8, 0.6), AGray(0.8, 0.6)),
                   (RGB(1, 0.5, 0), BGR(1, 0.5, 0)),
                   (RGBA(1, 0.5, 0, 0.8), ABGR(1, 0.5, 0, 0.8)),
                   (Gray(0.8N0f8), Gray24(0.8)))
        local a, b
        @test a !== b
        @test a == b
        @test isequal(a, b)
        @test hash(a) == hash(b)
    end
    for (a, b) in ((RGB(1, 0.5, 0), RGBA(1, 0.5, 0, 0.9)),
                   (RGB(0.5, 0.5, 0.5), Gray(0.5)),
                   (HSV(0, 0, 0.5), HSV(100, 0, 0.5)), # grays
                   (Lab(70, 0, 60), LCHab(70, 60, 90)),
                   (Oklab(0.7, 0, 0.2), Oklch(0.7, 0.2, 90)))
        local a, b
        @test a != b
        @test !isequal(a, b)
        @test hash(a) != hash(b)
    end
    for (a, b) in ((RGB(1.0, 0.5, NaN), RGB(1.0, 0.5, NaN)),
                   (Gray(NaN32), Gray(NaN)),
                   (Gray(NaN), NaN))
        @test a != b
        @test b != a
        @test isequal(a, b)
        @test isequal(b, a)
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

    @test !isapprox(Gray(1), RGB(1, 1, 1))

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
    @test Gray(0.8) <      0.9
    @test      0.8  < Gray(0.9)
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

    @test (Gray(0.3) < Gray(NaN)) == (0.3 < NaN)
    @test (Gray(NaN) < Gray(0.3)) == (NaN < 0.3)
    @test isless(Gray(0.3), Gray(NaN)) == isless(0.3, NaN)
    @test isless(Gray(NaN), Gray(0.3)) == isless(NaN, 0.3)
    @test isless(Gray(0.3), NaN) == isless(0.3, NaN)
    @test isless(Gray(NaN), 0.3) == isless(NaN, 0.3)
    @test isless(0.3, Gray(NaN)) == isless(0.3, NaN)
    @test isless(NaN, Gray(0.3)) == isless(NaN, 0.3)

    # transparent gray doesn't support comparison
    @test_throws MethodError GrayA(0.8, 0.4) < GrayA(0.9, 0.4)
    @test_throws MethodError GrayA(0.8, 0.4) <= GrayA(0.9, 0.4)
    @test_throws MethodError GrayA(0.9, 0.4) > GrayA(0.8, 0.4)
    @test_throws MethodError GrayA(0.9, 0.4) >= GrayA(0.8, 0.4)

    # 1-component color but not a gray
    @test_throws MethodError Cyanotype{Float32}(0.8) < Cyanotype{Float32}(0.9)
    @test_throws MethodError isless(Cyanotype{Float32}(0.8), Cyanotype{Float32}(0.9))
    @test_throws MethodError Cyanotype{Float64}(0.8) < Gray(0.9)
    @test_throws MethodError Cyanotype{Float64}(0.8) < 0.9
end

@testset "rand" begin
    function all_in_range(c::C) where {C}
        all(((f, gmin, gmax),) -> gmin <= getfield(c, f) <= gmax,
            zip(ColorTypes.colorfields(C), gamutmin(C), gamutmax(C)))
    end
    eltypes = (N0f8, N2f6, N0f16, N2f14, N0f32, N2f30, Q3f12,
               Float16, Float32, Float64)
    @testset "rand($C)" for C in (
            Gray{Bool}, # issue #275
            (Gray{T} for T in eltypes)...,
            (RGB{T} for T in eltypes)...,
            AGray{Float32}, GrayA{Float64},
            ARGB{Float32}, RGBA{N0f16}, XRGB{N0f8}, RGBX{Float64},
            BGR{Float16}, ABGR{N0f32}, BGRA{N2f14},
            HSV{Float32}, HSL{Float64}, ALab{Float32}, LCHabA{Float16},
            AOklab{Float32}, Oklch{Float16}, Gray, AGray, GrayA,
            unique(ColorTypes.parametric3)...,
            AHSV, HSLA)
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
    @testset "rand($C)" for C in (Gray24, AGray32, RGB24, ARGB32)
        c = rand(C)
        @test c isa C
        a = rand(C, 3, 5)
        @test eltype(a) === C
        @test size(a) == (3, 5)
        C in (RGB24, ARGB32) && continue
        b = c.color
        @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
        for el in a
            b = el.color
            @test b&0xff == (b>>8)&0xff == (b>>16)&0xff
        end
    end
    @test rand(MersenneTwister(), RGB{N0f8}) isa RGB{N0f8}
    @test rand(MersenneTwister(), ARGB32, 3, 2) isa Matrix{ARGB32}
    @test rand!(Gray{Float32}[0.0, 0.1]) isa Vector{Gray{Float32}}
    a = rand!(Array{RGB}(undef, 3, 5))
    @test a isa Matrix{RGB}
    @test typeof(a[1,1]) === RGB{Float64}
    # issue #125
    @test all_in_range(LCHab(50, 10, 359))
    @test all_in_range(YIQ(0.5, 0.59, 0.0))
    @test !all_in_range(YIQ(0.5, 0.0, -0.53))
end

@testset "mapc" begin
    @test @inferred(mapc(sqrt, Gray{N0f8}(0.04))) === Gray(sqrt(N0f8(0.04)))
    @test @inferred(mapc(sqrt, AGray{N0f8}(0.04, 0.4))) === AGray(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
    @test @inferred(mapc(sqrt, GrayA{N0f8}(0.04, 0.4))) === GrayA(sqrt(N0f8(0.04)), sqrt(N0f8(0.4)))
    @test @inferred(mapc(x->2x, RGB{N0f8}(0.04,0.2,0.3))) === RGB(map(x->2*N0f8(x), (0.04,0.2,0.3))...)
    @test @inferred(mapc(sqrt, RGBA{N0f8}(0.04,0.2,0.3,0.7))) === RGBA(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7))...)
    @test @inferred(mapc(x->1.5f0x, RGBA{N0f8}(0.04,0.2,0.3,0.4))) === RGBA(map(x->1.5f0*N0f8(x), (0.04,0.2,0.3,0.4))...)
    @test @inferred(mapc(sqrt, ACMYK{N0f8}(0.04,0.2,0.3,0.7,0.1))) === ACMYK(map(x->sqrt(N0f8(x)), (0.04,0.2,0.3,0.7,0.1))...)

    @test @inferred(mapc(max, Gray{N0f8}(0.2), Gray{N0f8}(0.3))) === Gray{N0f8}(0.3)
    @test @inferred(mapc(-, AGray{Float32}(0.3), AGray{Float32}(0.2))) === AGray{Float32}(0.3f0-0.2f0,0.0)
    @test @inferred(mapc(min, RGB{N0f8}(0.2,0.8,0.7), RGB{N0f8}(0.5,0.2,0.99))) === RGB{N0f8}(0.2,0.2,0.7)
    @test @inferred(mapc(+, RGBA{N0f8}(0.2,0.8,0.7,0.3), RGBA{Float32}(0.5,0.2,0.99,0.5))) === RGBA(0.5f0+N0f8(0.2),0.2f0+N0f8(0.8),0.99f0+N0f8(0.7),0.5f0+N0f8(0.3))
    @test @inferred(mapc(+, HSVA(0.1,0.8,0.3,0.5), HSVA(0.5,0.5,0.5,0.3))) === HSVA(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.3)
    @test @inferred(mapc(+, ACMYK(0.1,0.8,0.3,0.5,0.2), ACMYK(0.5,0.5,0.5,0.5,0.5))) === ACMYK(0.1+0.5,0.8+0.5,0.3+0.5,0.5+0.5,0.2+0.5)

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
    @test @inferred(reducec(+, 0.0, ACMYK(0.3, 0.8, 0.5, 0.7, 0.2))) === (((0.3 + 0.8) + 0.5) + 0.7) + 0.2
    @test @inferred(reducec(&, true, Gray(true)))
    @test !(@inferred(reducec(&, false, Gray(true))))
    @test !(@inferred(reducec(&, true, Gray(false))))

    @test @inferred(reducec(+, 0.0, 0.3)) === 0.3
    @test @inferred(reducec(+, 0, 0.3)) === 0.3
    @test @inferred(reducec(&, true, true))
    @test !(@inferred(reducec(&, false, true)))
    @test !(@inferred(reducec(&, true, false)))

    @test @inferred(reducec(+, Gray(0.3), init=0.5)) === 0.5 + 0.3
    @test @inferred(reducec(+, AGray{N0f8}(0.3, 0.8))) === 0.3N0f8 + 0.8N0f8 # overflow
    @test @inferred(reducec(*, RGB(0.3, 0.8, 0.5), init=0.5)) === ((0.5 * 0.3) * 0.8) * 0.5
    @test @inferred(reducec(*, RGBA{N0f8}(0.3, 0.8, 0.5, 0.7))) === ((0.3N0f8 * 0.8N0f8) * 0.5N0f8) * 0.7N0f8

    @test @inferred(reducec(max, 0.3, init=0.5)) === 0.5
    @test @inferred(reducec(min, 0.3)) === 0.3
end

@testset "mapreducec" begin
    @test @inferred(mapreducec(x->x^2, +, 0.0, Gray(0.3))) === 0.3^2
    @test @inferred(mapreducec(x->x^2, +, 1.0, Gray(0.3))) === 1 + 0.3^2
    @test @inferred(mapreducec(x->x^2, +, 0, Gray(0.3))) === 0.3^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, AGray(0.3, 0.8))) === 0.3^2 + 0.8^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, RGB(0.3, 0.8, 0.5))) === (0.3^2 + 0.8^2) + 0.5^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, RGBA(0.3, 0.8, 0.5, 0.7))) === ((0.3^2 + 0.8^2) + 0.5^2) + 0.7^2
    @test @inferred(mapreducec(x->x^2, +, 0.0, ACMYK(0.3, 0.8, 0.5, 0.7, 0.2))) === (((0.3^2 + 0.8^2) + 0.5^2) + 0.7^2) + 0.2^2

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

    @test @inferred(mapreducec(x->x^2, max, Gray(0.3), init=0.01)) === 0.3^2
    @test @inferred(mapreducec(x->x^2, max, AGray{N0f8}(0.3, 0.8))) === N0f8(0.8)^2
    @test @inferred(mapreducec(x->x^2, min, RGB(0.3, 0.8, 0.5), init=0.2)) === 0.3^2
    @test @inferred(mapreducec(x->x^2, min, RGBA{N0f8}(0.3, 0.8, 0.5, 0.7))) === N0f8(0.3)^2

    @test @inferred(mapreducec(x->x^2, +, 0.3, init=0.5)) === 0.5 + 0.3^2
    @test @inferred(mapreducec(x->x^2, *, 0.3)) === 0.3^2
end

@testset "ones/zeros" begin
    for C in (Gray, Gray{N0f8}, GrayA{Float32}, Gray24, AGray32,
              RGB, RGB{N0f8}, RGBA{Float32}, RGB24, ARGB32)
        for f in (ones, zeros)
            mat = @inferred(f(C, 3, 5))
            # note that the return type of `ones(RGB)` is `Array{RGB}`, not `Array{RGB{N0f8}}`
            @test typeof(mat) === Matrix{C}
            @test size(mat) == (3, 5)
            @test mat[2, 3] === (f === ones ? oneunit(C) : zero(C))
        end
    end
    @test_throws ColorTypes.ColorTypeResolutionError ones(HSV{Float32}, 3, 5)
    # Although `XYZ` and `LMS` have the definition of `oneunit`,
    # it is generally not equivalent to `Gray(1)`.
    @test_throws ColorTypes.ColorTypeResolutionError ones(XYZ, 3, 5)
    @test_throws ColorTypes.ColorTypeResolutionError ones(LMS{Float64}, 3, 5)

    @test zeros(HSV{Float32}, 3, 5)[2, 3] === zero(HSV{Float32})
    @test zeros(XYZ, 3, 5)[2, 3] === zero(XYZ)
    @test zeros(LMS{Float64}, 3, 5)[2, 3] === zero(LMS{Float64})
end
