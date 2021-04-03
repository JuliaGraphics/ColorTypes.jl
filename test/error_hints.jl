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
    @testset "Math" begin
        gray = Gray(0.8)
        rgb = RGB{Float32}(1, 0, 0)
        err_str = @except_str gray + rgb MethodError
        @test occursin("no method matching +(::Gray{Float64}, ::RGB{Float32})", err_str)
        @test occursin("Math on colors is deliberately undefined in ColorTypes, but see the ColorVectorSpace package", err_str)

        err_str = @except_str gray * rgb MethodError
        @test occursin("no method matching *(::Gray{Float64}, ::RGB{Float32})", err_str)
        @test occursin("Math on colors is deliberately undefined in ColorTypes, but see the ColorVectorSpace package", err_str)
        @test occursin("You may also need `⋅`, `⊙`, or `⊗`.", err_str)

        err_str = @except_str rgb * 0.5 MethodError
        @test !occursin("You may also need `⋅`, `⊙`, or `⊗`.", err_str)
    end
end
