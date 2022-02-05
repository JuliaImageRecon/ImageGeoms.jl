# jim.jl

#using .MIRTjim: jim
import .MIRTjim: jim

#using ImageGeoms: ImageGeom


"""
    jim(ig ; kwargs...)
Display the support mask
"""
jim(ig::ImageGeom{2} ; kwargs...) =
    jim(axes(ig)..., ig.mask; title = "(nx,ny)=$(ig.dims)", kwargs...)
jim(ig::ImageGeom{3} ; kwargs...) =
    jim(axis(ig,1), axis(ig,2), mask_or(ig.mask) ;
        title = "(dx,dy,dz)=$(ig.deltas)", kwargs...)
jim(ig::ImageGeom ; kwargs...) = throw("unsupported $(typeof(ig))")
