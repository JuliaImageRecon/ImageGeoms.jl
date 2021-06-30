# runtests.jl

using Test: @test, @testset, detect_ambiguities
using ImageGeoms

macro isplot(ex) # @isplot macro to streamline tests
    :(@test $(esc(ex)) isa Plots.Plot)
end

@testset "ImageGeoms" begin
    include("image-geom.jl")

    @test isempty(detect_ambiguities(ImageGeoms))
end

#include("unit.jl")
