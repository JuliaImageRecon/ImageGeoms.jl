# runtests.jl

using Test: @test, @testset, detect_ambiguities
using ImageGeoms

include("imresize.jl")
include("ndgrid.jl")
include("makemask.jl")
include("mask.jl")

@testset "ImageGeoms" begin
    include("core.jl")

    @test isempty(detect_ambiguities(ImageGeoms))
end
