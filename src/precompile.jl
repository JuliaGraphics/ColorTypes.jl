function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    eltypes = (N0f8, N0f16, Float32, Float64)        # eltypes of parametric colors
    pctypes = (Gray, RGB, AGray, GrayA, ARGB, RGBA)  # parametric colors
    cctypes = (Gray24, AGray32, RGB24, ARGB32)       # non-parametric colors
    realtypes = (Float16, Float32, Float64, Int)     # types for mixed Normed/Real operations
    # Constructors
    for R in realtypes
        for T in eltypes
            @assert precompile(Tuple{Type{Gray{T}},R})
            @assert precompile(Tuple{Type{AGray{T}},R})
            @assert precompile(Tuple{Type{GrayA{T}},R})
            @assert precompile(Tuple{Type{AGray{T}},R,R})
            @assert precompile(Tuple{Type{GrayA{T}},R,R})
            @assert precompile(Tuple{Type{RGB{T}},R,R,R})
            @assert precompile(Tuple{Type{RGBA{T}},R,R,R})
            @assert precompile(Tuple{Type{RGBA{T}},R,R,R,R})
            @assert precompile(Tuple{Type{ARGB{T}},R,R,R})
            @assert precompile(Tuple{Type{ARGB{T}},R,R,R,R})
        end
        @assert precompile(Tuple{Type{Gray},R})
        @assert precompile(Tuple{Type{AGray},R})
        @assert precompile(Tuple{Type{GrayA},R})
        @assert precompile(Tuple{Type{AGray},R,R})
        @assert precompile(Tuple{Type{GrayA},R,R})
        @assert precompile(Tuple{Type{RGB},R,R,R})
        @assert precompile(Tuple{Type{RGBA},R,R,R})
        @assert precompile(Tuple{Type{RGBA},R,R,R,R})
        @assert precompile(Tuple{Type{ARGB},R,R,R})
        @assert precompile(Tuple{Type{ARGB},R,R,R,R})
        @assert precompile(Tuple{Type{Gray24},R})
        @assert precompile(Tuple{Type{AGray32},R})
        @assert precompile(Tuple{Type{AGray32},R,R})
        @assert precompile(Tuple{Type{RGB24},R,R,R})
        @assert precompile(Tuple{Type{ARGB32},R,R,R})
        @assert precompile(Tuple{Type{ARGB32},R,R,R,R})
    end
    @assert precompile(Tuple{Type{Gray24},UInt32,Type{Val{true}}})
    @assert precompile(Tuple{Type{AGray32},UInt32,Type{Val{true}}})
    @assert precompile(Tuple{Type{RGB24},UInt32,Type{Val{true}}})
    @assert precompile(Tuple{Type{ARGB32},UInt32,Type{Val{true}}})
    # LCHab is used by distinguishable_colors
    for R in (Float32, Float64)
        @assert precompile(Tuple{Type{LCHab},R,R,R})
    end
    # convert
    for T1 in eltypes, T2 in eltypes
        @assert precompile(Tuple{typeof(convert),Type{Gray{T1}},Gray{T2}})
        @assert precompile(Tuple{typeof(convert),Type{RGB{T1}},RGB{T2}})
        @assert precompile(Tuple{typeof(convert),Type{RGB{T1}},Gray{T2}})
        @assert precompile(Tuple{typeof(convert),Type{RGBA{T1}},RGB{T2}})
        @assert precompile(Tuple{typeof(convert),Type{RGBA{T1}},RGBA{T2}})
        @assert precompile(Tuple{typeof(convert),Type{RGBA{T1}},ARGB{T2}})
        @assert precompile(Tuple{typeof(convert),Type{RGBA{T1}},Gray{T2}})
        @assert precompile(Tuple{typeof(convert),Type{ARGB{T1}},RGB{T2}})
        @assert precompile(Tuple{typeof(convert),Type{ARGB{T1}},RGBA{T2}})
        @assert precompile(Tuple{typeof(convert),Type{ARGB{T1}},ARGB{T2}})
        @assert precompile(Tuple{typeof(convert),Type{ARGB{T1}},Gray{T2}})
    end
    # traits
    for T in eltypes, C in pctypes
        @assert precompile(Tuple{typeof(alpha),C{T}})
        C <: AbstractGray && @assert precompile(Tuple{typeof(gray),C{T}})
        C <: AbstractRGB || continue
        @assert precompile(Tuple{typeof(red),C{T}})
        @assert precompile(Tuple{typeof(green),C{T}})
        @assert precompile(Tuple{typeof(blue),C{T}})
    end
    for C in cctypes
        @assert precompile(Tuple{typeof(alpha),C})
        C <: AbstractGray && @assert precompile(Tuple{typeof(gray),C})
        C <: AbstractRGB || continue
        @assert precompile(Tuple{typeof(red),C})
        @assert precompile(Tuple{typeof(green),C})
        @assert precompile(Tuple{typeof(blue),C})
    end
    # ccolor typically gets compiled as part of other things
    # hash
    for T in eltypes, C in pctypes
        @assert precompile(Tuple{typeof(hash),Type{C{T}},UInt})
    end
    for C in cctypes
        @assert precompile(Tuple{typeof(hash),Type{C},UInt})
    end
    # rand
    for T in eltypes, C in pctypes
        @assert precompile(Tuple{typeof(rand),Type{C{T}},Tuple{Int}})
        @assert precompile(Tuple{typeof(rand),Type{C{T}},Tuple{Int,Int}})
        @assert precompile(Tuple{typeof(rand),Type{C{T}},Int})
        @assert precompile(Tuple{typeof(rand),Type{C{T}},Int,Int})
    end
    for C in cctypes
        @assert precompile(Tuple{typeof(rand),Type{C},Tuple{Int}})
        @assert precompile(Tuple{typeof(rand),Type{C},Tuple{Int,Int}})
    end
    # mapc, reducec, and mapreducec are not really precompilable,
    # since they will be specialized for f
end
