using ColorTypes
using ColorTypes.FixedPointNumbers
using Test

@isdefined(CustomTypes) || include("customtypes.jl")
using .CustomTypes

SP = VERSION >= v"1.6.0-DEV.771" ? " " : "" # JuliaLang/julia #37085

@testset "single color" begin
    iob = IOBuffer()
    show(iob, RGB{N0f8}(0, 1/3, 1))
    @test String(take!(iob)) == "RGB{N0f8}(0.0, 0.333, 1.0)"
    show(iob, RGB{N0f16}(0, 1/3, 1))
    @test String(take!(iob)) == "RGB{N0f16}(0.0, 0.33333, 1.0)"
    show(iob, RGB{Float64}(0, 1/3, 1))
    @test String(take!(iob)) == "RGB{Float64}(0.0, 0.3333333333333333, 1.0)"
    show(IOContext(iob, :compact => true), RGB{Float64}(0, 1/3, 1))
    @test String(take!(iob)) == "RGB{Float64}(0.0, 0.333333, 1.0)"
    show(iob, RGBA{N0f8}(0, 1/3, 1, 0.5))
    @test String(take!(iob)) == "RGBA{N0f8}(0.0, 0.333, 1.0, 0.502)"
    show(IOContext(iob, :compact => true), RGBA{N0f8}(0, 1/3, 1, 0.5))
    @test String(take!(iob)) == "RGBA{N0f8}(0.0, 0.333, 1.0, 0.502)"
    show(iob, ARGB{N0f8}(0, 1/3, 1, 0.5))
    @test String(take!(iob)) == "ARGB{N0f8}(0.0, 0.333, 1.0, 0.502)"
    show(IOContext(iob, :compact => true), ARGB{N0f8}(0, 1/3, 1, 0.5))
    @test String(take!(iob)) == "ARGB{N0f8}(0.0, 0.333, 1.0, 0.502)"

    show(iob, RGB24(0.4,0.2,0.8))
    @test String(take!(iob)) == "RGB24(0.4N0f8, 0.2N0f8, 0.8N0f8)"
    show(iob, ARGB32(0.4,0.2,0.8,1.0))
    @test String(take!(iob)) == "ARGB32(0.4N0f8, 0.2N0f8, 0.8N0f8, 1.0N0f8)"
    show(IOContext(iob, :compact => true), ARGB32(0.4,0.2,0.8,1.0))
    @test String(take!(iob)) == "ARGB32(0.4, 0.2, 0.8, 1.0)"

    show(iob, Gray(0.8))
    @test String(take!(iob)) == "Gray{Float64}(0.8)"
    show(iob, GrayA(0.8))
    @test String(take!(iob)) == "GrayA{Float64}(0.8, 1.0)"
    show(iob, AGray(0.8))
    @test String(take!(iob)) == "AGray{Float64}(0.8, 1.0)"
    show(iob, Gray{Bool}(1))
    @test String(take!(iob)) == "Gray{Bool}(1)"
    show(iob, Gray24(0.4))
    @test String(take!(iob)) == "Gray24(0.4N0f8)"
    show(iob, AGray32(0.8))
    @test String(take!(iob)) == "AGray32(0.8N0f8, 1.0N0f8)"

    show(iob, CustomTypes.RGBA32(0.4, 0.2, 0.8, 1.0))
    @test String(take!(iob)) == "RGBA32(0.4N0f8, 0.2N0f8, 0.8N0f8, 1.0N0f8)"
    show(iob, AnaglyphColor{Float32}(0.4, 0.2))
    @test String(take!(iob)) == "AnaglyphColor{Float32}(0.4, 0.2)"
    show(iob, CMYK{Float64}(0.1, 0.2, 0.3, 0.4))
    @test String(take!(iob)) == "CMYK{Float64}(0.1, 0.2, 0.3, 0.4)"
    show(iob, ACMYK{N0f8}(0.2, 0.4, 0.6, 0.8))
    @test String(take!(iob)) == "ACMYK{N0f8}(0.2, 0.4, 0.6, 0.8, 1.0)"
end

@testset "array element" begin
    iob = IOBuffer()
    rgbf64 = RGB{Float64}(0, 1/3, 1)
    show(IOContext(iob, :typeinfo=>RGB{Float64}), rgbf64)
    @test String(take!(iob)) == "RGB(0.0, 0.3333333333333333, 1.0)"
    show(IOContext(iob, :typeinfo=>RGB{Float64}, :compact=>true), rgbf64)
    @test String(take!(iob)) == "RGB(0.0, 0.333333, 1.0)"
    show(IOContext(iob, :typeinfo=>RGB), rgbf64)
    @test String(take!(iob)) == "RGB{Float64}(0.0, 0.3333333333333333, 1.0)"

    argb32 = ARGB32(0.4,0.2,0.8,1.0)
    show(IOContext(iob, :typeinfo=>ARGB32), argb32)
    @test String(take!(iob)) == "ARGB32(0.4N0f8, 0.2N0f8, 0.8N0f8, 1.0N0f8)"
    show(IOContext(iob, :typeinfo=>ARGB32, :compact=>true), argb32)
    @test String(take!(iob)) == "ARGB32(0.4, 0.2, 0.8, 1.0)"
    show(IOContext(iob, :typeinfo=>ARGB), argb32)
    @test String(take!(iob)) == "ARGB32(0.4N0f8, 0.2N0f8, 0.8N0f8, 1.0N0f8)"

    grayf64 = Gray{Float64}(1/3)
    show(IOContext(iob, :typeinfo=>Gray{Float64}), grayf64)
    @test String(take!(iob)) == "0.3333333333333333"
    show(IOContext(iob, :typeinfo=>Gray{Float64}, :compact=>true), grayf64)
    @test String(take!(iob)) == "0.333333"
    show(IOContext(iob, :typeinfo=>Gray), grayf64)
    @test String(take!(iob)) == "Gray{Float64}(0.3333333333333333)"

    grayb = Gray{Bool}(1)
    show(IOContext(iob, :typeinfo=>Gray{Bool}), grayb)
    @test String(take!(iob)) == "1"
    show(IOContext(iob, :typeinfo=>Gray{Bool}, :compact=>true), grayb)
    @test String(take!(iob)) == "1"
    show(IOContext(iob, :typeinfo=>Gray), grayb)
    @test String(take!(iob)) == "Gray{Bool}(1)"
