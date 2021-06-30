# downsample.jl

using ImageGeoms: downsample
#include("../src/downsample.jl")

using Test: @test, @testset, @test_throws, @inferred


@testset "downsample" begin
    x = trues(6, 8)
    y = @inferred downsample(x, (3,2))
    @test y == trues(2, 4)

    x = ones(Bool, 6, 8)
    y = @inferred downsample(x, (3,2))
    @test y == trues(2, 4)

    x = trues(6, 9)
    z = @view x[1:6,1:8]
    y = @inferred downsample(z, (3,2))
    @test y == trues(2, 4)

    x = trues(6, 8, 10, 5)
    y = @inferred downsample(x, (3,2,5,5))
    @test y == trues(2, 4, 2, 1)

    x = trues(6, 7)
    @test_throws DimensionMismatch downsample(x, (2,2))
end
