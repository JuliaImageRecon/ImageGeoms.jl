#=
makemask.jl
methods relating to forming mask/support array
=#

export makemask, circle, ellipse
#using ImageGeoms: ImageGeom, Mask*

makemask(ig::ImageGeom, ::MaskAll) = trues(ig)
makemask(ig::ImageGeom, ::MaskCircle) = circle(ig)
makemask(ig::ImageGeom, ::MaskEllipse) = ellipse(ig)
makemask(ig::ImageGeom, ::MaskAllButEdge) = all_but_edge(ig)


"""
    ellipse(ig::ImageGeom{2} ; ...)
Ellipse that just inscribes the rectangle,
but keeping a 1 pixel border due to some regularizer limitations.
"""
function ellipse(ig::ImageGeom{2} ;
    dx::RealU = ig.deltas[1],
    dy::RealU = ig.deltas[2],
    rx::RealU = abs((ig.dims[1]/2-1)*dx),
    ry::RealU = abs((ig.dims[2]/2-1)*dy),
    cx::RealU = zero(dx),
    cy::RealU = zero(dy),
#   over::Int=2,
)

    x,y = axes(ig)
    fun = (x,y) -> ((x - cx) / rx)^2 + ((y - cy) / ry)^2 < 1
    return fun.(x, y')
end

function ellipse(ig::ImageGeom{3} ; kwargs...)
    i2 = ImageGeom(ig.dims[1:2], ig.deltas[1:2], ig.offsets[1:2])
    return repeat(ellipse(i2 ; kwargs...), 1, 1, ig.dims[3])
end


# default is a circle that just inscribes the square
# but keeping a 1 pixel border due to ASPIRE regularization restriction
function circle(ig::ImageGeom{2} ;
    rx::RealU = abs((ig.dims[1]/2-1)*ig.deltas[1]),
    ry::RealU = abs((ig.dims[2]/2-1)*ig.deltas[2]),
    r::RealU = min(rx,ry),
    kwargs...,
#   over::Int=2,
)
    return ellipse(ig ; rx=r, ry=r, kwargs...)
end

function circle(ig::ImageGeom{3} ; kwargs...)
    i2 = ImageGeom(ig.dims[1:2], ig.deltas[1:2], ig.offsets[1:2])
    return repeat(circle(i2 ; kwargs...), 1, 1, ig.dims[3])
end

function all_but_edge(ig::ImageGeom{2})
    mask = trues(ig.dims)
    mask[  1,   :] .= false
    mask[end,   :] .= false
    mask[  :,   1] .= false
    mask[  :, end] .= false
    return mask
end

function all_but_edge(ig::ImageGeom{3})
    i2 = ImageGeom( dims=ig.dims[1:2] )
    return repeat(all_but_edge(i2), 1, 1, ig.dims[3])
end
