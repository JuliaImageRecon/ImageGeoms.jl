# runtests.jl

using Test: @test, @testset, detect_ambiguities
using ImageGeoms

include("helper.jl")

include("core.jl")
include("imresize.jl")
include("makemask.jl")
include("mask.jl")
include("jim.jl")
#include("property.jl")

@testset "ImageGeoms" begin
    @test isempty(detect_ambiguities(ImageGeoms))
end
