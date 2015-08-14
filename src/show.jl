macro make_show(have_fixed, P, fields)
    fields = fields.args
    Pstr = paint_string(P)
    Pesc = esc(P)
    objfields = Array(Expr, length(fields))
    for i = 1:length(fields)
        if isa(fields[i], Expr)
            sym = fields[i].args[2].args[1]
            objfields[i] = :(c.c.$sym)
        else
            objfields[i] = :(c.$(fields[i]))
        end
    end
    exs = [:(showcompact(io, $(fn))) for fn in objfields]
    exc = [d < length(fields) ? (:(print(io, ','))) : (:(print(io, ')'))) for d = 1:length(fields)]
    exboth = hcat(exs, exc)'
    ex = Expr(:block, exboth...)
    exs = [:(show(io, $(fn))) for fn in objfields]
    exfull = Expr(:block, (hcat(exs, exc)')...)
    ret = quote
        function Base.show{T}(io::IO, c::$Pesc{T})
            print(io, "$($Pstr){$T}(")
            $exfull
        end
        function Base.showcompact{T}(io::IO, c::$Pesc{T})
            print(io, "$($Pstr){$T}(")
            $ex
        end
    end
    if have_fixed
        # Ufixed always print as compact
        ret = quote
            $ret
            function Base.show{T,f}(io::IO, c::$Pesc{FixedPointNumbers.UfixedBase{T,f}})
                print(io, "$($Pstr){Ufixed", f, "}(")
                $ex
            end
            function Base.show(io::IO, c::$Pesc{Ufixed8})
                print(io, "$($Pstr){U8}(")
                $ex
            end
        end
    end
    ret
end

for C in union(parametric, [Gray])
    fixed = eltype_default(C) <: Ufixed
    AC, CA = alphacolor(C), coloralpha(C)
    fn  = fieldnames(C)
    ex  = Expr(:tuple, fn...)
    exa = Expr(:tuple, fn..., :alpha)
    @eval @make_show $fixed $C $ex
    if !(C in (RGB1, RGB4))
        @eval @make_show $fixed $CA $exa
        @eval @make_show $fixed $AC $exa
    end
end
