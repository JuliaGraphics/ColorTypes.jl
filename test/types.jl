using ColorTypes
using ColorTypes.FixedPointNumbers
using Test

@isdefined(CustomTypes) || include("customtypes.jl")
using .CustomTypes

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

@testset "rgb constructors" begin
    Crgb = filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
    @testset "$C constructor" for C in Crgb
        for val1 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
            for val2 in (0.6, 0.6f0, N0f8(0.6), N4f12(0.6), N0f16(0.6))
                c = C(val1,val2,val1)
                @test isa(c, C)
                @test C{N0f8}(val1,val2,val1) === C(0.2N0f8,0.6N0f8,0.2N0f8)
                @test C{N0f16}(val1,val2,val1) === C(0.2N0f16,0.6N0f16,0.2N0f16)
            end
            # 1-arg constructor
            @test C(val1) === C{typeof(val1)}(0.2,0.2,0.2)
            @test C{N0f8}(val1) === C{N0f8}(0.2,0.2,0.2)
        end
        # 0-arg constructor
        @test C() === C{N0f8}(0, 0, 0)

        @test_throws ArgumentError C(2,1,0) # integers

        for val in (1.2, 1.2f0, N4f12(1.2), -0.2)
            @test_throws ArgumentError C{N0f8}(val,val,val)
            @test_throws ArgumentError C{N0f16}(val,val,val)
            @test isa(C(val,val,val), C)
        end
    end
end

@testset "transparent rgb constructors" begin
    Crgb = filter(T -> T <: AbstractRGB, ColorTypes.parametric3)
    # all(T -> alphacolor(T) === ARGB, (RGB, XRGB, RGBX))
    Ctransparent = unique(vcat(coloralpha.(Crgb), alphacolor.(Crgb)))
    @testset "$C constructor" for C in Ctransparent
        C0 = color_type(C)

        for val1 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
            for val2 in (0.6, 0.6f0, N0f8(0.6), N4f12(0.6), N0f16(0.6))
                c0 = C0(val1,val2,val1)
                et = eltype(c0)
                @test isa(C(val1,val2,val1), C)
                @test isa(C(val1,val2,val1,0.8), C)
                @test C(c0) === C(val1,val2,val1,convert(et, 1))
                @test C(c0) === C{et}(val1,val2,val1,1)
                @test C(c0,0.8) === C(val1,val2,val1,convert(et, 0.8))
                @test C{N0f8}(val1,val2,val1) === C(0.2N0f8,0.6N0f8,0.2N0f8,1N0f8)
                @test C{N0f16}(val1,val2,val1,0.8) === C(0.2N0f16,0.6N0f16,0.2N0f16,0.8N0f16)
            end
            # 1-arg constructor
            @test_broken C(val1) === C{typeof(val1)}(0.2,0.2,0.2,1)
            @test_broken C{N0f8}(val1) === C{N0f8}(0.2,0.2,0.2,1)
        end

        @test_throws ArgumentError C(2,1,0) # integers
        @test_throws ArgumentError C(2,1,0,1) # integers

        for val in (1.2, 1.2f0, N4f12(1.2), -0.2)
            c0 = C0(val,val,val)
            @test_throws ArgumentError C{N0f8}(val,val,val)
            @test_throws ArgumentError C{N0f16}(val,val,val,0.8)
            @test_throws ArgumentError C{N0f8}(c0)
            @test_throws ArgumentError C{N0f16}(c0,0.8)
            @test isa(C(val,val,val), C)
            @test isa(C(val,val,val,0.8), C)
            @test isa(C(val,val,val,val), C) # no exception thrown
        end
    end
end

