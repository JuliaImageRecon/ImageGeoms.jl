# imresize.jl

using ImageGeoms: downsample, downsample!
using ImageGeoms: upsample, upsample!
#include("../src/imresize.jl")

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
    y = @inferred downsample(x, (2,2))
    @test y == trues(3, 4)

    x = ones(Bool, 6, 7)
    y = @inferred downsample(x, (2,2))
    @test y == trues(3, 4)

    x = Bool[0 0 0 0 0; 0 1 1 0 0; 0 1 0 0 0; 0 0 0 0 0]
    y = @inferred downsample(x, (2,2))
    @test y == Bool[1 1 0; 1 0 0]

    x = ones(Bool, 6, 7)
    y = falses(2,2)
    @test_throws DimensionMismatch downsample!(y, x, (2,2))
end

@testset "upsample" begin
    x = trues(2, 3)
    y = @inferred upsample(x, (5,4))
    @test y == trues(10, 12)

    x = Bool[1 0 1; 0 1 0]
    y = @inferred upsample(x, (2,2))
    @test y == Bool[1 1 0 0 1 1; 1 1 0 0 1 1; 0 0 1 1 0 0; 0 0 1 1 0 0]

    x = ones(Bool, 2, 3)
    y = @inferred upsample(x, (4,1))
    @test y == trues(8, 3)

    @test_throws DimensionMismatch upsample!(y, x, (2,2))
end
