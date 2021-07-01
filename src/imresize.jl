#=
imresize.jl
Down-sample or up-sample a binary mask;
very specialized versions of `imresize`.
=#

export downsample!, downsample
export upsample!, upsample


"""
    downsample!(y, x, down::NTuple{Int})
Non-allocating version of `y = downsample(x, down)`.
Requires `size(y) = ceil(size(x) / down)`.
"""
function downsample!(
    y::BitArray{D},
    x::Union{BitArray{D}, AbstractArray{Bool,D}},
    down::NTuple{D,Int},
) where {D}
    size(y) == ceil.(Int, size(x) ./ down) || throw(DimensionMismatch())
    p = prod(down)
    for i in CartesianIndices(x)
        j = CartesianIndex( (((Tuple(i) .- 1) .÷ down) .+ 1)... )
        @inbounds y[j] |= x[i]
    end
    return y
end


"""
    y = downsample(x, down::NTuple{Int})
Down-sample a `Bool` array `x` by "max pooling" in all dimensions.
Output size will be `ceil(size(x) / down)`.
Thus, in a typical case where `size(x)` is integer multiple of `down`,
the output size will be `size(x) ÷ down`.
"""
function downsample(
    x::Union{BitArray{D}, AbstractArray{Bool,D}},
    down::NTuple{D,Int},
) where {D}
    y = falses(ceil.(Int, size(x) ./ down))
    return downsample!(y, x, down)
end


"""
    upsample!(y, x, up::NTuple{Int})
Non-allocating version of `y = upsample(x, up)`.
Requires `size(y) = ceil(size(x) * up)`.
"""
function upsample!(
    y::BitArray{D},
    x::Union{BitArray{D}, AbstractArray{Bool,D}},
    up::NTuple{D,Int},
) where {D}
    size(y) == size(x) .* up || throw(DimensionMismatch())
    p = prod(up)
    for j in CartesianIndices(y)
        i = CartesianIndex( (((Tuple(j) .- 1) .÷ up) .+ 1)... )
        @inbounds y[j] |= x[i]
    end
    return y
end


"""
    y = upsample(x, up::NTuple{Int})
Up-sample a `Bool` array `x` by "repeating" in all dimensions.
Output size will be `size(x) * up`.
"""
function upsample(
    x::Union{BitArray{D}, AbstractArray{Bool,D}},
    up::NTuple{D,Int},
) where {D}
    y = falses(size(x) .* up)
    return upsample!(y, x, up)
end
