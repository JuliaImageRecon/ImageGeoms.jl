#=
property.jl
=#

using FillArrays: Zeros
#using ImageGeoms #: [many]


"""
    `ImageGeom` help

## Properties

Access by `ig.key`, mostly for 2D (and 3D) geometries:

`fovs` `(|dx|*nx, |dy|*ny, ...)`
`np`   `sum(mask)` = # pixels to be estimated

`dim`  `(nx, ny, [nz])`

`wx`   `(nx - 1/2) * dx + offset_x`
`wy`   `(ny - 1/2) * dy + offset_y`
`wz`   `(nz - 1/2) * dz + offset_z`

`x` 1D x coordinates of each pixel
`y` 1D y coordinates of each pixel
`z` 1D z coordinates of each pixel

`xg` x coordinates of each pixel as a grid (2D or 3D)
`yg` y coordinates of each pixel as a grid (2D or 3D)
`zg` z coordinates of each pixel as a grid (2D or 3D)

`u` 1D frequency domain coordinates of each pixel (kx)
`v` 1D frequency domain coordinates of each pixel (ky)
`w` 1D frequency domain coordinates of each pixel (kz)

`ug` ≥1D grid of kx frequency domain coordinates
`vg` ≥2D grid of ky frequency domain coordinates
`wg` ≥3D grid of kz frequency domain coordinates

`ones`  `FillArray.Ones(dim)`
`zeros` `FillArray.Zeros(dim)`

`mask_outline` binary image showing 2D outline of `mask` (todo)

Derived values for 3D images:

`mask_or` `[nx ny]` logical 'or' of `mask`

## Methods:

* `embed(x)`   turn short column(s) into array(s)
* `maskit(x)`  opposite of embed
* `shape(x)`   reshape long column x to `[nx ny [nz]]` array
* `unitv(...)`
  * `j=j | i=(ix,iy) | c=(cx cy)`
  * `j`: single index from 1 to `length(z)`
  * `i`: (ix,iy[,iz]) index from 1 to nx,ny
  * `c`: (cx,cy[,cz]) index from +/- n/2 center at floor(n/2)+1

* `circ(rx=,ry=,cx=,cy=)` circle of given radius and center (cylinder in 3D)
* `plot(jim)` plot the image geometry using the `MIRTjim.jim` function # todo - method

## Methods that return a new `ImageGeom:`

* `down(down::Int)` down-sample geometry by given factor
* `over(over::Int)` over-sample geometry by given factor
* `expand_nz(nz_pad)` expand image geometry in z by `nz_pad` on both ends
"""
ImageGeomHelp


"""
    out = image_geom_unitv(dims::Dims ; j=?, i=?, c=?, T=?)

Return a standard unit vector (Kronecker impulse).

# options (use at one of these):
- `j` single index from 1 to length(z)
- `i` (ix, iy [,iz]) index from 1 to nx,ny
- `c` (cx, cy [,cz]) index from +/- n/2 center at floor(n/2)+1
- `T::DataType` default `Bool`

Default with no arguments gives unit vector at center `c=(0, 0 [,0])`
"""
function image_geom_unitv(
    dims::Dims{D} ;
    T::DataType = Bool,
    j::Int = 0,
    i::NTuple{D,Int} = ntuple(i -> 0, D),
    c::NTuple{D,Int} = ntuple(i -> 0, D),
)::Array{T, D} where {D}

    out = zeros(T, dims)
@show T, typeof(out)

#=
    (j < 0 || j > length(out)) && throw("bad j $j")
    if 1 <= j <= length(out)
        any(!=(0), i) && throw("i $i")
        any(!=(0), c) && throw("c $c")
        out[j] = one(T)
    elseif all(1 .<= i .<= size(out))
        any(!=(0), c) && throw("c $c")
        out[i...] = one(T)
    else
        any(!=(0), i) && throw("i $i")
        tmp = c .+ (size(out) .÷ 2) .+ 1
        out[tmp...] = one(T)
    end
=#

    return out::Array{T, D}
end


# spatial axes grids ala ndgrid
xg(ig::ImageGeom) = grids(ig)[1]
yg(ig::ImageGeom) = grids(ig)[2]
zg(ig::ImageGeom) = grids(ig)[3]


