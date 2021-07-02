# makemask.jl

using ImageGeoms
#include("../src/makemask.jl")

using Test: @test, @testset, @test_throws, @inferred

@testset "makemask" begin
    @test MaskAll <: Mask
    @test MaskCircle <: Mask
    @test MaskEllipse <: Mask
    @test MaskAllButEdge <: Mask

    i2 = ImageGeom( dims=(3,4) )
    i3 = ImageGeom( dims=(3,4,5) )

    m = @inferred makemask(i2, MaskAll())
    @test m == trues(i2)

    m = @inferred makemask(i3, MaskAll())
    @test m == trues(i3)

    m = @inferred makemask(i2, MaskAllButEdge())
    @test m == Bool[0 0 0 0; 0 1 1 0; 0 0 0 0]

    m = @inferred makemask(i3, MaskAllButEdge())
    @test sum(m) == 2 * size(i3,3)

    i2 = ImageGeom( dims=(8,6) )
    i3 = ImageGeom( dims=(8,6,4) )

    m2 = @inferred makemask(i2, MaskCircle())
    @test sum(m2) == 12

    m3 = @inferred makemask(i3, MaskCircle())
    @test sum(m3) == 12 * size(i3,3)
    @test m3[:,:,end] == m2

    m2 = @inferred makemask(i2, MaskEllipse())
    @test sum(m2) == 20

    m3 = @inferred makemask(i3, MaskEllipse())
    @test sum(m3) == 20 * size(i3,3)

    i1 = ImageGeom( dims=(8,) )
    @test_throws MethodError makemask(i1, MaskAllButEdge())

    i2 = @inferred ImageGeom( MaskCircle() ; dims=(8,6) )
    @test i2.mask == makemask(i2, MaskCircle())
end
