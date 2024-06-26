#=
core.jl
ImageGeom type, constructors, and core methods
=#

export ImageGeom
export downsample, oversample, expand_nz
export axis, grids, axisf, axesf, gridf, fovs

#using ImageGeoms: downsample, upsample
using LazyGrids: ndgrid
using FillArrays: Trues, Falses, Zeros, Ones


## Type

"""
    ImageGeom{D,S,M}

Image geometry struct with essential grid parameters.

- `dims::Dims{D}` image dimensions
- `deltas::S` where `S <: NTuple{D}` pixel sizes,
  where each Δ is usually `Real` or `Unitful.Length`
- `offsets::NTuple{D,Float32}` unitless
- `mask::M` where `M <: AbstractArray{Bool,D}` logical mask, often `FillArrays.Trues(dims)`.
"""
struct ImageGeom{D, S <: NTuple{D,RealU}, M <: AbstractArray{Bool,D}}
    dims::Dims{D} # image dimensions
    deltas::S # pixel sizes
    offsets::NTuple{D,Float32} # unitless
    mask::M # logical mask for image support

    function ImageGeom{D,S,M}(
        dims::Dims{D},
        deltas::S,
        offsets::NTuple{D,Real},
        mask::M
    ) where {D,
            S <: NTuple{D,RealU}, # i.e., Union{Real,Unitful.Length}
            M <: AbstractArray{Bool,D},
        }
        any(<=(0), dims) && throw("dims must be positive")
        any(iszero, deltas) && throw("deltas must be nonzero")
        size(mask) == dims ||
            throw(DimensionMismatch("mask size $(size(mask)) vs dims $dims"))
        new{D,S,M}(dims, deltas, Float32.(offsets), mask)
    end
end


## Constructors


"""
    ig = ImageGeom(dims::Dims, deltas, offsets, [, mask])
Constructor for `ImageGeom` of dimensions `dims`.
* The `deltas` elements (tuple of grid spacings)
  should each be `Real` or a `Unitful.Length`; default `(1,…,1)`.
* The `offsets` (tuple of grid offsets) must be unitless;  default `(0,…,0)`.
* The `dims`, `deltas` and `offsets` tuples must be same length.
* Default `mask` is `FillArrays.Trues(dims)` which is akin to `trues(dims)`.

Using `offsets = :dsp` means `offsets = 0.5 .* iseven.(dims)`.

# Example

```jldoctest
julia> ImageGeom((5,7), (2.,3.))
ImageGeom{2, NTuple{2,Float64}, FillArrays.Trues{2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}}
 dims::NTuple{2,Int64} (5, 7)
 deltas::NTuple{2,Float64} (2.0, 3.0)
 offsets::NTuple{2,Float32} (0.0f0, 0.0f0)
 mask: 5×7 Ones{Bool} {35 of 35}
```
"""
function ImageGeom(
    dims::Dims{D},
    deltas::S,
    offsets::Union{Symbol,NTuple{D,Real}},
    mask::M,
) where {D, S <: NTuple{D,RealU}, M <: AbstractArray{Bool,D}}
    if offsets isa Symbol
        offsets == :dsp || throw("bad offset $offset")
        offsets = 0.5 .* iseven.(dims)
    end
    ImageGeom{D,S,M}(dims, deltas, offsets, mask)
end

function ImageGeom(
    dims::Dims{D},
    deltas::NTuple{D,RealU} = ntuple(i -> 1, D),
    offsets::Union{Symbol,NTuple{D,Real}} = ntuple(i -> 0, D),
) where {D}
    ImageGeom(dims, deltas, offsets, Trues(dims))
end


_Tfov(fov::RealU) = typeof(1f0 * fov) # ensure at least Float32

"""
    ig = ImageGeom( ; dims=(nx,ny), deltas=(1,1), offsets=(0,0), mask=Trues )
Constructor using named keywords.
One can use `fovs` as an alternate keyword,
in which case `deltas = fovs ./ dims`.
The keyword `fov` applies to all dimensions.
"""
function ImageGeom( ;
    dims::Dims{D} = (128,128),
    fov::RealU = 0f0,
    fovs::NTuple{D,RealU} = _Tfov(fov).(iszero(fov) ? dims : ntuple(i -> fov, length(dims))),
    deltas::NTuple{D,RealU} = fovs ./ dims,
    offsets::Union{Symbol,NTuple{D,Real}} = ntuple(i -> 0f0, length(dims)),
    mask::M = Trues(dims),
) where {D, M <: AbstractArray{Bool}}
    D == ndims(mask) || throw(DimensionMismatch("D=$D mask size $(size(mask))"))
    ImageGeom(dims, deltas, offsets, mask)
end


"""
    ig = ImageGeom(masktype::Mask ; kwargs...)
Constructor with specified mask, e.g., `ImageGeom(MaskCircle() ; dims=(6,8))`.
"""
function ImageGeom(masktype::Mask ; kwargs...)
    ig = ImageGeom( ; kwargs...)
    mask = makemask(ig, masktype)
    return ImageGeom( ; mask, kwargs...)
end


## Methods

# Simplify type display of Tuple to NTuple if possible
function _typeof(x::Tuple)
    D = length(x)
    return x isa NTuple{D, typeof(x[1])} ?
        "NTuple{$D,$(typeof(x[1]))}" : typeof(x)
end


