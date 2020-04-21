
function show(io::IO, c::Colorant)
    show_colorant_string_with_eltype(io, typeof(c))
    _show_components(io, c)
end

# Special handling for Normed types: don't print the giant type name
function show(io::IO, c::ColorantNormed)
    show_colorant_string_with_eltype(io, typeof(c))
    if isempty(typeof(c).parameters) # Nonparametric types
        _show_components(io, c) # with trailing "N0f8" unless :compat=>true
    else
        _show_components(IOContext(io, :compact=>true), c)
    end
end

function _show_components(io::IO, c::ColorantN{N}) where N
    comp_n = (comp1, comp2, comp3, comp4, comp5)
    print(io, '(')
    for i = 1:N
        show(io, (comp_n[i])(c))
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

show_colorant_string_with_eltype(io::IO, ::Type{Union{}}) = show(io, Union{})
function show_colorant_string_with_eltype(io::IO, ::Type{C}) where {C<:Colorant}
    if !isconcretetype(C) || isempty(C.parameters)
        print(io, C)
    else
        print(io, colorant_string(C))
        print(io, '{')
        showcoloranttype(io, eltype(C))
        print(io, '}')
    end
end

showcoloranttype(io, ::Type{Union{}}) = show(io, Union{})
showcoloranttype(io, ::Type{T}) where {T<:FixedPoint} = FixedPointNumbers.showtype(io, T)
showcoloranttype(io, ::Type{T}) where {T} = show(io, T)