# spatial frequency axes grids ala ndgrid
ug(ig::ImageGeom) = gridf(ig)[1]
vg(ig::ImageGeom) = gridf(ig)[2]
wg(ig::ImageGeom) = gridf(ig)[3]


function help(ig::ImageGeom; io::IO = isinteractive() ? stdout : devnull)
    print(io, "propertynames:\n")
    println(io, propertynames(ig))
    @doc ImageGeomHelp
end


# Extended properties

image_geom_fun0 = Dict([
    (:help, ig -> help(ig)),

    (:ndim, ig -> length(ig.dims)),
    (:nx, ig -> ig.dims[1]),
    (:ny, ig -> ig.ndim ≥ 2 ? ig.dims[2] : 0),
    (:nz, ig -> ig.ndim ≥ 3 ? ig.dims[3] : 0),
    (:dim, ig -> ig.dims),
    (:fovs, ig -> abs.(ig.deltas) .* ig.dims),

    (:zeros, ig -> zeros(ig)),
    (:ones, ig -> ones(ig)),

    (:dx, ig -> ig.deltas[1]),
    (:dy, ig -> ig.ndim ≥ 2 ? ig.deltas[2] : zero(ig.deltas[1])),
    (:dz, ig -> ig.ndim ≥ 3 ? ig.deltas[3] : zero(ig.deltas[1])),

    (:offset_x, ig -> ig.offsets[1]),
    (:offset_y, ig -> ig.ndim ≥ 2 ? ig.offsets[2] : Float32(0)),
    (:offset_z, ig -> ig.ndim ≥ 3 ? ig.offsets[3] : Float32(0)),

    (:wx, ig -> (ig.nx - 1)/2 + ig.offset_x),
    (:wy, ig -> (ig.ny - 1)/2 + ig.offset_y),
    (:wz, ig -> (ig.nz - 1)/2 + ig.offset_z),

    # spatial axes and grids
    (:x, ig -> ((0:ig.nx-1) .- ig.wx) * ig.dx),
    (:y, ig -> ((0:ig.ny-1) .- ig.wy) * ig.dy),
    (:z, ig -> ((0:ig.nz-1) .- ig.wz) * ig.dz),

    (:xg, ig -> xg(ig)),
    (:yg, ig -> yg(ig)),
    (:zg, ig -> zg(ig)),

    # DFT frequency axes and grids
    (:u, ig -> axisf(ig, 1)),
    (:v, ig -> axisf(ig, 2)),
    (:w, ig -> axisf(ig, 3)),

    (:ug, ig -> ug(ig)),
    (:vg, ig -> vg(ig)),
    (:wg, ig -> wg(ig)),

    (:np, ig -> sum(ig.mask)),
    (:mask_or, ig -> mask_or(ig.mask)),
#   (:mask_outline, ig -> mask_outline(ig.mask)),

    # simple functions

#   (:plot, ig -> ((how::Function ; kwargs...) -> plot(ig, how ; kwargs...))), # todo cut
    (:embed, ig -> (x::AbstractArray -> embed(x, ig.mask))),
    (:maskit, ig -> (x::AbstractArray -> maskit(x, ig.mask))),
    (:shape, ig -> (x::AbstractArray -> reshape(x, ig.dims))),
    (:unitv, ig -> (( ; kwargs...) -> image_geom_unitv(ig.dim ; kwargs...))),
    (:circ, ig -> (( ; kwargs...) -> circle(ig ; kwargs...))),

    # functions that return new geometry

    (:down, ig -> (down::Int -> downsample(ig, down))),
    (:over, ig -> (over::Int -> oversample(ig, over))),
    (:expand_nz, ig -> (nz_pad::Int -> expand_nz(ig, nz_pad))),

    ]
)


# Tricky overloading here!

Base.getproperty(ig::ImageGeom, s::Symbol) =
        haskey(image_geom_fun0, s) ? image_geom_fun0[s](ig) : getfield(ig, s)

Base.propertynames(ig::ImageGeom) =
    (fieldnames(typeof(ig))..., keys(image_geom_fun0)...)