@testset "RGB24/ARGB32 constructors" begin
    for val1 in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2))
        for val2 in (0.6, 0.6f0, N0f8(0.6), N4f12(0.6), N0f16(0.6))
            @test RGB24(val1,val2,val1) === RGB24(0.2,0.6,0.2)
            @test ARGB32(val1,val2,val1) === ARGB32(0.2,0.6,0.2,1)
            @test ARGB32(val1,val2,val1,0.8) === ARGB32(0.2,0.6,0.2,0.8)
            c0 = RGB24(val1,val2,val1)
            @test ARGB32(c0) === ARGB32(val1,val2,val1,1)
            @test ARGB32(c0,0.8) === ARGB32(val1,val2,val1,0.8)
        end
        # 1-arg constructor
        @test RGB24(val1) === RGB24(0.2,0.2,0.2)
        @test ARGB32(val1) === ARGB32(0.2,0.2,0.2,1)
    end
    # 0-arg constructor
    @test RGB24() === RGB24(0, 0, 0)
    @test ARGB32() === ARGB32(0, 0, 0, 1)

    @test_throws ArgumentError RGB24(2,1,0) # integers
    @test_throws ArgumentError ARGB32(2,1,0) # integers
    @test_throws ArgumentError ARGB32(2,1,0,1) # integers

    # https://github.com/JuliaGraphics/ColorTypes.jl/pull/183#issuecomment-616958191
    @test_broken ARGB32(-0.00196, 0.0, 1.00196) === ARGB32(0, 0, 1)

    for val in (1.2, 1.2f0, N4f12(1.2), -0.2)
        @test_throws ArgumentError RGB24(val,val,val)
        @test_throws ArgumentError ARGB32(val,val,val)
        @test_throws ArgumentError ARGB32(val,val,val,0.8)
        c0 = RGB(val,val,val)
        @test_throws ArgumentError ARGB32(c0)
        @test_throws ArgumentError ARGB32(c0,0.8)
    end
end

@testset "RGB construction with integer arguments" begin
    ret = @test_throws ArgumentError RGB(255, 17, 48)
    @test occursin("255, 17, 48", ret.value.msg)
    @test occursin("0-255", ret.value.msg)
    ret = @test_throws ArgumentError RGB(256, 17, 48)
    @test occursin("256, 17, 48", ret.value.msg)
    @test !occursin("0-255", ret.value.msg)
    # for RGB24 and ARGB32 with UInt32 arguments, see "bit pattern ambiguities"
    # in "test/conversion.jl"
end

@testset "color construction from grayscale" begin
    @test RGB(Gray(0.2), 0.3, 0.4) === RGB(0.2, 0.3, 0.4)
    @test RGB(0.2, Gray(0.3), 0.4) === RGB(0.2, 0.3, 0.4)
    @test RGB(0.2, 0.3, Gray(0.4)) === RGB(0.2, 0.3, 0.4)
    @test RGB(Gray(0.2), Gray(0.3), Gray(0.4)) === RGB(0.2, 0.3, 0.4)
    @test RGB24(Gray(0.2), 0.3, 0.4) === RGB24(0.2, 0.3, 0.4)
    @test ARGB32(0.2, 0.3, 0.4, Gray(0.5)) === ARGB32(0.2, 0.3, 0.4, 0.5)
    @test RGB(0.2, Gray24(0.3), 0.4) === RGB(0.2, 0.3N0f8, 0.4)
    @test_throws MethodError HSV(0.2, 0.3, Gray(0.4))
    @test_throws MethodError ALab(0.2, 0.3, 0.4, Gray24(0.5))
end

@testset "gray constructors" begin
    for val in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2),
                Gray{N0f8}(0.2), Gray{N4f12}(0.2), Gray24(0.2))
        T = val isa AbstractGray ? eltype(val) : typeof(val)
        @test Gray(val) === Gray{T}(0.2)
        @test Gray{N0f8}(val) === Gray{N0f8}(0.2)
        @test Gray{N0f16}(val) === Gray{N0f16}(0.2)
        @test Gray24(val) === Gray24(0.2)
    end
    for val in (1.2, 1.2f0, N4f12(1.2), Gray{N4f12}(1.2), 2, -0.2)
        T = val isa AbstractGray ? eltype(val) : typeof(val)
        !isa(val, Int) && @test Gray(val) === Gray{T}(val)
        @test_throws ArgumentError Gray{N0f8}(val)
        @test_throws ArgumentError Gray{N0f16}(val)
        @test_throws ArgumentError Gray24(val)
    end
    # 0-arg constructor
    @test Gray() === Gray{N0f8}(0)
    @test Gray24() === Gray24(0)

    @test Gray(Gray()) === Gray()  # no StackOverflowError
    @test Gray(1) === Gray{N0f8}(1)
    @test Gray(true) === Gray{Bool}(1)
    # construction from a "transparent" gray
    @test Gray(GrayA(0.2,0.8)) === Gray{Float64}(0.2)
    @test Gray(AGray32(0.2,0.8)) === Gray{N0f8}(0.2)
    @test Gray24(AGray(0.2,0.8)) === Gray24(0.2)
    @test Gray24(AGray32(0.2,0.8)) === Gray24(0.2)

    @test eltype(broadcast(Gray, rand(5))) == Gray{Float64}
    @test eltype(broadcast(Gray, rand(Float32,5))) == Gray{Float32}
