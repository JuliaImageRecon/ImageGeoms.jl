#=
"""
    ig = image_geom(...)

OBSOLETE
Constructor for `ImageGeom`, where `dx,dy,dz` and `fov` and `fovz` may have units

# Arguments
- `nx::Int = 128`
- `ny::Int = nx`
- `dx::RealU = ?` (must specify one of `dx` or `fov`)
- `dy::RealU = -dx`
- `offset_x::Real = 0` (unitless)
- `offset_y::Real = 0` (unitless)
- `fov::RealU = ?` (if specified, then `nx*dx=ny*dy`)
- `nz::Int = 0`
- `dz::RealU = ?` (need one of `dz` or `zfov` if `nz > 0`)
- `zfov::RealU = ?` (if specified, then `nz*dz`)
- `offset_z::Real = 0` (unitless)
- `offsets::Symbol = :none` or :dsp
- `mask::Union{Symbol,AbstractArray{Bool}} = :all` | `:circ` | `:all_but_edge_xy`
"""
function image_geom( ;
    nx::Int = 128,
    ny::Int = nx,
    dx::RealU = NaN,
    dy::RealU = NaN,
    offset_x::Real = 0,
    offset_y::Real = 0,
    fov::RealU = NaN,
    nz::Int = 0,
    dz::RealU = NaN,
    zfov::RealU = NaN,
    offset_z::Real = 0,
    offsets::Symbol = :none,
    mask::Union{Symbol,AbstractArray{Bool}}    = :all,
)

    # handle optional arguments

    is3 = !isnan(dz) || !isnan(zfov) || (nz > 0)

    # offsets
    if offsets === :dsp
        # check that no nonzero offset was specified
        (offset_x != 0 || offset_y != 0) && throw("offsets usage incorrect")
        offset_x = 0.5
        offset_y = 0.5
        if is3
            offset_z != 0 && throw("offset_z usage incorrect")
            offset_z = 0.5
        end
    elseif offsets != :none
        throw("offsets $offsets")
    end

    # transverse plane (2d) distances
    if true
        if isnan(fov)
            isnan(dx) && throw("dx or fov required")
        #    fov = nx * dx
        else
            !isnan(dx) && throw("dx and fov?")
            dx = fov / nx
            dy = fov / ny
        end

        dy = isnan(dy) ? -dx : dy # default dy
    end

    # 3D geometry
    if is3
        if isnan(zfov)
            isnan(dz) && throw("dz or zfov required")
        #    zfov = nz * dz
        else
            !isnan(dz) && throw("dz and zfov?")
            dz = zfov / nz
        end
    end

    # mask
    if mask === :all
        mask = is3 ? Trues(nx, ny, nz) : Trues(nx, ny)
    elseif mask === :circ
        mask = image_geom_circle(nx, ny, dx, dy)
        if nz > 0
            mask = repeat(mask, 1, 1, nz)
        end
    elseif mask === :all_but_edge_xy
        mask = trues(nx,ny,max(nz,1))
        mask[  1,   :, :] .= false
        mask[end,   :, :] .= false
        mask[  :,   1, :] .= false
        mask[  :, end, :] .= false
        if !is3
            mask = mask[:,:,1]
        end
    elseif isa(mask, Symbol)
        throw("mask symbol $mask")
    elseif size(mask,1) != nx || size(mask,2) != ny || (is3 && size(mask,3) != nz)
        throw("mask size $(size(mask)), nx=$nx ny=$ny nz=$nz")
    end

    # return the object (type unstable, but used rarely so ok)
    return is3 ?
        ImageGeom((nx, ny, nz), (dx, dy, dz),
            (offset_x, offset_y, offset_z), mask) :
        ImageGeom((nx, ny), (dx, dy),
            (offset_x, offset_y), mask)
end
=#
