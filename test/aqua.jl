using ImageGeoms
import Aqua
using Test: @testset

@testset "aqua" begin
    # todo: ambiguities in FillArrays
    Aqua.test_all(ImageGeoms, ambiguities=false)
end
