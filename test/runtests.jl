using ColorTypes
using ColorTypes.FixedPointNumbers
using Test

@test isempty(detect_ambiguities(ColorTypes, Base, Core))

using Documenter
doctest(ColorTypes, manual = false)

# if the test below fails, please extend the list of types at the call to
# make_alpha in types.jl (this is the price of making that list explicit)
@test Set(ColorTypes.ctypes) ==
    Set([DIN99d, DIN99o, DIN99, HSI, HSL, HSV, LCHab, LCHuv,
         LMS, Lab, Luv, XYZ, YCbCr, YIQ, xyY, BGR, RGB, Gray])

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, :register_error_hint)
    @testset "error_hints" begin
        # ColorVectorSpace, if needed, should not be imported before this
        include("error_hints.jl")
    end
end

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


 @testset "misc." begin
     # This tests the same thing as the last, but in a user-observable way
     let a = Array{Gray}(undef, 1)
         a[1] = Gray(0)
         a[1] = 1
         @test a[1] === Gray(1)
     end

     # broadcast
     @test eltype(broadcast(RGB, [BGR(1,0,0)])) === RGB{N0f8}
     addred(x1::AbstractRGB, x2::AbstractRGB) = red(x1) + red(x2)
     @test addred.([RGB(1,0,0)], RGB(1.0,0,0)) == [2.0]
 end


@testset "type-centric" begin
    @testset "$C" for C in ColorTypes.parametric3
        @test eltype(C{Float32}) === Float32
        et = (C <: AbstractRGB) ? N0f8 : Float32
        @test color_type(C(1,0,0)) === C{et}
        @test color_type(C) === C
        @test color_type(C{Float32}) === C{Float32}
        @test eltype(C{Float32}(1,0,0)) === Float32
    end

    for C in setdiff(ColorTypes.parametric3, [XRGB,RGBX])
        @testset "$A" for A in (alphacolor(C), coloralpha(C))
            @test eltype(A{Float32}) === Float32
            @test color_type(A) === C
            @test color_type(A{Float32}) === C{Float32}
            @test eltype(A(1,0.8,0.6,0.4)) === Float64
            c = A{Float64}(1,0.8,0.6,0.4)
            @test color_type(c) === C{Float64}
            cc = color(c)
            @test cc === C{Float64}(1,0.8,0.6)
            @test A(cc) === A{Float64}(1,0.8,0.6,1)
            @test A(cc, 0.4)  === c
            @test A(cc, 0x01) === A{Float64}(1,0.8,0.6,1)
            @test A{Float32}(cc, 0x01) === A{Float32}(1,0.8,0.6,1)
            @test C(c         ) === C{Float64}(1,0.8,0.6)
            @test C{Float32}(c) === C{Float32}(1,0.8,0.6)
            @test convert(A, cc) === A{Float64}(1,0.8,0.6,1)
            @test A(cc) === A{Float64}(1,0.8,0.6,1)
            @test A{Float64}(cc) === A{Float64}(1,0.8,0.6,1)
            @test convert(A, cc, 0.4)  === c
            @test convert(A, cc, 0x01) === A{Float64}(1,0.8,0.6,1)
            @test convert(A{Float32}, cc, 0x01) === A{Float32}(1,0.8,0.6,1)
            @test convert(C,          c) === C{Float64}(1,0.8,0.6)
            @test convert(C{Float32}, c) === C{Float32}(1,0.8,0.6)
            @test C{Float32}(c) === C{Float32}(1,0.8,0.6)
        end
    end
end
