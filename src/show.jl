show(io::IO, c::Colorant) = get(io, :compact, false) ? _showcompact(io, c) : _show(io, c)
show(io::IO, c::ColorantNormed) = show_normed(io, c)

# Nonparametric types
show_normed(io::IO, c::Gray24) = print(io, "Gray24(", gray(c), ')')
show_normed(io::IO, c::RGB24)  = print(io, "RGB24(", red(c), ',', green(c), ',', blue(c), ')')
show_normed(io::IO, c::ARGB32) = print(io, "ARGB32(", red(c), ',', green(c), ',', blue(c), ',', alpha(c), ')')

# FIXME: handle `Color` and `TransparentColor` correctly
#       (e.g. `Color{T,4}` such as CMYK is different from `Transparent3`).
for N = 1:4
    component = N >= 3 ? (:comp1, :comp2, :comp3, :alpha) : (:comp1, :alpha)
    printargs = Array{Any}(undef, 2, N)
    for i = 1:N
        printargs[1,i] = :(show(io, $(component[i])(c)))
        chr = i < N ? ',' : ')'
        printargs[2,i] = :(print(io, $chr))
    end
    @eval begin
        function _show(io::IO, c::Colorant{T,$N}) where T
            print(io, colorant_string(typeof(c)), "{", T, "}(")
            $(printargs[:]...)
        end
    end
    for i = 1:N
        printargs[1,i] = :(show(IOContext(io, :compact => true), $(component[i])(c)))
    end
    @eval begin
        function _showcompact(io::IO, c::Colorant{T,$N}) where T
            print(io, colorant_string(typeof(c)), "{", T, "}(")
            $(printargs[:]...)
        end
        # Special handling for Normed types: don't print the giant type name
        function show_normed(io::IO, c::Colorant{FixedPointNumbers.Normed{T,f},$N}) where {T,f}
            print(io, colorant_string(typeof(c)), '{')
            FixedPointNumbers.showtype(io, eltype(typeof(c)))
            print(io, "}(")
            $(printargs[:]...)
        end
    end
end

function Base.showarg(io::IO, a::Array{C}, toplevel) where C<:Colorant
    toplevel || print(io, "::")
    print(io, "Array{")
    colorant_string_with_eltype(io, C)
    print(io, ",$(ndims(a))}")
    toplevel && print(io, " with eltype ", C)
end


colorant_string(::Type{Union{}}) = "Union{}"
colorant_string(::Type{C}) where {C<:Colorant} = string(nameof(C))
function colorant_string_with_eltype(::Type{C}) where {C<:Colorant}
    io = IOBuffer()
    colorant_string_with_eltype(io, C)
    String(take!(io))
end
colorant_string_with_eltype(io::IO, ::Type{Union{}}) = show(io, Union{})
function colorant_string_with_eltype(io::IO, ::Type{C}) where {C<:Colorant}
    if isconcretetype(C)
        print(io, colorant_string(C))
        print(io, '{')
        showcoloranttype(io, eltype(C))
        print(io, '}')
    else
        print(io, C)
    end
end
# Nonparametric types
colorant_string_with_eltype(io::IO, ::Type{Gray24})  = print(io, "Gray24")
colorant_string_with_eltype(io::IO, ::Type{AGray32}) = print(io, "AGray32")
colorant_string_with_eltype(io::IO, ::Type{RGB24})   = print(io, "RGB24")
colorant_string_with_eltype(io::IO, ::Type{ARGB32})  = print(io, "ARGB32")

showcoloranttype(io, ::Type{Union{}}) = show(io, Union{})
showcoloranttype(io, ::Type{T}) where {T<:FixedPoint} = FixedPointNumbers.showtype(io, T)
showcoloranttype(io, ::Type{T}) where {T} = show(io, T)
