#=
image-geom.jl
Methods related to an image geometry for image reconstruction
2017-10-02 Samuel Rohrer, University of Michigan
2019-03-05 Jeff Fessler, Julia 1.1 + tests
2019-06-23 Jeff Fessler, overhaul
2020-07-21 Jeff Fessler, D-dimensional
2021-06-30 Jeff Fessler, streamline
=#

export ImageGeom #, image_geom, cbct
export circle, ellipse

#using ImageGeoms: downsample, upsample
using FillArrays: Trues, Zeros, Ones


"""
    ImageGeom{D,S}

Image geometry struct with essential grid parameters.

- `dims::Dims{D}` image dimensions
- `deltas::S` where `S <: NTuple{D}` pixel sizes,
  where each Δ is usually `Real` or `Unitful.Length`
- `offsets::NTuple{D,Float32}` unitless
- `mask::AbstractArray{Bool,D}` logical mask, often `FillArrays.Trues(dims)`.
"""
struct ImageGeom{D, S <: NTuple{D,RealU}}
    dims::Dims{D} # image dimensions
    deltas::S # pixel sizes
    offsets::NTuple{D,Float32} # unitless
    mask::AbstractArray{Bool,D} # logical mask for image support

    function ImageGeom{D,S}(
        dims::Dims{D},
        deltas::S,
        offsets::NTuple{D,Real},
        mask::AbstractArray{Bool,D},
    ) where {D, S <: NTuple{D,RealU}} # i.e., Union{Real,Unitful.Length}
        any(<=(zero(Int)), dims) && throw("dims must be positive")
        any(iszero, deltas) && throw("deltas must be nonzero")
        size(mask) == dims ||
            throw(DimensionMismatch("mask size $(size(mask)) vs dims $dims"))
        new{D,S}(dims, deltas, Float32.(offsets), mask)
    end
end

"""
    ig = ImageGeom(dims, deltas, offsets, [, mask])
Convenient constructor for `ImageGeom`.
The `deltas` elements should each be `Real` or a `Unitful.Length`.
Default `mask` is `FillArrays.Trues(dims)` which is akin to `trues(dims)`.
"""
function ImageGeom(
    dims::Dims{D},
    deltas::S,
    offsets::NTuple{D,Real},
    mask::AbstractArray{Bool,D},
) where {D, S <: NTuple{D,RealU}}
    ImageGeom{D,S}(dims, deltas, offsets, mask)
end

function ImageGeom(
    dims::Dims{D},
    deltas::NTuple{D,RealU},
    offsets::NTuple{D,Real},
) where {D}
    ImageGeom(dims, deltas, offsets, Trues(dims))
end

"""
    ig = ImageGeom( ; dims=(nx,nx), deltas=(1,1), offsets=(0,0), mask=Trues )
Convenience constructor using named keywords
"""
function ImageGeom( ;
    dims::Dims{D} = (128,128),
    deltas::NTuple{D,RealU} = ntuple(i -> 1.0f0, length(dims)),
    offsets::NTuple{D,Real} = ntuple(i -> 0.0f0, length(dims)),
    mask::AbstractArray{Bool,D} = Trues(dims),
) where {D}
    ImageGeom(dims, deltas, offsets, mask)
end


function help(ig::ImageGeom; io::IO = isinteractive() ? stdout : devnull)
	print(io, "propertynames:\n")
	println(io, propertynames(ig))
end


