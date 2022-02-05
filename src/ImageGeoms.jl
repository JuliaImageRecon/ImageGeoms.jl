"""
    ImageGeoms
Module for describing image geometries.
"""
module ImageGeoms

using Requires: @require

const RealU = Number # Union{Real, Unitful.Length}

"""
    Mask
Abstract type for describing the support of an image
(i.e., which pixels will be reconstructed in solving an inverse problem).
"""
abstract type Mask end
struct MaskAll <: Mask end
struct MaskCircle <: Mask end
struct MaskEllipse <: Mask end
struct MaskAllButEdge <: Mask end

export Mask, MaskAll, MaskCircle, MaskEllipse, MaskAllButEdge

include("core.jl")
include("imresize.jl")
include("makemask.jl")
include("mask.jl")

#include("property.jl") # exclude due to type inference issues

# support MIRTjim iff user has loaded it

function __init__()
    @require MIRTjim = "170b2178-6dee-4cb0-8729-b3e8b57834cc" include("jim.jl")
end

end # module
