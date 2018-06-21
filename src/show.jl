show(io::IO, c::Colorant) = get(io, :compact, false) ? _showcompact(io, c) : _show(io, c)
show(io::IO, c::ColorantNormed) = show_normed(io, c)

# Nonparametric types
show_normed(io::IO, c::Gray24) = print(io, "Gray24(", gray(c), ')')
show_normed(io::IO, c::RGB24)  = print(io, "RGB24(", red(c), ',', green(c), ',', blue(c), ')')
show_normed(io::IO, c::ARGB32) = print(io, "ARGB32(", red(c), ',', green(c), ',', blue(c), ',', alpha(c), ')')

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
