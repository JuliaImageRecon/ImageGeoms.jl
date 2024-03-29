#=
mask.jl
Methods related to an image support mask.
2019-06-22 Jeff Fessler, University of Michigan
2020-06-30 embed! getindex!
=#

export embed, embed!, mask_or, maskit
#export mask_outline
export getindex!

#using ImageFiltering: imfilter, centered
#using SparseArrays: sparse, findnz, AbstractSparseVector


"""
    getindex!(y::AbstractVector, x::AbstractArray{T,D}, mask::AbstractArray{Bool,D})
Equivalent to the in-place `y .= x[mask]` but is non-allocating.

For non-Boolean indexing, just use `@views y .= A[index]`, per
https://discourse.julialang.org/t/efficient-non-allocating-in-place-getindex-for-bitarray/42268
"""
@inline function getindex!(
    y::AbstractVector,
    x::AbstractArray{T,D},
    mask::AbstractArray{Bool,D},
) where {T,D}
    axes(y) == (Base.OneTo(count(mask)),) || throw("y axes $(axes(y))")
    axes(mask) == axes(x) || throw(DimensionMismatch("x vs mask"))
    accum = 1
    @inbounds for i in 1:LinearIndices(mask)[findlast(mask)]
        y[accum] = x[i]
        accum += mask[i]
    end
    return y
end


"""
    mask_or(mask)
compress 3D mask to 2D by logical `or` along `z` direction
"""
@inline mask_or(mask::AbstractArray{Bool,2}) = mask
mask_or(mask::AbstractArray{Bool,3}) =
    dropdims(sum(mask, dims=3) .> 0, dims=3)
mask_or(mask::AbstractArray{Bool}) = throw("ndims(mask) = $(ndims(mask))")


"""
    mask_outline(mask)
Return outer boundary of 2D `mask` (or `mask_or` for 3D).
"""
function mask_outline(mask::AbstractMatrix{Bool})
#   out = imfilter(mask, centered(ones(Int32,3,3))) # dilate
#   out = out[2:end-1,2:end-1] # 'same'
    out = copy(mask)
    for s1 in -1:1, s2 in -1:1
        out .|= circshift(mask, (s1,s2))
    end
    return @. (out > 0) & !mask
end
mask_outline(mask::AbstractArray{Bool,3}) = mask_outline(mask_or(mask))


"""
    embed!(array, v, mask ; filler=0)
Embed vector `v` of length `count(mask)`
into elements of `array` where `mask` is `true`,
setting the remaining elements to `filler` (default 0).
"""
embed!(array::AbstractArray{T,D}, v::AbstractVector{<:Number},
    mask::AbstractArray{Bool,D} ; filler::T = zero(T)
) where {T, D} =
    setindex!(fill!(array, filler), v, mask)


"""
    array = embed(v, mask ; filler=0)

Embed vector `v` of length `count(mask)`
into elements of an array where `mask` is `true`; see `embed!`.
"""
embed(v::AbstractVector{T}, mask::AbstractArray{Bool} ;
    filler::Number = zero(T)) where {T <: Number} =
    embed!(fill(filler, size(mask)), v, mask)


"""
    array = embed(matrix::AbstractMatrix{<:Number}, mask::AbstractArray{Bool})

Embed each column of `matrix` into `mask` then `cat` along next dimension
# In:
* `matrix [count(mask) L]`
* `mask [(N)]`

# Out:
* `array [(N) L]`
"""
function embed(x::AbstractMatrix{<:Number}, mask::AbstractArray{Bool})
    L = size(x,2)
    out = zeros(eltype(x), prod(size(mask)), L)
    for l in 1:L
        out[:,l] = vec(embed(x[:,l], mask))
    end
    reshape(out, size(mask)..., L)
end



#=
this is needed only for "unpacking" sparse system matrices so ignore for now
# image_geom_embed_sparse
# called by image_geom_embed
# function _embed_sparse(x::Array{T}) where {T <: Number}
function embed(x::AbstractSparseVector{<:Number},
                mask::AbstractArray{Bool,N} where N)
    i, v = findnz(x)
    ind = findall(mask)
    j = ind(j)
    return sparsevec(i, j, a, size(x,1), length(mask))
end
=#



"""
    maskit(x::AbstractArray{<:Number}, mask)
opposite of embed
"""
function maskit(x::AbstractArray, mask::AbstractArray{Bool})
    dim = size(x)
    ((ndims(x) >= ndims(mask)) && (size(x)[1:ndims(mask)] == size(mask))) ||
        throw(DimensionMismatch("size x $(size(x)) vs mask $(size(mask))"))
    x = reshape(x, length(mask), :)
    x = x[vec(mask),:] # reshape(mask, prod(_dim()))]
    return length(dim) == ndims(mask) ?
        dropdims(x, dims=2) : # squeeze
        reshape(x, :, dim[(1+ndims(mask)):end]...)
end
