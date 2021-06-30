#=
downsample.jl
Down-sample a binary mask;
a very specialized version of `imresize`.
=#

export downsample!, downsample


"""
    downsample!(y, x, down::NTuple{Int})
Non-allocating version of `y = downsample(x, down)`.
"""
function downsample!(
    y::BitArray{D},
    x::Union{BitArray{D}, AbstractArray{Bool,D}},
    down::NTuple{D,Int},
) where {D}
    all(==(0), rem.(size(x), down)) || throw(DimensionMismatch())
    p = prod(down)
    for d in 1:p
        vec(y) .|= x[d-1 .+ (1:p:length(x))]
    end
    return y
end


"""
    y = downsample(x, down::NTuple{Int})
Down-sample a `Bool` array by "max pooling" in all dimensions.
The factors `down` must be integer divisors of `size(x)`.
"""
function downsample(
    x::Union{BitArray{D}, AbstractArray{Bool,D}},
    down::NTuple{D,Int},
) where {D}
    y = falses(size(x) .÷ down)
    return downsample!(y, x, down)
end
