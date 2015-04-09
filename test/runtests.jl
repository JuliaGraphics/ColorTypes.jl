using ColorTypes
using Base.Test

#very simple first test
b =  [0.2, 0.2, 0.3]
a = RGB(b)
@test a+a == RGB(0.4, 0.4, 0.6)
mul = a.*a
mulj = b.*b
for i=1:3
	@test isapprox(mul[i], mulj[i])
end
s = sin(a)
sj = RGB(sin(b))
for i=1:3
	@test isapprox(s[i], sj[i])
end

@test eltype(a) == Float64
@test size(a) == (3,)
@test ndims(a) == 1
@test length(a) == 3

@test a[1] == 0.2
@test a.r == 0.2

b = typeof(a)
@test eltype(b) == Float64
@test size(b) == (3,)
@test ndims(b) == 1
@test length(b) == 3

