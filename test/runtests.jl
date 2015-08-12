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
@test colortype(RGBA) == RGB
@test colortype(RGB24)  == RGB24
@test colortype(ARGB32) == RGB24
@test colortype(Transparent{RGB}) == RGB
@test colortype(Transparent{RGB,Float64}) == RGB
@test colortype(Transparent{RGB{Float64},Float64}) == RGB{Float64}
@test_throws MethodError colortype(Transparent)
@test_throws MethodError colortype(Paint{U8})

@test basecolortype(RGBA{Float32}) == RGB
@test basecolortype(ARGB{Float32}) == RGB
@test basecolortype(BGR{U8})       == BGR
@test basecolortype(HSV)  == HSV
@test basecolortype(HSVA) == HSV
@test basecolortype(Transparent{RGB{Float64},Float64}) == RGB

@test basepainttype(RGBA{Float32}) == RGBA
@test basepainttype(ARGB{Float32}) == ARGB
@test basepainttype(BGR{U8})       == BGR
@test basepainttype(HSV)  == HSV
@test basepainttype(HSVA) == HSVA
@test_throws MethodError basepainttype(Transparent{RGB{Float64},Float64})

@test ccolor(RGB{Float32}, HSV{Float32}) == RGB{Float32}
@test ccolor(RGB{U8},      HSV{Float32}) == RGB{U8}
@test ccolor(RGB,          HSV{Float32}) == RGB{Float32}
@test ccolor(ARGB{Float32}, HSV{Float32}) == ARGB{Float32}
@test ccolor(ARGB{U8},      HSV{Float32}) == ARGB{U8}
@test ccolor(ARGB,          HSV{Float32}) == ARGB{Float32}

@test eltype(RGB{U8}(1,0,0)) == U8
@test eltype(argb(1.0,0.8,0.6,0.4)) == Float64

@test colortype(RGB{U8}(1,0,0)) == RGB{U8}
@test colortype(argb(1.0,0.8,0.6,0.4)) == RGB{Float64}

@test basecolortype(RGB{U8}(1,0,0)) == RGB
@test basecolortype(argb(1.0,0.8,0.6,0.4)) == RGB

@test basepainttype(RGB{U8}(1,0,0)) == RGB
@test basepainttype(argb(1.0,0.8,0.6,0.4)) == ARGB
