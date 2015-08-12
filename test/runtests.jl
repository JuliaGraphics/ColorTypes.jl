using ColorTypes
using Base.Test

@test eltype(Paint{U8}) == U8
@test eltype(RGB{Float32}) == Float32
@test eltype(RGBA{Float64}) == Float64
# @test eltype(RGB) == TypeVar(:T, Fractional)
eltype(RGB)      # just test that it doesn't error

@test colortype(RGB{U8}) == RGB{U8}
@test colortype(RGB) == RGB
@test colortype(RGBA{Float32}) == RGB{Float32}
@test colortype(GrayAlpha{U8}) == Gray{U8}
@test colortype(RGB24)  == RGB24
@test colortype(ARGB32) == RGB24
@test colortype(Transparent{RGB}) == RGB
@test colortype(Transparent{RGB,Float64}) == RGB
@test colortype(Transparent{RGB{Float64},Float64}) == RGB{Float64}
@test_throws MethodError colortype(Transparent)
@test_throws MethodError colortype(Paint{U8})

@test basecolortype(RGBA{Float32}) == RGB
@test basecolortype(BGR{U8}) == BGR