end

@testset "summary" begin
    iob = IOBuffer()
    summary(iob, Gray{N0f8}[0.2, 0.4, 0.6])
    vec_summary = String(take!(iob))

    mat = RGB{Float64}[RGB(1,0,0) RGB(0,1,0); RGB(0,0,1) RGB(1,1,1)]
    summary(iob, mat)
    mat_summary = String(take!(iob))

    summary(iob, view(mat,:,:))
    view_summary = String(take!(iob))

    summary(iob, TransparentColor[ARGB32(), HSVA(30,1,1,0.5)])
    avec_summary = String(take!(iob))

    if VERSION >= v"1.6.0-DEV.356"
        @test vec_summary == "3-element Vector{Gray{N0f8}}"
        @test mat_summary == "2×2 Matrix{RGB{Float64}}"
        @test view_summary == "2×2 view(::Matrix{RGB{Float64}}, :, :) with eltype RGB{Float64}"
        @test avec_summary == "2-element Vector{TransparentColor}"
    else
        @test vec_summary == "3-element Array{Gray{N0f8},1} with eltype Gray{Normed{UInt8,8}}"
        @test mat_summary == "2×2 Array{RGB{Float64},2}"
        @test view_summary == "2×2 view(::Array{RGB{Float64},2}, :, :) with eltype RGB{Float64}"
        @test avec_summary == "2-element Array{TransparentColor,1}"
    end
end

@testset "colorant_string" begin
    @test ColorTypes.colorant_string(Union{}) == "Union{}"
    @test ColorTypes.colorant_string(RGB{N0f8}) == "RGB"
    @test ColorTypes.colorant_string(HSV{Float32}) == "HSV"
    @test ColorTypes.colorant_string(RGB24) == "RGB24"
    @test ColorTypes.colorant_string(ARGB32) == "ARGB32"
    @test ColorTypes.colorant_string(Gray24) == "Gray24"
    @test ColorTypes.colorant_string(AGray32) == "AGray32"
    @test ColorTypes.colorant_string(RGB) == "RGB"
    @test_throws MethodError ColorTypes.colorant_string(Float32)
end

@testset "colorant_string_with_eltype" begin
    @test ColorTypes.colorant_string_with_eltype(Union{}) == "Union{}"
    @test ColorTypes.colorant_string_with_eltype(RGB{N0f8}) == "RGB{N0f8}"
    @test ColorTypes.colorant_string_with_eltype(HSV{Float32}) == "HSV{Float32}"
    @test ColorTypes.colorant_string_with_eltype(RGB24) == "RGB24"
    @test ColorTypes.colorant_string_with_eltype(ARGB32) == "ARGB32"
    @test ColorTypes.colorant_string_with_eltype(Gray24) == "Gray24"
    @test ColorTypes.colorant_string_with_eltype(AGray32) == "AGray32"
    @test ColorTypes.colorant_string_with_eltype(RGB) == "RGB"
    @test ColorTypes.colorant_string_with_eltype(RGB{Union{}}) == "RGB{Union{}}"
    @test ColorTypes.colorant_string_with_eltype(RGB{<:Fractional}) == "RGB"
    @test ColorTypes.colorant_string_with_eltype(HSV{<:AbstractFloat}) == "HSV"
    rgb_fractional = ColorTypes.colorant_string_with_eltype(RGB{Fractional})
    if VERSION >= v"1.6.0-DEV.356"
        @test eval(Meta.parse(rgb_fractional)) == RGB{Union{AbstractFloat, FixedPoint}}
    else
        @test rgb_fractional == "RGB{Union{AbstractFloat, FixedPoint}}"
    end
    @test ColorTypes.colorant_string_with_eltype(HSV{AbstractFloat}) == "HSV{AbstractFloat}"
    @test ColorTypes.colorant_string_with_eltype(TransparentColor) == "TransparentColor"
    if occursin("where", sprint(show, Array{Float32, N} where N)) # cf. JuliaLang/julia PR #39395
        @test ColorTypes.colorant_string_with_eltype(TransparentColor{RGB{Float32},Float32}) ==
            "TransparentColor{RGB{Float32},$(SP)Float32,$(SP)N} where N"
    else
        @test ColorTypes.colorant_string_with_eltype(TransparentColor{RGB{Float32},Float32}) ==
            "TransparentColor{RGB{Float32},$(SP)Float32}"
    end
    @test ColorTypes.colorant_string_with_eltype(TransparentColor{RGB{Float32},Float32,4}) ==
        "TransparentColor{RGB{Float32},$(SP)Float32,$(SP)4}"
    @test_throws MethodError ColorTypes.colorant_string_with_eltype(Float32)
end