"""
    show(io::IO, ::MIME"text/plain", ig::ImageGeom)
"""
function Base.show(io::IO, ::MIME"text/plain", ig::ImageGeom{D}) where {D}
    t = typeof(ig)
    t = replace(string(t), string(typeof(ig.deltas)) => string(_typeof(ig.deltas)))
    println(io, t)
    for f in (:dims, :deltas, :offsets)
        p = getfield(ig, f)
        t = _typeof(p)
        println(io, " ", f, "::", t, " ", p)
    end
    f = :mask
    mask = getfield(ig, f)
    print(io, " ", f, ":", " ", summary(mask))
    println(io, " {", count(mask), " of ", length(mask), "}")
end

Base.ndims(ig::ImageGeom{D}) where {D} = D
Base.size(ig::ImageGeom) = ig.dims
Base.size(ig::ImageGeom, d::Int) = ig.dims[d]

Base.zeros(T::Type{<:Number}, ig::ImageGeom) = Zeros{T}(ig.dims...)
Base.zeros(ig::ImageGeom) = zeros(Float32, ig)
Base.ones(T::Type{<:Number}, ig::ImageGeom) = Ones{T}(ig.dims...)
Base.ones(ig::ImageGeom) = ones(Float32, ig)

Base.trues(ig::ImageGeom) = Trues(ig.dims...)
Base.falses(ig::ImageGeom) = Falses(ig.dims...)

#Base.zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,Real}} = zero(Float32)
#Base.zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,Any}} = zero(Int32) # alert!
#Base.zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,T}} where {T <: Number} = zero(T)
#Base.zero(ig::ImageGeom{D,S}) where {D, S <: NTuple{D,T}} where {T <: Real} = zero(T)


"""
    fovs(ig::ImageGeom) = ig.dims .* ig.deltas
Return tuple of the field of view (FOV) values for all D axes.
"""
fovs(ig::ImageGeom) = ig.dims .* ig.deltas


"""
    ig_down = downsample(ig, down::Tuple{Int})
Down sample an image geometry by the factor `down`.
Image size `ig.dims` must be ≥ `down`.
cf `image_geom_downsample`.
"""
function downsample(ig::ImageGeom{D,S,M}, down::NTuple{D,Int}) where {D,S,M}

    any(ig.dims .< down) && throw("dims=$(ig.dims) < down=$down")
    down_dim = ig.dims .÷ down # round down (if needed)
    deltas = ig.deltas .* down
    down_offsets = ig.offsets ./ down # adjust offsets to new "pixel" units

    # carefully down-sample the mask
    if ig.mask isa Trues # || all(ig.mask)
        down_mask = Trues(down_dim)
    else
        v = view(ig.mask, Base.OneTo.(down_dim .* down)...)
        down_mask = downsample(v, down)
    end

    return ImageGeom{D,S,M}(down_dim, deltas, down_offsets, down_mask)
end

downsample(ig::ImageGeom{D}, down::Int) where {D} =
    downsample(ig, ntuple(i -> down, D))


"""
    ig_over = oversample(ig::ImageGeom, over::Int or NTuple)
Over-sample an image geometry by the factor `over`.
"""
function oversample(ig::ImageGeom{D,S}, over::NTuple{D,Int}) where {D,S}
    if ig.mask isa Trues # || all(ig.mask)
        mask_over = Trues(ig.dims .* over)
    else
        mask_over = upsample(ig.mask, over)
    end
    return ImageGeom(ig.dims .* over, ig.deltas ./ over,
        ig.offsets .* over, mask_over,
    )
end

oversample(ig::ImageGeom{D}, over::Int) where {D} =
    oversample(ig, ntuple(i -> over, D))


"""
    ig_new = expand_nz(ig::ImageGeom{3}, nz_pad::Int)
Pad both ends along z.
"""
function expand_nz(ig::ImageGeom{3,S,M}, nz_pad::Int) where {S,M}
    out_nz = size(ig,3) + 2*nz_pad
    if ig.mask isa Trues
        out_mask = Trues(ig.dims[1:2]..., out_nz)
    else
        out_mask = cat(dims=3, repeat(ig.mask[:,:,1], 1, 1, nz_pad),
            ig.mask, repeat(ig.mask[:,:,end], 1, 1, nz_pad),
        )
    end
    return ImageGeom{3,S,M}((ig.dims[1], ig.dims[2], out_nz),
        ig.deltas, ig.offsets, out_mask,
    )
end


# spatial axes
_center(n::Int, offset::Toffset) where {Toffset <: Real} =
    Toffset((n - 1)/2 + offset) # maintain type of offset
_axis(n::Int, Δ::RealU, offset::Real) = ((0:n-1) .- _center(n, offset)) * Δ
axis(ig::ImageGeom{D}, d::Int) where {D} =
    _axis(ig.dims[d], ig.deltas[d], ig.offsets[d])
Base.axes(ig::ImageGeom{D}) where {D} = ntuple(d -> axis(ig, d), Val(D))

grids(ig::ImageGeom) = ndgrid(axes(ig)...) # spatial grids

# spatial frequency axes
_axisf(n::Int, Δ::RealU) =
    (iseven(n) ? (-n/2:n/2-1) : (-(n-1)/2:(n-1)/2)) / (n*Δ)
axisf(ig::ImageGeom{D}, d::Int) where {D} = _axisf(ig.dims[d], ig.deltas[d])
axesf(ig::ImageGeom{D}) where {D} = ntuple(d -> axisf(ig, d), Val(D))

gridf(ig::ImageGeom) = ndgrid(axesf(ig)...) # spectral grids
