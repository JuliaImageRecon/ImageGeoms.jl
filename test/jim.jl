# jim.jl

using ImageGeoms
using MIRTjim: jim
using Plots: Plot
using Unitful: m

using Test: @test, @testset, @test_throws, @inferred

@testset "jim" begin
    arg1 = ((2,), (3m,), (0,))
    arg2 = ((2,3), (3m,4.), (0,1))
    arg3 = ((2,3,4), (3m,4.,1//2), (0,2//3,2.))

    ig1 = @inferred ImageGeom(arg1...)#, trues(arg1[1]...))
    ig2 = @inferred ImageGeom(arg2...)#, trues(arg2[1]...))
    ig3 = @inferred ImageGeom(arg3...)#, trues(arg3[1]...))

    @test_throws String jim(ig1)
    @test jim(ig2) isa Plot
    @test jim(ig3) isa Plot
end
