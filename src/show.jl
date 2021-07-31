
function show(io::IO, c::Colorant)
    if get(io, :typeinfo, Any) === typeof(c)
        print(io, colorant_string(typeof(c)))
    else
        show_colorant_string_with_eltype(io, typeof(c))
    end
    _show_components(io, c)
end

function show(io::IO, c::AbstractGray)
    if get(io, :typeinfo, Any) === typeof(c)
        show(_components_iocontext(io, c), comp1(c))
    else
        show_colorant_string_with_eltype(io, typeof(c))
        _show_components(io, c)
    end
end

function show(io::IO, c::AbstractGray{Bool})
    if get(io, :typeinfo, Any) === typeof(c)
        print(io, gray(c) ? '1' : '0')
    else
        show_colorant_string_with_eltype(io, typeof(c))
        print(io, gray(c) ? "(1)" : "(0)")
    end
end


@inline function _components_iocontext(io::IO, c::Colorant{T}) where T
    if typeof(c) === base_colorant_type(c)
        # For non-parametric colors, we do not set :typeinfo since they do not
        # explicitly show their element type. Therefore, the suffix "N0f8" is
        # displayed in RGB24 etc. unless :compact=>true.
        return io
    elseif T === Float64
        return io
    elseif T <: FixedPoint # workaround for FPN v0.8 or earlier
        return IOContext(io, :typeinfo => T, :compact => true)
    else
        return IOContext(io, :typeinfo => T)
    end
end

function _show_components(io::IO, c::Colorant{T, N}) where {T, N}
    io = _components_iocontext(io, c)
    print(io, '(')
    for i = 1:N
        show(io, comps(c)[i])
        print(io, i < N ? ", " : ")")
    end
end

if VERSION < v"1.6.0-DEV.356" # JuliaLang/julia#36107
    function Base.showarg(io::IO, a::Array{C}, toplevel) where C<:Colorant
        toplevel || print(io, "::")
        print(io, "Array{")
        show_colorant_string_with_eltype(io, C)
        print(io, ',', ndims(a), '}')
        is_parametric_fixed = C <: Colorant{<:FixedPoint} && !isempty(C.parameters)
        toplevel && is_parametric_fixed && print(io, " with eltype ", C)
    end
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
