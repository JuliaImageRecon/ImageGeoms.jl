# core.jl

using ImageGeoms
using FillArrays: Trues
using Unitful: m

using Test: @test, @testset, @test_throws, @inferred

@testset "construct" begin
    ig = @inferred ImageGeom()
    @test ig isa ImageGeom

    arg1 = ((2,), (3,), (0,))
    arg2 = ((2,3), (3m,4.), (0,1))
    arg3 = ((2,3,4), (3m,4.,1//2), (0,2//3,2.))

    ig1 = @inferred ImageGeom(arg1..., trues(arg1[1]...))
    ig2 = @inferred ImageGeom(arg2..., trues(arg2[1]...))
    ig3 = @inferred ImageGeom(arg3..., trues(arg3[1]...))
    @test ig3 isa ImageGeom

    ig1 = @inferred ImageGeom(arg1...)
    ig2 = @inferred ImageGeom(arg2...)
    ig3 = @inferred ImageGeom(arg3...)
    @test ig3 isa ImageGeom

    ig3a = @inferred ImageGeom(arg3..., Trues(arg3[1]))
    ig3b = @inferred ImageGeom(dims=arg3[1], deltas=arg3[2], offsets=arg3[3])
    ig3c = @inferred ImageGeom(dims=arg3[1], deltas=arg3[2], offsets=arg3[3],
        mask=Trues(arg3[1]))
    @test ig3a == ig3b == ig3c

    # components
    @test ig3.dims == arg3[1]
    @test ig3.deltas == arg3[2]
    @test all(ig3.offsets .≈ arg3[3])
    @test ig3.mask == Trues(ig3.dims)

    ig = @inferred ImageGeom((2,3), (3m,4.), :dsp)
    ig = @inferred ImageGeom(dims=(2,3), deltas=(3m,4.), offsets=:dsp)
    @test ig.offsets == (0.5, 0)

    ig = @inferred ImageGeom( ; dims=(2,3), fovs=(3m,4.))

    ig = @inferred ImageGeom(dims=(2,3), fov=12)
    @test ig.deltas == (6, 4)
end

@testset "methods" begin
    dims = (6,8)
    ig = @inferred ImageGeom(; dims)

    show(isinteractive() ? stdout : devnull, ig)
    show(isinteractive() ? stdout : devnull, MIME("text/plain"), ig)

    for f in (zeros, ones, falses, trues)
        @test f(ig.dims) == (@inferred f(ig))
    end
    @test ndims(ig) == 2
    @test size(ig) == dims
    @test size(ig,1) == dims[1]
    @test fovs(ig) isa Tuple

    # _zero tests
#   @test zero(ImageGeom((2,3), (3.0,4.0), (0,0))) === zero(Float64)
#   @test zero(ImageGeom((2,3), (3.0,4.0f0), (0,0))) === zero(Float32)
#   @test zero(ImageGeom((2,3), (3m,4.0), (0,0))) === zero(Int32) # alert
#   @test zero(ImageGeom((2,3), (3.0m,4.0m), (0,0))) === zero(0.0m)

    ig_down = @inferred downsample(ig, (2,2))
    ig_over = @inferred oversample(ig_down, (2,2))
    @test ig_over == ig

    i3 = @inferred ImageGeom(MaskAllButEdge(); dims=(8,6,4))
    i3 = @inferred ImageGeom(MaskCircle(); dims=(8,6,4))
    i3_down = @inferred downsample(i3, 2)
    i3_over = @inferred oversample(i3_down, 2)
    @test i3_over.dims == i3.dims
    @test i3_over.deltas == i3.deltas
    @test i3_over.offsets == i3.offsets
    @test all(i3_over.mask[i3.mask])

    i3a = @inferred ImageGeom( dims=(2,3,4) )
    i3z = @inferred expand_nz(i3a, 1)
    @test size(i3z,3) == size(i3a,3) + 2

    i3z = @inferred expand_nz(i3, 4)
    @test size(i3z,3) == size(i3,3) + 8

    @test (@inferred axes(i3)) isa Tuple
    @test axis(i3, 2) isa StepRangeLen
    @test (@inferred grids(i3)) isa Tuple

    @test axisf(i3, 2) isa StepRangeLen
    @test (@inferred axesf(i3)) isa Tuple
    @test (@inferred gridf(i3)) isa Tuple
end


@testset "down" begin
    dims = (6,3)
    ig = @inferred ImageGeom(; dims)
    @test_throws String downsample(ig, (2,4))
end
