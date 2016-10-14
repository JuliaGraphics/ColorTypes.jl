show(io::IO, c::Colorant)              = _show(io, c)
show(io::IO, c::ColorantUFixed)        = show_ufixed(io, c)
showcompact(io::IO, c::Colorant)       = _showcompact(io, c)
showcompact(io::IO, c::ColorantUFixed) = show_ufixed(io, c)

for N = 1:4
    component = N >= 3 ? (:comp1, :comp2, :comp3, :alpha) : (:comp1, :alpha)
    printargs = Array(Any, 2, N)
    for i = 1:N
        printargs[1,i] = :(show(io, $(component[i])(c)))
        chr = i < N ? ',' : ')'
        printargs[2,i] = :(print(io, $chr))
    end
    @eval begin
        function _show{T}(io::IO, c::Colorant{T,$N})
            print(io, colorant_string(typeof(c)), "{", T, "}(")
            $(printargs[:]...)
        end
    end
    for i = 1:N
        printargs[1,i] = :(showcompact(io, $(component[i])(c)))
    end
    @eval begin
        function _showcompact{T}(io::IO, c::Colorant{T,$N})
            print(io, colorant_string(typeof(c)), "{", T, "}(")
            $(printargs[:]...)
        end
        # Special handling for UFixed types: don't print the giant type name
        function show_ufixed{T,f}(io::IO, c::Colorant{FixedPointNumbers.UFixed{T,f},$N})
            print(io, colorant_string(typeof(c)), '{')
            FixedPointNumbers.showtype(io, eltype(typeof(c)))
            print(io, "}(")
            $(printargs[:]...)
        end
    end
end
