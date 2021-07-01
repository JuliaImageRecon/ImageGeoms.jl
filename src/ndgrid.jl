#=
ndgrid.jl
lazy and non-lazy versions of ndgrid
https://github.com/JuliaArrays/FillArrays.jl/issues/112
=#

using LazyArrays

export ndgrid, ndgrid_lazy

"""
    grid = ndgrid_repeat(v::AbstractVector, dims::Dims{D}, d::Int)
Do the type of repeat needed for `ndgrid`, e.g., `repeat(x, 1, n)`,
for arbitrary dimensions, where `1 ≤ d ≤ D` and `dims[d] == length(v)`.
Output size is `dims`.
"""
function ndgrid_repeat(v::AbstractVector, dims::Dims{D}, d::Int) where D
    (1 ≤ d ≤ D) || throw(ArgumentError("$d $dims"))
    length(v) == dims[d] ||
        throw(DimensionMismatch("$d $(dims[d]) $(length(v))"))
    t1 = ntuple(i -> i == d ? length(v) : 1, Val(D)) # (1,…,1,n,1,…,1)
    t2 = ntuple(i -> i == d ? 1 : dims[i], Val(D)) # (?,…,?,1,?,…,?)
    repeat(reshape(v, t1), t2...)
end

"""
    ndgrid(args::AbstractVector...)
Returns tuple.  This is provided for convenience and testing,
but `ndgrid` is less efficient than broadcast so should be avoided.
"""
function ndgrid(args::AbstractVector...)
    fun = i -> ndgrid_repeat(args[i], length.(args), i)
    ntuple(fun, Val(length(args)))
end

const Repeat = Applied{A, typeof(ndgrid_repeat), Tuple{V,Dim,Int}} where
    {A <: Any, V <: AbstractVector, Dim <: Dims{D} where D}
Base.ndims(r::Repeat) = length(r.args[2])
Base.size(r::Repeat) = r.args[2]
Base.eltype(r::Repeat) = eltype(r.args[1])

const RepeatA{T,N} = ApplyArray{T, N, typeof(ndgrid_repeat)}
# Base.IndexStyle(RepeatA) = IndexCartesian() # default

Base.@propagate_inbounds function Base.getindex(
    r::RepeatA{T,N},
    i::Vararg{Int,N},
) where {T,N}
    @boundscheck checkbounds(r, i...)
    return @inbounds r.args[1][i[r.args[3]]]
#   return r.args[1][i[r.args[3]]]
end

"""
    ndgrid_lazy(args::AbstractVector...)
Returns tuple of `Repeat` items, so avoids the memory issues of `ndgrid`.
"""
function ndgrid_lazy(args::AbstractVector...)
    fun = i -> ApplyArray(ndgrid_repeat, args[i], length.(args), i)
    ntuple(fun, Val(length(args)))
end
