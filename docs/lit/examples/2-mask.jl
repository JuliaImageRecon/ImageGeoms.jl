#=
# [Support mask](@id 2-mask)

This page explains the `mask` aspects of the Julia package
[`ImageGeoms`](https://github.com/JuliaImageRecon/ImageGeoms.jl).
=#

#srcURL


# ### Setup

# Packages needed here.

using ImageGeoms: ImageGeom, MaskCircle, MaskAllButEdge
using ImageGeoms: maskit, embed, embed!, getindex! # +jim +size
using ImageGeoms: mask_outline
using MIRTjim: jim, prompt
using Unitful: mm


# The following line is helpful when running this file as a script;
# this way it will prompt user to hit a key after each figure is displayed.

isinteractive() ? jim(:prompt, true) : prompt(:draw);


#=
## Mask overview

In tomographic image reconstruction, patients are usually more "round"
than "square" so often we only want to estimate the pixels inside some
support `mask`: a `Bool` array indicating which pixels are to be estimated.
(The rest are constrained to be zero.)
The `ImageGeom` struct has an entry to store this `mask`.
The default is `Trues(dims)` which is a "lazy" Bool `AbstractArray`
from the `FillArrays` package that is conceptually similar to `trues(dims)`
but requires `O(1)` storage.  So there is essentially no memory penalty
to storing this entry in the `ImageGeom` for users who do not want
to think about a `mask`.
For users who do want a `mask`, fortunately Julia uses a special `BitArray`
type to store `Bool` arrays, so the storage is 8× less than using bytes
in most other languages.

Often we use a "circle inscribed in the square" as a generic support mask,
and one of the built-in constructors can generate such a circular mask:
=#

ig = ImageGeom(MaskCircle() ; dims=(40,32), deltas=(1mm,1mm))

# That last line shows that 716 of 1280=40*32 mask pixels are nonzero.

jim(ig)


#=
Note that `jim` displays the axes with the units naturally;
see [MIRTjim.jl](https://github.com/JeffFessler/MIRTjim.jl).

A 3D mask can be hard to visualize, so there is a `mask_or` method
that collapses it to 2D:
=#

ig = ImageGeom(MaskAllButEdge() ; dims=(32,32,16))

jim(ig)


# ## Mask operations

# Often we need to extract the pixel values within a mask:

ig = ImageGeom(MaskAllButEdge() ; dims=(6,4))
x = 1:size(ig,1)
y = 1:size(ig,2)
ramp = x .+ 10*y'

ig.mask

core = ramp[ig.mask]

# Or equivalently:
maskit(ramp, ig.mask)

# Conversely, we can `embed` that list of pixels back into an array:
array = embed(core, ig.mask)


# There are in-place versions of these two operations:
core = Array{Float32}(undef, sum(ig.mask))
getindex!(core, ramp, ig.mask)

#
array = collect(zeros(Float16, ig))
embed!(array, core, ig.mask)


#=
## Mask outline
Sometimes we need the outline of the mask.
=#
ig = ImageGeom(MaskCircle() ; dims=(40,32))
outline = mask_outline(ig.mask)
jim(
 jim(ig.mask, "Mask"; prompt=false),
 jim(outline, "Outline"; prompt=false),
)
