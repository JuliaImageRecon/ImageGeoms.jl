using ImageGeoms
import Aqua
using Test: @testset

@testset "aqua" begin
    Aqua.test_all(ImageGeoms)
end
