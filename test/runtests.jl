# runtests.jl

using Test: @test, @testset, detect_ambiguities
using ImageGeoms

include("core.jl")
include("imresize.jl")
include("makemask.jl")
include("mask.jl")
#include("property.jl")

@testset "ImageGeoms" begin
    @test isempty(detect_ambiguities(ImageGeoms))
end
