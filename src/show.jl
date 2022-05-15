
function show(io::IO, c::Colorant)
    show_colorant_string_with_eltype(io, typeof(c))
    _show_components(io, c)
end

# Special handling for Normed types: don't print the giant type name
function show(io::IO, c::ColorantNormed)
    show_colorant_string_with_eltype(io, typeof(c))
    if typeof(c) === base_colorant_type(typeof(c)) # non-parametric
        _show_components(io, c) # with trailing "N0f8" unless :compat=>true
    else
        _show_components(IOContext(io, :compact=>true), c)
    end
end

function _show_components(io::IO, c::Colorant{T,N}) where {T, N}
    print(io, '(')
    for i = 1:N
        i == 1 && show(io, comp1(c))
        i == 2 && show(io, comp2(c))
        i == 3 && show(io, comp3(c))
        i == 4 && show(io, comp4(c))
        i == 5 && show(io, comp5(c))
        print(io, i < N ? ',' : ')') # without spaces
    end
end

function Base.showarg(io::IO, a::Array{C}, toplevel) where C<:Colorant
    toplevel || print(io, "::")
    print(io, "Array{")
    show_colorant_string_with_eltype(io, C)
    print(io, ",$(ndims(a))}")
    toplevel && print(io, " with eltype ", C)
end


colorant_string(::Type{Union{}}) = "Union{}"
colorant_string(::Type{C}) where {C<:Colorant} = string(nameof(C))
function colorant_string_with_eltype(::Type{C}) where {C<:Colorant}
    io = IOBuffer()
    show_colorant_string_with_eltype(io, C)
    String(take!(io))
end

# for backward compatibility (Some other packages use this method.)
colorant_string_with_eltype(io::IO, ::Type{C}) where {C<:Colorant} =
    show_colorant_string_with_eltype(io, C)

show_colorant_string_with_eltype(io::IO, ::Type{Union{}}) = show(io, Union{})
function show_colorant_string_with_eltype(io::IO, ::Type{C}) where {C<:Colorant}
    if !isconcretetype(C)
        get(io, :compact, false) && return show(io, C)
        show(IOContext(io, :compact => true), C) # w/o module names
    elseif C === base_colorant_type(C) # non-parametric
        print(io, nameof(C))
    else
        print(io, nameof(C))
        print(io, '{')
        showcoloranttype(io, eltype(C))
        print(io, '}')
    end
end

showcoloranttype(io, ::Type{Union{}}) = show(io, Union{})
showcoloranttype(io, ::Type{T}) where {T<:FixedPoint} = FixedPointNumbers.showtype(io, T)
showcoloranttype(io, ::Type{T}) where {T} = show(io, T)
