# ndgrid.jl
# test lazy and non-lazy version

using ImageGeoms: ndgrid, ndgrid_lazy, ndgrid_repeat
#include("../src/ndgrid.jl")

using Test: @test, @testset, @test_throws, @inferred

@testset "ndgrid" begin
    xg, yg, zg = @inferred ndgrid(1:4, 5:7, 8:9)
    @test xg == repeat(1:4, 1, 3, 2)
    @test yg == repeat((5:7)', 4, 1, 2)

    x = 1:4
    y = [1//2, 3//4]
    z = [:a, :b, :c]

    @inferred ndgrid(x, y) # compiler figures it out,
    @inferred ndgrid(x, z) # surprisingly

    @test_throws ArgumentError ndgrid_repeat(x, (4,2,3), 0)
    @test_throws DimensionMismatch ndgrid_repeat(x, (4,2,3), 2)

    @inferred ndgrid_repeat(x, (4,2,3), 1)
    @inferred ndgrid_repeat(y, (4,2,3), 2)
    @inferred ndgrid_repeat(z, (4,2,3), 3)
#   xg, yg, zg = @inferred ndgrid(x, y, z) # @inferred fails here
    xg, yg, zg = ndgrid(x, y, z)
    @test zg == repeat(reshape(z, (1,1,3)), 4, 2, 1)
end

@testset "ndgrid_lazy" begin
    x = 1:4
    y = [1//2, 3//4]
    z = [:a, :b, :c]
    a = ndgrid(x, y)
    b = @inferred ndgrid_lazy(x, y)
    @test a == b
    a = ndgrid(x, y, z)
#   b = @inferred ndgrid_lazy(x, y, z) # @inferred fails here
    b = ndgrid_lazy(x, y, z)
    @test a == b

    # indexing
    (xn, _, _) = ndgrid(x, y, z)
    (xl, _, _) = ndgrid_lazy(x, y, z)

    @test xn == xl
    @test xn[3] == xl[3]
    @test xn[3] == xl[3]
    @test xn[:] == xl[:]
    @test size(xn) == size(xl)
    @test ndims(xn) == ndims(xl)
    @test xl isa AbstractArray
end

#=
@which getindex(xn, 3) # calls Base
@which getindex(xl, 1, 1, 1) # calls specialize getindex
=#

#=
# uncomment this block for timing comparisons

f = x -> x^2
    x = 1:2^8
    y = 1:2^9
    z = 1:2^4
    (xn, _, _) = ndgrid(x, y, z)
    (xl, _, _) = ndgrid_lazy(x, y, z)
@assert sum(f, xl) ≈ sum(f, xn)

using BenchmarkTools
@btime sum($f, $xn) # 0.8 ms
@btime sum($f, $xl) # 4.3 ms (much slower, but less memory...)
=#
