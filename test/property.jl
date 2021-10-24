# tests for properties

using ImageGeoms
using FillArrays: Trues, Falses, Zeros, Ones
using Test: @test, @testset, @test_throws, @inferred

# test 2D properties
function image_geom_test2(ig::ImageGeom)
    @test ig.dims isa Tuple
    @test ig.deltas isa Tuple
    @test ig.offsets isa Tuple

    @test ig.dim isa Tuple
    @test ig.x isa AbstractVector
    @test ig.y isa AbstractVector
    @test ig.wx isa Number
    @test ig.wy isa Number
    @test ig.xg isa AbstractArray
    @test ig.yg isa AbstractArray
    @test ig.fovs isa Tuple
    @test ig.np isa Int
#   ig.mask_outline
    @test ig.ones isa Ones
    @test ig.zeros isa Zeros
    @test ig.u isa AbstractVector
    @test ig.v isa AbstractVector
    @test ig.ug isa AbstractArray
    @test ig.vg isa AbstractArray
#   ig.fg

    @test ig.shape(vec(ig.ones)) == ig.ones
    @test ig.embed(ig.ones[ig.mask]) == ig.mask
    @test ig.maskit(ig.ones) == ones(ig.np)
#   @inferred # todo
    @inferred ig.unitv()
    ig.unitv(j=4)
    ig.unitv(i=ntuple(i->1, length(ig.dim)))
    ig.unitv(c=ntuple(i->0, length(ig.dim)))
#= todo-i: why do these fail?
    @inferred image_geom_ellipse(8, 10, 1, 2)
    @inferred ig.circ()
    @inferred ig.plot()
    @inferred ig.unitv()
=#
    ig.circ()
    how = (args...; kw...) -> args[1] # trick to avoid Plots
    ig.plot(how)
    ig.unitv()
#= todo-i:
    @inferred ig.down(2)
    @inferred ig.over(2)
=#
    @test ig.down(2) isa ImageGeom
    @test ig.over(2) isa ImageGeom
#   image_geom_ellipse(8, 10, 1, 2)
    true
end


function image_geom_test2()
    #@inferred
#   image_geom(nx=16, dx=2, offsets=:dsp, mask=:all_but_edge_xy)
#   @test_throws String image_geom(nx=16, dx=1, offsets=:bad)
#   @test_throws String image_geom(nx=16, dx=1, mask=:bad) # mask type
#   @test_throws String image_geom(nx=16, dx=1, mask=trues(2,2)) # mask size
    ig = ImageGeom(MaskAll(); dims=(9,8), deltas=(2,2))
    image_geom_test2(ig) # todo: fails at embed
    ig = ImageGeom(MaskCircle(); dims=(9,8), deltas=(2,2))
    image_geom_test2(ig)
    ig.over(2)
    ig.down(3) # test both even and non-even factors
    ig.help
    true
end


function image_geom_test3(ig::ImageGeom{3})
    @test image_geom_test2(ig)
    ig.wz
    ig.zg
    ig.mask_or
    @inferred ig.expand_nz(2)
#   @inferred cbct(ig)
#   @test_throws String image_geom(nx=1, dx=1, nz=2, offset_z=-1, offsets=:dsp)
    true
end


function image_geom_test3()
    ig = @inferred ImageGeom( dims = (9,8,4) )
    image_geom_test3(ig)
    true
end


@testset "2d" begin
    @test all(ImageGeom((2,), (3,), (0,)).mask)
    @test image_geom_test2()
end

@testset "3d" begin
    @test image_geom_test3()
end
