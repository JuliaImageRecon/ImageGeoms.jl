#=
# [ImageGeoms overview](@id 1-overview)

This page explains the Julia package
[`ImageGeoms`](https://github.com/JuliaImageRecon/ImageGeoms.jl).
=#

#srcURL


# ### Setup

# Packages needed here.

using ImageGeoms: ImageGeom, axis, axisf, axesf, downsample, grids, oversample
import ImageGeoms # ellipse
using AxisArrays
using MIRTjim: jim, prompt
using Plots: scatter, plot!, default; default(markerstrokecolor=:auto)
using Unitful: mm, s
using InteractiveUtils: versioninfo


# The following line is helpful when running this file as a script;
# this way it will prompt user to hit a key after each figure is displayed.

isinteractive() ? jim(:prompt, true) : prompt(:draw);

#=
## Overview

When performing tomographic image reconstruction,
one must specify the geometry of the grid of image pixels.
(In contrast, for image denoising and image deblurring problems,
one works with the given discrete image
and no physical coordinates are needed.)

The key parameters of a grid of image pixels are
* the size (dimensions) of the grid, e.g., `128 × 128`,
* the spacing of the pixels, e.g., `1mm × 1mm`,
* the offset of the pixels relative to the origin, e.g., `(0,0)`

The data type `ImageGeom` describes such a geometry,
for arbitrary dimensions (2D, 3D, etc.).

There are several ways to construct this structure.
The default is a `128 × 128` grid
with pixel size ``\Delta_X = \Delta_Y = 1`` (unitless) and zero offset:
=#

ig = ImageGeom()


# Here is a 3D example with non-cubic voxel size:

ig = ImageGeom( (512,512,128), (1,1,2), (0,0,0) )


# To avoid remembering the order of the arguments,
# named keyword pairs are also supported:

ig = ImageGeom( dims=(512,512,128), deltas=(1,1,2), offsets=(0,0,0) )


#=
## Units
#
The pixel dimensions `deltas` can (and should!) be values with units.

Here is an example for a video (2D+time) with 12 frames per second:
=#

ig = ImageGeom( dims=(640,480,1000), deltas=(1mm,1mm,(1//12)s) )


#=
## Methods

An ImageGeom object has quite a few methods;
`axes` and `axis` are especially useful:
=#

ig = ImageGeom( dims=(7,8), deltas=(3,2), offsets=(0,0.5) )
axis(ig, 2)


#=
or an axis of length `n` with spacing `Δ` (possibly with units)
and (always unitless but possibly non-integer) `offset` the axis
is a subtype of `AbstractRange` of the form
`( (0:n-1) .- ((n - 1)/2 + offset) ) * Δ`

These axes are useful for plotting:
=#

ig = ImageGeom( dims=(10,8), deltas=(1mm,1mm), offsets=(0.5,0.5) )


#
_ticks(x, off) = [x[1]; # hopefully helpful tick marks
    iseven(length(x)) && iszero(off) ?
        oneunit(eltype(x)) * [-0.5,0.5] : zero(eltype(x)); x[end]]
showgrid = (ig) -> begin # x,y grid locations of pixel centers
    x = axis(ig, 1)
    y = axis(ig, 2)
    (xg, yg) = grids(ig)
    scatter(xg, yg; label="", xlabel="x", ylabel="y",
        xlims = extrema(x) .+ (ig.deltas[1] * 0.5) .* (-1,1),
        xticks = _ticks(x, ig.offsets[1]),
        ylims = extrema(y) .+ (ig.deltas[2] * 0.5) .* (-1,1),
        yticks = _ticks(y, ig.offsets[2]),
        widen = true, aspect_ratio = 1, title = "offsets $(ig.offsets)")
end
showgrid(ig)


# Axes labels can have units
prompt()


#=
## Offsets (unitless translation of grid)

The default `offsets` are zeros,
corresponding to symmetric sampling around origin:
=#

ig = ImageGeom( dims=(12,10), deltas=(1mm,1mm) )
p = showgrid(ig)

#
prompt();


# That default for `offsets` is natural for tomography
# when considering finite pixel size:

square = (x,y,Δ,p) -> plot!(p, label="", color=:black,
    x .+ Δ[1] * ([0,1,1,0,0] .- 0.5),
    y .+ Δ[2] * ([0,0,1,1,0] .- 0.5),
)
square2 = (x,y) -> square(x, y, ig.deltas, p)
square2.(grids(ig)...)
plot!(p)


#
prompt();


#=
In that default geometry, the center `(0,0)` of the image
is at a corner of the middle 4 pixels (for even image sizes).
That default is typical for tomographic imaging (e.g., CT, PET, SPECT).
One must be careful when using operations like `imrotate` or `fft`.
=#


#=
## Odd dimensions
If an image axis has an odd dimension,
then each middle pixel along that axis
is centered at 0,
for the default `offset=0`.
=#

igo = ImageGeom( dims=(7,6) )
po = showgrid(igo)
square2 = (x,y) -> square(x, y, igo.deltas, po)
square2.(grids(igo)...)
plot!(po)

#
prompt();


# ## AxisArrays

#=
There is a natural connection between `ImageGeom` and `AxisArrays`.
Note the automatic labeling of units (when relevant) on all axes by
[MIRTjim.jim](https://github.com/JeffFessler/MIRTjim.jl).
=#

ig = ImageGeom( dims=(60,48), deltas=(1.5mm,1mm) )
za = AxisArray( ImageGeoms.ellipse(ig) * 10/mm ; x=axis(ig,1), y=axis(ig,2) )
jim(za, "AxisArray example")

#
prompt();


#=
## Resizing

Often we have a target grid in mind but want coarser sampling for debugging.
The `downsample` method is useful for this.
=#

ig = ImageGeom( dims = (512,512), deltas = (500mm,500mm) ./ 512 )
ig_down = downsample(ig, 4)


# Other times we want to avoid an "inverse crime" by using finer sampling
# to simulate data; use `oversample` for this.

ig_over = oversample(ig, (2,2))


#=
## Frequency domain axes
For related packages like
[`ImagePhantoms`](https://github.com/JuliaImageRecon/ImagePhantoms.jl),
there are also `axisf` and `axesf` methods
that return the frequency axes
associated with an FFT-based approximation
to a Fourier transform,
where ``Δ_f Δ_X = 1/N.``
=#
ig = ImageGeom( dims=(4,5), deltas=(1mm,1mm) )
axesf(ig)

#
axisf(ig, 1)

#
axisf(ig, 2)


include("../../../inc/reproduce.jl")
