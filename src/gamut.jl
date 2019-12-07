
abstract type AbstractGamut end

abstract type AbstractRGBGamut <: AbstractGamut end

abstract type Gamut_sRGB <: AbstractRGBGamut end

"""
    gamutmax(colorspace, gamut=Gamut_sRGB)

Returns the upper bound of `gamut` in `colorspace`. If the `gamut` exceeds the
upper bound of the `colorspace`, the latter is returned.
"""
gamutmax(::Type{T}) where {T<:Color} = gamutmax(T, Gamut_sRGB)

function gamutmax(colorspace::Type{T},
                  gamut::Type{<:AbstractGamut}=Gamut_sRGB) where {T<:TransparentColor}
    (gamutmax(color_type(T), Gamut_sRGB)..., 1)
end

function gamutmax(::Type{T}, gamut::AbstractGamut) where {T<:Colorant}
    gamutmax(T, typeof(gamut)) # fallback
end

"""
    gamutmin(colorspace, gamut=Gamut_sRGB)

Returns the lower bound of `gamut` in `colorspace`. If the `gamut` exceeds (is
below) the lower bound of the `colorspace`, the latter is returned.
"""
gamutmin(::Type{T}) where {T<:Color} = gamutmin(T, Gamut_sRGB)

function gamutmin(colorspace::Type{T},
                  gamut::Type{<:AbstractGamut}=Gamut_sRGB) where {T<:TransparentColor}
    (gamutmin(color_type(T), Gamut_sRGB)..., 0)
end

function gamutin(::Type{T}, gamut::AbstractGamut) where {T<:Colorant}
    gamutmin(T, typeof(gamut)) # fallback
end


# the following values based on the D65 whitepoint
gamutmin(::Type{<:Color3}, ::Type{Gamut_sRGB}) = (0,0,0)

gamutmax(::Type{<:AbstractRGB}, ::Type{Gamut_sRGB}) = (1,1,1)

gamutmax(::Type{<:HSV}, ::Type{Gamut_sRGB}) = (360,1,1)

gamutmax(::Type{<:HSL}, ::Type{Gamut_sRGB}) = (360,1,1)

gamutmax(::Type{<:HSI}, ::Type{Gamut_sRGB}) = (360,1,1)

gamutmax(::Type{<:XYZ}, ::Type{Gamut_sRGB}) = (0.9505,1,1.089)

gamutmax(::Type{<:xyY}, ::Type{Gamut_sRGB}) = (0.3127,0.3290,1)


gamutmax(::Type{<:Lab}, ::Type{Gamut_sRGB}) = (100,98.2343,94.4779)
gamutmin(::Type{<:Lab}, ::Type{Gamut_sRGB}) = (0,-86.1827,-107.8602)

gamutmax(::Type{<:Luv}, ::Type{Gamut_sRGB}) = (100,175.0150,107.3985)
gamutmin(::Type{<:Luv}, ::Type{Gamut_sRGB}) = (0,-83.077,-134.1030)

gamutmax(::Type{<:LCHab}, ::Type{Gamut_sRGB}) = (100,133.8076,360)

gamutmax(::Type{<:LCHuv}, ::Type{Gamut_sRGB}) = (100,179.0414,360)

gamutmax(::Type{<:DIN99}, ::Type{Gamut_sRGB}) = (100.0013,36.1753,31.1551)
gamutmin(::Type{<:DIN99}, ::Type{Gamut_sRGB}) = (0,-27.4504,-33.3955)

gamutmax(::Type{<:DIN99d}, ::Type{Gamut_sRGB}) = (100.0002,43.6867,43.6318)
gamutmin(::Type{<:DIN99d}, ::Type{Gamut_sRGB}) = (0,-38.1436,-45.8498)

gamutmax(::Type{<:DIN99o}, ::Type{Gamut_sRGB}) = (99.9997,45.5242,44.3662)
gamutmin(::Type{<:DIN99o}, ::Type{Gamut_sRGB}) = (0,-40.1101,-40.4900)

# LMS colorspace depends on color appearance models.
gamutmax(::Type{<:LMS}, ::Type{Gamut_sRGB}) = (0.9493,1.0354,1.0872)

gamutmax(::Type{<:YIQ}, ::Type{Gamut_sRGB}) = (1,0.5957,0.5226)
gamutmin(::Type{<:YIQ}, ::Type{Gamut_sRGB}) = (0,-0.5957,-0.5226)

gamutmax(::Type{<:YCbCr}, ::Type{Gamut_sRGB}) = (235,240,240)
gamutmin(::Type{<:YCbCr}, ::Type{Gamut_sRGB}) = (16,16,16)

gamutmax(::Type{<:AbstractGray}, ::Type{Gamut_sRGB}) = (1,)
gamutmin(::Type{<:AbstractGray}, ::Type{Gamut_sRGB}) = (0,)