"""
	`ImageGeom` help

## Properties

Access by `ig.key`, mostly for 2D (and 3D) geometries:

`is3`	is it 3d (`nz > 0`?) deprecated: use ndims(ig)
`fovs` `(|dx|*nx, |dy|*ny, ...)`
`np`	`sum(mask)` = # pixels to be estimated

`dim`	`(nx, ny, [nz])`
`x`	1D x coordinates of each pixel
`y`	1D y coordiantes of each pixel
`wx`	`(nx - 1/2) * dx + offset_x`
`wy`	`(ny - 1/2) * dy + offset_y`
`wz`	`(nz - 1/2) * dz + offset_z`

`xg`	x coordinates of each pixel as a grid (2D or 3D)
`yg`	y coordinates of each pixel as a grid (2D or 3D)

`u`	1D frequency domain coordinates of each pixel (kx)
`v`	1D frequency domain coordinates of each pixel (ky)
`w`	1D frequency domain coordinates of each pixel (kz)

`ug`	2D or 3D grid of frequency domain coordinates
`vg`	2D or 3D grid of frequency domain coordinates
`fg`	`NamedTuple` of 2D or 3D frequency coordinates
`ones`	`FillArray.Ones(dim)`
`zeros`	FillArray.Zeros(dim)

`mask_outline`	binary image showing 2D outline of `mask`

	Derived values for 3D images:

`z`	z coordinates of each pixel
`zg`	z coordinates of each pixel as a grid (3D only)
`wg`	3D grid of frequency domain coordinates

`mask_or`	`[nx ny]` logical 'or' of mask

## Methods:

* `embed(x)`	turn short column(s) into array(s)
* `maskit(x)`	opposite of embed
* `shape(x)`	reshape long column x to `[nx ny [nz]]` array
* `unitv(...)`
  * `j=j | i=(ix,iy) | c=(cx cy)`
  * `j`: single index from 1 to `length(z)`
  * `i`: (ix,iy[,iz]) index from 1 to nx,ny
  * `c`: (cx,cy[,cz]) index from +/- n/2 center at floor(n/2)+1

* `circ(rx=,ry=,cx=,cy=)` circle of given radius and center (cylinder in 3D)
* `plot(jim)` plot the image geometry using the `MIRTjim.jim` function

## Methods that return a new `ImageGeom:`

* `down(down::Int)` down-sample geometry by given factor
* `over(over::Int)` over-sample geometry by given factor
* `expand_nz(nz_pad)` expand image geometry in z by `nz_pad` on both ends
"""
ImageGeom


#=
"""
    MIRT_cbct_ig

Structure suitable for passing to C routines `cbct_*`
based on the struct `cbct_ig` found in `cbct,def.h`
"""
struct MIRT_cbct_ig
	nx::Cint
	ny::Cint
	nz::Cint
	dx::Cfloat
	dy::Cfloat
	dz::Cfloat
	offset_x::Cfloat
	offset_y::Cfloat
	offset_z::Cfloat
	mask2::Ptr{Cuchar}	# [nx,ny] 2D support mask: 0 or 1 .. nthread
	iy_start::Ptr{Cint} # [nthread] for mask2
	iy_end::Ptr{Cint}	# [nthread] for mask2
end


"""
    cbct(ig::ImageGeom{3,<:Real}; nthread::Int=1)
Constructor for `MIRT_cbct_ig` (does not support units currently)
"""
function cbct(ig::ImageGeom{3,S} ; nthread::Int=1) where {S <: NTuple{3,Real}}
	iy_start = [0]
	iy_end = [ig.ny]
	nthread != 1 && throw("only nthread=1 for now due to iy_start")
	return MIRT_cbct_ig(
		Cint(ig.nx), Cint(ig.ny), Cint(ig.nz), Cfloat(ig.dx),
		Cfloat(ig.dy), Cfloat(ig.dz),
		Cfloat(ig.offset_x), Cfloat(ig.offset_y), Cfloat(ig.offset_z),
		pointer(UInt8.(ig.mask_or)),
		pointer(Cint.(iy_start)), pointer(Cint.(iy_end)),
	)
end
=#


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
	mask::Union{Symbol,AbstractArray{Bool}}	= :all,
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
		#	fov = nx * dx
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
		#	zfov = nz * dz
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


