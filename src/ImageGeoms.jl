module ImageGeoms

const RealU = Number # Union{Real, Unitful.Length}

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

end # module
