MathTypes{T,C} = Union{AbstractRGB{T},TransparentRGB{C,T},AbstractGray{T},TransparentGray{C,T}}

# provided by https://github.com/JuliaLang/julia/pull/35094
function register_hints()
    if isdefined(Base, :Experimental) && isdefined(Base.Experimental, :register_error_hint)
        Base.Experimental.register_error_hint(MethodError) do io, exc, argtypes, kwargs
            # In theory we could list every function supported by ColorVectorSpace.
            # This list of functions is far from comprehensive but may be enough to catch many users.
            if exc.f in (+, -, /) && any(T->T<:MathTypes || T<:Type{<:MathTypes}, argtypes)
                print(io, "\nMath on colors is deliberately undefined in ColorTypes, but see the ColorVectorSpace package.")
            end
            if (exc.f === *) && any(T->T<:MathTypes || T<:Type{<:MathTypes}, argtypes)
                print(io, "\nMath on colors is deliberately undefined in ColorTypes, but see the ColorVectorSpace package.\nYou may also need `⋅`, `⊙`, or `⊗`.")
            end
            if exc.f === one
                if argtypes[1] <: Colorant
                    print(io, "\nDo you mean `oneunit(c)`?")
                elseif argtypes[1] <: Type{<:Colorant}
                    T = argtypes[1].parameters[1]
                    print(io, "\nDo you mean `oneunit($T)`? Or, if calling `ones`, `fill(oneunit($T), ...)`?")
                end
            end
        end
    end
end