"""
    ig_down = downsample(ig, down::Tuple{Int})
Down sample an image geometry by the factor `down`.
cf `image_geom_downsample`
"""
function downsample(ig::ImageGeom{D,S}, down::NTuple{D,Int}) where {D,S}

	any(ig.dims .< down) && throw("dims=$(ig.dims) < down=$down")
	down_dim = ig.dims ÷ down # round down (if needed)
	deltas .*= down
	down_offsets = ig.offsets ./ down # adjust offsets to new "pixel" units

	# carefully down-sample the mask
	v = view(mask, Base.OneTo.(down_dim .* down)...)
    down_mask = downsample(v, down)

	return ImageGeom{D,S}(down_dim, deltas, down_offsets, down_mask)
end

downsample(ig::ImageGeom{D}, down::Int) where {D} =
	downsample(ig, ntuple(i->down, D))


"""
    ig_new = expand_nz(ig::ImageGeom{3}, nz_pad::Int)
Pad both ends along z.
"""
function expand_nz(ig::ImageGeom{3,S}, nz_pad::Int) where S
	out_nz = ig.nz + 2*nz_pad
    if ig.mask isa Trues
	    out_mask = Trues(ig.dims[1:2]..., out_nz)
    else
		out_mask = cat(dims=3, repeat(ig.mask[:,:,1], 1, 1, nz_pad),
			ig.mask, repeat(ig.mask[:,:,end], 1, 1, nz_pad),
		)
	end
	return ImageGeom{3,S}((ig.dims[1], ig.dims[2], out_nz),
		ig.deltas, ig.offsets, out_mask,
	)
end


"""
    ig_over = oversample(ig::ImageGeom, over::Int)
Over-sample an image geometry by the factor `over`.
"""
function oversample(ig::ImageGeom{D}, over::Int) where {D}
	if ig.mask isa Trues || all(ig.mask)
		mask_over = Trues(ig.dims .* over)
	else
		mask_over = upsample(ig.mask, over)
	end
	return ImageGeom(ig.dims .* over, ig.deltas ./ over,
		ig.offsets .* over, mask_over,
	)
