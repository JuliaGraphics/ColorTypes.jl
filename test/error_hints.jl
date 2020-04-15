macro except_str(expr, err_type)
    return quote
        let err = nothing
            try
                $(esc(expr))
            catch err
            end
            err === nothing && error("expected failure, but no exception thrown")
            @test typeof(err) === $(esc(err_type))
            buf = IOBuffer()
            showerror(buf, err)
            String(take!(buf))
        end
    end
end

@testset "error hints" begin
    @testset "zeros/ones" begin
        for T in (RGB, RGB{N0f8})
            err_str = @except_str zero(T) MethodError
            @test occursin(r"MethodError: no method matching zero\(::Type\{RGB.*\}", err_str)
            @test occursin("You may need to `using ColorVectorSpace`.", err_str)

            err_str = @except_str zero(T(1, 1, 1)) MethodError
            @test occursin(r"MethodError: no method matching zero\(::RGB\{.*\}", err_str)
            @test occursin("You may need to `using ColorVectorSpace`.", err_str)

            err_str = @except_str zeros(T) MethodError
            @test occursin(r"MethodError: no method matching zero\(::Type\{RGB.*\}", err_str)
            @test occursin("You may need to `using ColorVectorSpace`.", err_str)

            err_str = @except_str one(T) MethodError
            @test occursin(r"MethodError: no method matching one\(::Type\{RGB.*\}", err_str)
            @test occursin("You may need to `using ColorVectorSpace`.", err_str)

            err_str = @except_str one(T(1, 1, 1)) MethodError
            @test occursin(r"MethodError: no method matching one\(::RGB\{.*\}", err_str)
            @test occursin("You may need to `using ColorVectorSpace`.", err_str)

            err_str = @except_str ones(T) MethodError
            @test occursin(r"MethodError: no method matching one\(::Type\{RGB.*\}", err_str)
            @test occursin("You may need to `using ColorVectorSpace`.", err_str)
        end
    end
end
