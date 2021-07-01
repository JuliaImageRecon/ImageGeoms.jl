# runtests.jl

using Test: @test, @testset, detect_ambiguities
using ImageGeoms

macro isplot(ex) # @isplot macro to streamline tests
    :(@test $(esc(ex)) isa Plots.Plot)
end

include("imresize.jl")

@testset "ImageGeoms" begin
    include("image-geom.jl")

    @test isempty(detect_ambiguities(ImageGeoms))
end