end


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

    return @. ((ig.x - cx) / rx)^2 + ((ig.y' - cy) / ry)^2 .< 1
end


# default is a circle that just inscribes the square
# but keeping a 1 pixel border due to ASPIRE regularization restriction
function circle(ig::ImageGeom{2} ;
	rx::RealU = abs((ig.dims[1]/2-1)*dx),
	ry::RealU = abs((ig.dims[2]/2-1)*dy),
	r::RealU = min(rx,ry),
    kwargs...,
#   over::Int=2,
)
	return ellipse(ig ; rx=r, ry=r, kwargs...)
end

function circle(ig::ImageGeom{3} ; kwargs...)
	i2 = ImageGeom(ig.dims[1:2], ig.deltas[1:2], ig.offsets[1:2])
    return repeat(circle(i2 ; kwargs...), 1, 1, ig.nz)
end


"""
    out = image_geom_add_unitv(z::AbstractArray ; j=?, i=?, c=?)

Add a unit vector to an initial array `z` (typically of zeros).

# options (use at one of these):
- `j` single index from 1 to length(z)
- `i` (ix, iy [,iz]) index from 1 to nx,ny
- `c` (cx, cy [,cz]) index from +/- n/2 center at floor(n/2)+1

Default with no arguments gives unit vector at center `c=(0, 0 [,0])`
"""
function image_geom_add_unitv(
	z::AbstractArray{T, D} ; # starts with zeros()
	j::Int = 0,
	i::NTuple{D,Int} = ntuple(i -> 0, D),
	c::NTuple{D,Int} = ntuple(i -> 0, D),
) where {T <: Number, D}

	out = collect(z)

	(j < 0 || j > length(z)) && throw("bad j $j")
	if 1 <= j <= length(z)
		any(!=(0), i) && throw("i $i")
		any(!=(0), c) && throw("c $c")
		out[j] += one(T)
	elseif all(1 .<= i .<= size(z))
		any(!=(0), c) && throw("c $c")
		out[i...] += one(T)
	else
		any(!=(0), i) && throw("i $i")
		tmp = c .+ (size(out) .÷ 2) .+ 1
		out[tmp...] += one(T)
	end

	return out
end


"""
    plot(ig, how ; kwargs...)
The `how` argument should be `MIRTjim.jim` to be useful.
"""
plot(ig::ImageGeom{2}, how::Function ; kwargs...) =
	how(ig.x, ig.y, ig.mask, "(nx,ny)=$(ig.nx),$(ig.ny)" ; kwargs...)
plot(ig::ImageGeom{3}, how::Function ; kwargs...) =
	how(ig.x, ig.y, ig.mask_or,
		"(dx,dy,dz)=$(ig.dx),$(ig.dy),$(ig.dz)" ; kwargs...)


"""
    show(io::IO, ::MIME"text/plain", ig::ImageGeom)
"""
function Base.show(io::IO, ::MIME"text/plain", ig::ImageGeom)
    println(io, typeof(ig))
    for f in (:dims, :deltas, :offsets)
        p = getproperty(ig, f)
        println(io, " ", f, "::", typeof(p), " ", p)
    end
    f = :mask
    mask = getproperty(ig, f)
#   print(io, " ", f, "::", typeof(ig).types[end], " ", mask)
    print(io, " ", f, "::", " ", mask)
    println(io, " {", sum(mask), " of ", length(mask), "}")
end

Base.zeros(ig::ImageGeom) = Zeros{Float32}(ig.dims...)
Base.ones(ig::ImageGeom) = Ones{Float32}(ig.dims...)
Base.ndims(ig::ImageGeom{D}) where D = D

_zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,Real}} = zero(Float32)
_zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,Any}} = zero(Int32) # alert!
_zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,T}} where {T <: Number} = zero(T)
_zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,T}} where {T <: Real} = zero(T)


# spatial axes and grids ala ndgrid (todo: use lazy repeat?)
xg(ig::ImageGeom{1}) = ig.x
xg(ig::ImageGeom) = repeat(ig.x, 1, ig.dims[2:end]...)

