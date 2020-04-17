# provided by https://github.com/JuliaLang/julia/pull/35094
function register_hints()
    if VERSION >= v"1.5.0-DEV.491"
        register_error_hint(MethodError) do io, exc, argtypes, kwargs
            if exc.f in (zero, one) && argtypes[1] <: Union{Type{<:AbstractRGB}, AbstractRGB}
                print(io, "\nYou may need to `using ColorVectorSpace`.")
            end
            if exc.f in (zeros, ones) && argtypes[1] <: Type{<:AbstractRGB}
                print(io, "\nYou may need to `using ColorVectorSpace`.")
            end
        end
    end
end
