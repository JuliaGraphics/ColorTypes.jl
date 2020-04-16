using ColorTypes
using ColorTypes.FixedPointNumbers
using Test

@testset "single color" begin
    iob = IOBuffer()
    cf  = RGB{Float32}(0.32218,0.14983,0.87819)
    c   = convert(RGB{N0f8}, cf)
    c16 = RGB{N0f16}(0.32218,0.14983,0.87819)
    ca  = RGBA{N0f8}(0.32218,0.14983,0.87819,0.99241)
    ac  = alphacolor(ca)

    show(iob, c)
    @test String(take!(iob)) == "RGB{N0f8}(0.322,0.149,0.878)"
    show(iob, c16)
    @test String(take!(iob)) == "RGB{N0f16}(0.32218,0.14983,0.87819)"
    show(iob, cf)
    @test String(take!(iob)) == "RGB{Float32}(0.32218f0,0.14983f0,0.87819f0)"
    show(IOContext(iob, :compact => true), cf)
    @test String(take!(iob)) == "RGB{Float32}(0.32218,0.14983,0.87819)"
    show(iob, ca)
    @test String(take!(iob)) == "RGBA{N0f8}(0.322,0.149,0.878,0.992)"
    show(IOContext(iob, :compact => true), ca)
    @test String(take!(iob)) == "RGBA{N0f8}(0.322,0.149,0.878,0.992)"
    show(iob, ac)
    @test String(take!(iob)) == "ARGB{N0f8}(0.322,0.149,0.878,0.992)"
    show(IOContext(iob, :compact => true), ac)
    @test String(take!(iob)) == "ARGB{N0f8}(0.322,0.149,0.878,0.992)"

    show(iob, RGB24(0.4,0.2,0.8))
    @test String(take!(iob)) == "RGB24(0.4N0f8,0.2N0f8,0.8N0f8)"
    show(iob, ARGB32(0.4,0.2,0.8,1.0))
    @test String(take!(iob)) == "ARGB32(0.4N0f8,0.2N0f8,0.8N0f8,1.0N0f8)"

    show(iob, Gray(0.8))
    @test String(take!(iob)) == "Gray{Float64}(0.8)"
    show(iob, GrayA(0.8))
    @test String(take!(iob)) == "GrayA{Float64}(0.8,1.0)"
    show(iob, AGray(0.8))
    @test String(take!(iob)) == "AGray{Float64}(0.8,1.0)"
    show(iob, Gray24(0.4))
    @test String(take!(iob)) == "Gray24(0.4N0f8)"
    show(iob, AGray32(0.8))
    @test String(take!(iob)) == "AGray32{N0f8}(0.8,1.0)"
end

@testset "collection of colors" begin
    iob = IOBuffer()
    summary(iob, Gray{N0f8}[0.2, 0.4, 0.6])
    @test String(take!(iob)) == "3-element Array{Gray{N0f8},1} with eltype Gray{Normed{UInt8,8}}"
    mat = RGB{Float64}[RGB(1,0,0) RGB(0,1,0); RGB(0,0,1) RGB(1,1,1)]
    summary(iob, mat)
    @test String(take!(iob)) == "2×2 Array{RGB{Float64},2} with eltype RGB{Float64}"
    summary(iob, view(mat,:,:))
    @test String(take!(iob)) == "2×2 view(::Array{RGB{Float64},2}, :, :) with eltype RGB{Float64}"
    summary(iob, TransparentColor[ARGB32(), HSVA(30,1,1,0.5)])
    @test String(take!(iob)) == "2-element Array{TransparentColor,1} with eltype TransparentColor"
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
    @test ColorTypes.colorant_string_with_eltype(RGB{Fractional}) == "RGB{Union{AbstractFloat, FixedPoint}}"
    @test ColorTypes.colorant_string_with_eltype(HSV{AbstractFloat}) == "HSV{AbstractFloat}"
    @test ColorTypes.colorant_string_with_eltype(TransparentColor) == "TransparentColor"
    @test ColorTypes.colorant_string_with_eltype(TransparentColor{RGB{Float32},Float32}) ==
        "TransparentColor{RGB{Float32},Float32,N} where N"
    @test ColorTypes.colorant_string_with_eltype(TransparentColor{RGB{Float32},Float32,4}) ==
        "TransparentColor{RGB{Float32},Float32,4}"
    @test_throws MethodError ColorTypes.colorant_string_with_eltype(Float32)
end