yg(ig::ImageGeom{1}) = Zeros{Float32}(ig.dims)
yg(ig::ImageGeom{2}) = repeat(ig.y', ig.nx, 1)
yg(ig::ImageGeom{3}) = repeat(ig.y', ig.nx, 1, ig.nz)
yg(ig::ImageGeom) = throw(DimensionMismatch("yg for > 3D"))

zg(ig::ImageGeom{1}) = Zeros{Float32}(ig.dims)
zg(ig::ImageGeom{2}) = Zeros{Float32}(ig.dims)
zg(ig::ImageGeom{3}) = repeat(reshape(ig.z, 1, 1, ig.nz), ig.nx, ig.ny, 1)
zg(ig::ImageGeom) = throw(DimensionMismatch("yg for > 3D"))

Base.axes(ig::ImageGeom{1}) = (ig.x,)
Base.axes(ig::ImageGeom{2}) = (ig.x, ig.y)
Base.axes(ig::ImageGeom{3}) = (ig.x, ig.y, ig.z)
Base.axes(ig::ImageGeom) = throw(DimensionMismatch("axes for > 3D"))

# spatial frequency grids
ug(ig::ImageGeom{1}) = ig.u
ug(ig::ImageGeom) = repeat(ig.u, 1, ig.dims[2:end]...)

vg(ig::ImageGeom{1}) = Zeros{Float32}(ig.dims)
vg(ig::ImageGeom{2}) = repeat(ig.v', ig.nx, 1)
vg(ig::ImageGeom{3}) = repeat(ig.v', ig.nx, 1, ig.nz)
vg(ig::ImageGeom) = throw(DimensionMismatch("vg for > 3D"))

wg(ig::ImageGeom{1}) = Zeros{Float32}(ig.dims)
wg(ig::ImageGeom{2}) = Zeros{Float32}(ig.dims)
wg(ig::ImageGeom{3}) = repeat(reshape(ig.z, 1, 1, ig.nz), ig.nx, ig.ny, 1)
wg(ig::ImageGeom) = throw(DimensionMismatch("wg for > 3D"))

fg(ig::ImageGeom{1}) = (ig.ug,)
fg(ig::ImageGeom{2}) = (ig.ug, ig.vg)
fg(ig::ImageGeom{3}) = (ig.ug, ig.vg, ig.wg)
fg(ig::ImageGeom) = throw(DimensionMismatch("fg for > 3D"))


# Extended properties

image_geom_fun0 = Dict([
	(:help, ig -> help(ig)),

	(:ndim, ig -> length(ig.dims)),
	(:nx, ig -> ig.dims[1]),
	(:ny, ig -> ig.ndim >= 2 ? ig.dims[2] : 0),
	(:nz, ig -> ig.ndim >= 3 ? ig.dims[3] : 0),
#	(:is3, ig -> ig.nz > 0),
	(:dim, ig -> ig.dims),
	(:fovs, ig -> abs.(ig.deltas) .* ig.dims),

	(:zeros, ig -> zeros(ig)),
	(:ones, ig -> ones(ig)),

	(:dx, ig -> ig.deltas[1]),
    (:dy, ig -> ig.ndim >= 2 ? ig.deltas[2] : _zero(ig)),
    (:dz, ig -> ig.ndim >= 3 ? ig.deltas[3] : _zero(ig)),

	(:offset_x, ig -> ig.offsets[1]),
	(:offset_y, ig -> ig.ndim >= 2 ? ig.offsets[2] : Float32(0)),
	(:offset_z, ig -> ig.ndim >= 3 ? ig.offsets[3] : Float32(0)),

	(:wx, ig -> (ig.nx - 1)/2 + ig.offset_x),
	(:wy, ig -> (ig.ny - 1)/2 + ig.offset_y),
	(:wz, ig -> (ig.nz - 1)/2 + ig.offset_z),

	# spatial axes and grids
	(:x, ig -> ((0:ig.nx-1) .- ig.wx) * ig.dx),
	(:y, ig -> ((0:ig.ny-1) .- ig.wy) * ig.dy),
	(:z, ig -> ((0:ig.nz-1) .- ig.wz) * ig.dz),
	(:axes, ig -> axes(ig)),

	(:xg, ig -> xg(ig)),
	(:yg, ig -> yg(ig)),
	(:zg, ig -> zg(ig)),

	# DFT frequency axes and grids
	(:u, ig -> (-ig.nx/2:(ig.nx/2-1)) / (ig.nx*ig.dx)),
	(:v, ig -> (-ig.ny/2:(ig.ny/2-1)) / (ig.ny*ig.dy)),
	(:w, ig -> (-ig.nz/2:(ig.nz/2-1)) / (ig.nz*ig.dz)),

	(:ug, ig -> ug(ig)),
	(:vg, ig -> vg(ig)),
	(:wg, ig -> ug(ig)),
	(:fg, ig -> fg(ig)),

	(:np, ig -> sum(ig.mask)),
	(:mask_or, ig -> mask_or(ig.mask)),
	(:mask_outline, ig -> mask_outline(ig.mask)),

	# simple functions

	(:plot, ig -> ((how::Function ; kwargs...) -> plot(ig, how ; kwargs...))),
	(:embed, ig -> (x::AbstractArray -> embed(x, ig.mask))),
	(:maskit, ig -> (x::AbstractArray -> maskit(x, ig.mask))),
	(:shape, ig -> (x::AbstractArray -> reshape(x, ig.dim))),
	(:unitv, ig -> (( ; kwargs...) -> image_geom_add_unitv(ig.zeros ; kwargs...))),
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
