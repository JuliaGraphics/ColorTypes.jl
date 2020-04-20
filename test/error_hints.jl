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
    @testset "one/ones" begin
        for T in (RGB, RGB{N0f8})
            err_str = @except_str one(T) MethodError
            @test occursin(r"MethodError: no method matching one\(::Type\{RGB.*\}", err_str)
            @test occursin("Do you mean `oneunit", err_str)

            err_str = @except_str one(T(1, 1, 1)) MethodError
            @test occursin(r"MethodError: no method matching one\(::RGB\{.*\}", err_str)
            @test occursin("Do you mean `oneunit(c)`?", err_str)

            err_str = @except_str ones(T) MethodError
            @test occursin(r"MethodError: no method matching one\(::Type\{RGB.*\}", err_str)
            @test occursin("Do you mean `oneunit", err_str)
            @test occursin("fill(oneunit", err_str)
        end
    end

    @testset "Math" begin
        x = Gray(0.8)
        err_str = @except_str x + x MethodError
        @test occursin("no method matching +(::Gray{Float64}, ::Gray{Float64})", err_str)
        @test occursin("Math on colors is deliberately undefined in ColorTypes, but see the ColorVectorSpace package", err_str)
    end
end
