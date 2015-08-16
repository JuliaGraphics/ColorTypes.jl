Base.show(io::IO, c::Paint)        = show_paint(io, to_paint(c), c)
Base.showcompact(io::IO, c::Paint) = showcompact_paint(io, to_paint(c), c)

show_paint{T<:Ufixed,N}(io, ::Type{Paint{T,N}}, c)        = show_paint_ufixed(io, Paint{T,N}, c)
showcompact_paint{T<:Ufixed,N}(io, ::Type{Paint{T,N}}, c) = show_paint_ufixed(io, Paint{T,N}, c)

for N = 1:4
    component = N >= 3 ? (:comp1, :comp2, :comp3, :alpha) : (:comp1, :alpha)
    printargs = Array(Any, 2, N)
    for i = 1:N
        printargs[1,i] = :(show(io, $(component[i])(c)))
        chr = i < N ? ',' : ')'
        printargs[2,i] = :(print(io, $chr))
    end
    @eval begin
        function show_paint{T}(io::IO, ::Type{Paint{T,$N}}, c)
            print(io, paint_string(typeof(c)), "{", T, "}(")
            $(printargs[:]...)
        end
    end
    for i = 1:N
        printargs[1,i] = :(showcompact(io, $(component[i])(c)))
    end
    @eval begin
        function showcompact_paint{T}(io::IO, ::Type{Paint{T,$N}}, c)
            print(io, paint_string(typeof(c)), "{", T, "}(")
            $(printargs[:]...)
        end
        # Special handling for Ufixed types: don't print the giant type name
        function show_paint_ufixed{T,f}(io::IO, ::Type{Paint{FixedPointNumbers.UfixedBase{T,f},$N}}, c)
            print(io, paint_string(typeof(c)), "{Ufixed", f, "}(")
            $(printargs[:]...)
        end
        function show_paint_ufixed(io::IO, ::Type{Paint{U8,$N}}, c)
            print(io, paint_string(typeof(c)), "{U8}(")
            $(printargs[:]...)
        end
    end
end