end

@testset "transparent gray constructors" begin
    for val in (0.2, 0.2f0, N0f8(0.2), N4f12(0.2), N0f16(0.2),
                Gray{N0f8}(0.2), Gray{N4f12}(0.2), Gray24(0.2))
        T = val isa AbstractGray ? eltype(val) : typeof(val)
        @test @inferred(AGray(val)) === AGray{T}(0.2, 1)
        @test AGray{N0f8}(val) === AGray{N0f8}(0.2, 1)
        @test GrayA{N0f16}(val) === GrayA{N0f16}(0.2, 1)
        @test AGray32(val) === AGray32(0.2, 1)
        @test AGray32(val, 0.8) === AGray32(0.2, 0.8)
        if val isa FixedPoint
            @test AGray(val, 1) === AGray{Float32}(0.2, 1) # inconsistent eltype
            @test_broken @inferred(AGray(val, 1)) === AGray{T}(0.2, 1)
            @test_broken @inferred(GrayA(val, 0)) === GrayA{T}(0.2, 0)
        else
            @test @inferred(AGray(val, 1)) === AGray{T}(0.2, 1)
            @test @inferred(GrayA(val, 0)) === GrayA{T}(0.2, 0)
        end
        Ta = val isa AbstractGray ? T : Float64
        if val isa Gray24
            @test_broken @inferred(AGray(val, 0.8)) === AGray{Ta}(val, 0.8)
            @test_broken @inferred(GrayA(val, 0.8)) === GrayA{Ta}(val, 0.8)
        else
            @test @inferred(AGray(val, 0.8)) === AGray{Ta}(val, 0.8)
            @test @inferred(GrayA(val, 0.8)) === GrayA{Ta}(val, 0.8)
        end
        if !(val isa AbstractFloat)
            @test_broken @inferred(AGray(0, val)) === AGray{T}(0, 0.2)
            @test_broken @inferred(GrayA(1, val)) === GrayA{T}(1, 0.2)
        else
            @test @inferred(AGray(0, val)) === AGray{T}(0, 0.2)
            @test @inferred(GrayA(1, val)) === GrayA{T}(1, 0.2)
        end
    end
    for val in (1.2, 1.2f0, N4f12(1.2), Gray{N4f12}(1.2), 2, -0.2)
        T = val isa AbstractGray ? eltype(val) : typeof(val)
        !isa(val, Int) && @test @inferred(AGray(val)) === AGray{T}(val, 1)
        !isa(val, Int) && @test @inferred(GrayA(val)) === GrayA{T}(val, 1)
        @test_throws ArgumentError AGray{N0f8}(val)
        @test_throws ArgumentError GrayA{N0f16}(val, 0.8)
        @test_throws ArgumentError AGray32(val)
        @test_throws ArgumentError AGray32(val, 0.8)
    end
    # 0-arg constructor
    @test AGray() === AGray{N0f8}(0, 1)
    @test GrayA() === GrayA{N0f8}(0, 1)
    @test AGray32() === AGray32(0, 1)

    @test AGray(AGray()) === AGray()  # no StackOverflowError
    # construction from a "transparent" gray
    @test AGray{N0f16}(AGray(0.2, 0.8)) === AGray{N0f16}(0.2, 0.8)
    @test_broken GrayA{Float16}(AGray(0.2, 0.8), 0.6) === GrayA{Float16}(0.2, 0.6)
    @test_broken AGray32(AGray32(0.2, 0.8), 0.6) === AGray32(0.2, 0.6)
end

@testset "parametric3 constructors" begin
    @testset "$C constructor" for C in ColorTypes.parametric3
        et = (C <: AbstractRGB) ? N0f8 : Float32
        @test isa(C(1,0,0), C)
        @test isa(C(1,0,0), C{et})
        @test isa(C{Float32}(1, 0.5, 0), C{Float32})
        @test C(1N0f8, 0.6N0f8, 0N0f8) === C{et}(1, 0.6, 0) # issue #80
        @test C() === C{et}(0,0,0)
        @test C(C()) === C()  # no StackOverflowError
    end
