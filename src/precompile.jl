function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    eltypes = (N0f8, N0f16, Float32, Float64)        # eltypes of parametric colors
    pctypes = (Gray, RGB, AGray, GrayA, ARGB, RGBA)  # parametric colors
    cctypes = (Gray24, AGray32, RGB24, ARGB32)       # non-parametric colors
    realtypes = (Float16, Float32, Float64, Int)     # types for mixed Normed/Real operations
    # Constructors
    for R in realtypes
        for T in eltypes
            precompile(Tuple{Type{Gray{T}},R})
            precompile(Tuple{Type{AGray{T}},R})
            precompile(Tuple{Type{GrayA{T}},R})
            precompile(Tuple{Type{AGray{T}},R,R})
            precompile(Tuple{Type{GrayA{T}},R,R})
            precompile(Tuple{Type{RGB{T}},R,R,R})
            precompile(Tuple{Type{RGBA{T}},R,R,R})
            precompile(Tuple{Type{RGBA{T}},R,R,R,R})
            precompile(Tuple{Type{ARGB{T}},R,R,R})
            precompile(Tuple{Type{ARGB{T}},R,R,R,R})
        end
        precompile(Tuple{Type{Gray},R})
        precompile(Tuple{Type{AGray},R})
        precompile(Tuple{Type{GrayA},R})
        precompile(Tuple{Type{AGray},R,R})
        precompile(Tuple{Type{GrayA},R,R})
        precompile(Tuple{Type{RGB},R,R,R})
        precompile(Tuple{Type{RGBA},R,R,R})
        precompile(Tuple{Type{RGBA},R,R,R,R})
        precompile(Tuple{Type{ARGB},R,R,R})
        precompile(Tuple{Type{ARGB},R,R,R,R})
        precompile(Tuple{Type{Gray24},R})
        precompile(Tuple{Type{AGray32},R})
        precompile(Tuple{Type{AGray32},R,R})
        precompile(Tuple{Type{RGB24},R,R,R})
        precompile(Tuple{Type{ARGB32},R,R,R})
        precompile(Tuple{Type{ARGB32},R,R,R,R})
    end
    precompile(Tuple{Type{Gray24},UInt32,Type{Val{true}}})
    precompile(Tuple{Type{AGray32},UInt32,Type{Val{true}}})
    precompile(Tuple{Type{RGB24},UInt32,Type{Val{true}}})
    precompile(Tuple{Type{ARGB32},UInt32,Type{Val{true}}})
    # LCHab is used by distinguishable_colors
    for R in (Float32, Float64)
        precompile(Tuple{Type{LCHab},R,R,R})
    end
    # convert
    for T1 in eltypes, T2 in eltypes
        precompile(Tuple{typeof(convert),Type{Gray{T1}},Gray{T2}})
        precompile(Tuple{typeof(convert),Type{RGB{T1}},RGB{T2}})
        precompile(Tuple{typeof(convert),Type{RGB{T1}},Gray{T2}})
        precompile(Tuple{typeof(convert),Type{RGBA{T1}},RGB{T2}})
        precompile(Tuple{typeof(convert),Type{RGBA{T1}},RGBA{T2}})
        precompile(Tuple{typeof(convert),Type{RGBA{T1}},ARGB{T2}})
        precompile(Tuple{typeof(convert),Type{RGBA{T1}},Gray{T2}})
        precompile(Tuple{typeof(convert),Type{ARGB{T1}},RGB{T2}})
        precompile(Tuple{typeof(convert),Type{ARGB{T1}},RGBA{T2}})
        precompile(Tuple{typeof(convert),Type{ARGB{T1}},ARGB{T2}})
        precompile(Tuple{typeof(convert),Type{ARGB{T1}},Gray{T2}})
    end
    # traits
    for T in eltypes, C in pctypes
        precompile(Tuple{typeof(eltype),Type{C}})
        precompile(Tuple{typeof(eltype),Type{C{T}}})
        precompile(Tuple{typeof(alpha),C{T}})
        C <: AbstractGray && precompile(Tuple{typeof(gray),C{T}})
        C <: AbstractRGB || continue
        precompile(Tuple{typeof(red),C{T}})
        precompile(Tuple{typeof(green),C{T}})
        precompile(Tuple{typeof(blue),C{T}})
    end
    for C in cctypes
        precompile(Tuple{typeof(eltype),Type{C}})
        precompile(Tuple{typeof(alpha),C})
        C <: AbstractGray && precompile(Tuple{typeof(gray),C})
        C <: AbstractRGB || continue
        precompile(Tuple{typeof(red),C})
        precompile(Tuple{typeof(green),C})
        precompile(Tuple{typeof(blue),C})
    end
    precompile(Tuple{typeof(eltype),Type{AbstractGray{T} where T<:Fractional}})
    precompile(Tuple{typeof(eltype),Type{AbstractRGB{T} where T<:Fractional}})
    # ccolor typically gets compiled as part of other things
    # hash
    for T in eltypes, C in pctypes
        precompile(Tuple{typeof(hash),Type{C{T}},UInt})
    end
    for C in cctypes
        precompile(Tuple{typeof(hash),Type{C},UInt})
    end
    # rand
    for T in eltypes, C in pctypes
        precompile(Tuple{typeof(rand),Type{C{T}},Tuple{Int}})
        precompile(Tuple{typeof(rand),Type{C{T}},Tuple{Int,Int}})
        precompile(Tuple{typeof(rand),Type{C{T}},Tuple{Int,Int,Int}})
        precompile(Tuple{typeof(rand),Type{C{T}},Int})
        precompile(Tuple{typeof(rand),Type{C{T}},Int,Int})
        precompile(Tuple{typeof(rand),Type{C{T}},Int,Int,Int})
    end
    for C in cctypes
        precompile(Tuple{typeof(rand),Type{C},Tuple{Int}})
        precompile(Tuple{typeof(rand),Type{C},Tuple{Int,Int}})
    end
    precompile(Tuple{typeof(rand),Type{Gray{Bool}},Tuple{Int}})
    precompile(Tuple{typeof(rand),Type{Gray{Bool}},Tuple{Int,Int}})
    precompile(Tuple{typeof(rand),Type{Gray{Bool}},Tuple{Int,Int,Int}})
    # show
    for IO in (IOBuffer, IOContext{IOBuffer}, IOContext{Base.TTY})
        for T in eltypes, C in pctypes
            precompile(Tuple{typeof(show),IO,C{T}})
        end
        for C in cctypes
            precompile(Tuple{typeof(show),IO,C})
        end
        precompile(Tuple{typeof(show),IO,Gray{Bool}})
    end
    # FIXME the following do not yet "work", meaning you can issue these precompile directives but no value comes of it.
    # Possibly this is https://github.com/JuliaLang/julia/pull/32705, but the actual cause is unknown.
    # # permutedims
    # for T in eltypes, C in pctypes, n = 2:4
    #     precompile(permutedims, (Array{C{T},n}, Tuple{Vararg{Int,n}}))
    # end
    # # broadcast
    # for T1 in eltypes, T2 in eltypes, n = 2:4
    #     precompile(broadcast, (Type{T1}, Array{Gray{T2},n}))
    #     precompile(broadcast, (Type{Gray{T1}}, Array{T2,n}))
    #     precompile(broadcast, (Type{Gray{T1}}, Array{Gray{T2},n}))
    #     precompile(broadcast, (Type{RGB{T1}}, Array{RGB{T2},n}))
    #     precompile(Broadcast.materialize, (Broadcast.Broadcasted{Broadcast.DefaultArrayStyle{n},Nothing,Type{T1},Tuple{Array{Gray{T2},n}}},))
    #     precompile(Broadcast.materialize, (Broadcast.Broadcasted{Broadcast.DefaultArrayStyle{n},Nothing,Type{Gray{T1}},Tuple{Array{T2,n}}},))
    #     precompile(Broadcast.materialize, (Broadcast.Broadcasted{Broadcast.DefaultArrayStyle{n},Nothing,Type{Gray{T1}},Tuple{Array{Gray{T2},n}}},))
    #     precompile(Broadcast.materialize, (Broadcast.Broadcasted{Broadcast.DefaultArrayStyle{n},Nothing,Type{RGB{T1}},Tuple{Array{RGB{T2},n}}},))
    # end

    # mapc, reducec, and mapreducec are not really precompilable,
    # since they will be specialized for f
end