end

@testset "transparent3 constructors" begin
    Cp3 = ColorTypes.parametric3
    Ctransparent = unique(vcat(coloralpha.(Cp3), alphacolor.(Cp3)))
    @testset "transparent3 constructors: $C" for C in Ctransparent
        et = (C <: TransparentRGB) ? N0f8 : Float32
        @test isa(C(1,0,0), C)
        @test isa(C(1,0,0), C{et})
        @test isa(C{Float32}(1, 0.5, 0), C{Float32})
        @test C(1,0,0,0.8) === C{Float64}(1,0,0,0.8)
        @test C(1,0,0) === C{et}(1,0,0,1)
        @test C(1,0,0,1) === C{et}(1,0,0,1)
        if C <: TransparentRGB
            @test C(1N0f8, 0.6N0f8, 0N0f8) === C{et}(1, 0.6, 0, 1)
        else
            @test_broken C(1N0f8, 0.6N0f8, 0N0f8) === C{et}(1, 0.6, 0, 1) # issue #156
        end
        @test C() === C{et}(0,0,0,1)
        @test C(C()) === C()  # no StackOverflowError
        @test C{Float16}(C(1, 0, 0, 0.8)) === C{Float16}(1, 0, 0, 0.8)
    end
end

@testset "constructors for other types" begin
    # @test Cyanotype() === Cyanotype{Float32}(0)
    # @test Cyanotype(1) === Cyanotype{Float32}(1)

    # @test C2() === C2{Float32}(0, 0)
    @test_throws MethodError C2(1)
    # @test C2(0.2, 0) === C2{Float64}(0.2, 0.0)
    # The following is the result of the default constructor having priority.
    # If you give preference to `eltype_default`, define the constructor
    # explicitly to prevent implicit argument conversion.
    @test C2(0, 1) === C2{Int}(0, 1) # !== C2{Float32}(0, 1)

    # @test C2A() === C2A{Float32}(0, 0, 1)
    @test_throws MethodError C2A(1)
    # @test C2A(0.2, 0) === C2A{Float64}(0.2, 0.0, 1.0)
    # @test C2A(0, 2, 1) === C2A{Float32}(0, 2, 1)

    # @test C4() === C4{Int16}(0, 0, 0, 0)
    @test_throws MethodError C4(1)
    @test_throws MethodError C4(1, 2)
    @test_throws MethodError C4(1, 2, 3)
    # @test C4(0.2, 0.5f0, 0.4, 0) === C4{Float64}(0.2, 0.5, 0.4, 0.0)
    # @test C4(0, true, 0x2, 3) === C4{Int}(0, 1, 2, 3)
    # @test C4(false, true, 0x2, Int8(3)) === C4{Int16}(0, 1, 2, 3)

    @test_broken AC4() === AC4{Int16}(0, 0, 0, 0, 1)
    @test_throws MethodError AC4(1)
    @test_throws MethodError AC4(1, 2)
    @test_throws MethodError AC4(1, 2, 3)
    # @test AC4(0.2, 0.5f0, 0.4, 0) === AC4{Float64}(0.2, 0.5, 0.4, 0.0, 1.0)
    # @test AC4(false, true, 0x2, Int8(3), Int16(1)) === AC4{Int16}(0, 1, 2, 3, 1)
end

@testset "construction from a non-gray Color1" begin
    ct = Cyanotype{Float32}(0.8) # blue (#006B8F), not light gray
    @test_broken Gray(ct) != Gray{Float32}(0.8)
    @test_broken AGray(ct) != AGray{Float32}(0.8, 1)
    @test_broken GrayA(ct, 0.2) != AGray{Float32}(0.8, 0.2)
    @test_throws MethodError AGray(1, ct)
    @test RGB(ct) === RGB{Float32}(0, 0.42, 0.56)
    @test_broken ARGB(ct) === ARGB{Float32}(0, 0.42, 0.56, 1)
    @test RGBA(ct, 0.2) === RGBA{Float32}(0, 0.42, 0.56, 0.2)
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
