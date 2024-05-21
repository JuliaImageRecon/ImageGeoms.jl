var documenterSearchIndex = {"docs":
[{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"EditURL = \"../../../lit/examples/2-mask.jl\"","category":"page"},{"location":"generated/examples/2-mask/#2-mask","page":"Support mask","title":"Support mask","text":"","category":"section"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"This page explains the mask aspects of the Julia package ImageGeoms.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"This page comes from a single Julia file: 2-mask.jl.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"You can access the source code for such Julia documentation using the 'Edit on GitHub' link in the top right. You can view the corresponding notebook in nbviewer here: 2-mask.ipynb, or open it in binder here: 2-mask.ipynb.","category":"page"},{"location":"generated/examples/2-mask/#Setup","page":"Support mask","title":"Setup","text":"","category":"section"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Packages needed here.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"using ImageGeoms: ImageGeom, MaskCircle, MaskAllButEdge\nusing ImageGeoms: maskit, embed, embed!, getindex! # +jim +size\nusing ImageGeoms: mask_outline\nusing MIRTjim: jim, prompt\nusing Unitful: mm","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"The following line is helpful when running this file as a script; this way it will prompt user to hit a key after each figure is displayed.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"isinteractive() ? jim(:prompt, true) : prompt(:draw);\nnothing #hide","category":"page"},{"location":"generated/examples/2-mask/#Mask-overview","page":"Support mask","title":"Mask overview","text":"","category":"section"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"In tomographic image reconstruction, patients are usually more \"round\" than \"square\" so often we only want to estimate the pixels inside some support mask: a Bool array indicating which pixels are to be estimated. (The rest are constrained to be zero.) The ImageGeom struct has an entry to store this mask. The default is Trues(dims) which is a \"lazy\" Bool AbstractArray from the FillArrays package that is conceptually similar to trues(dims) but requires O(1) storage.  So there is essentially no memory penalty to storing this entry in the ImageGeom for users who do not want to think about a mask. For users who do want a mask, fortunately Julia uses a special BitArray type to store Bool arrays, so the storage is 8× less than using bytes in most other languages.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Often we use a \"circle inscribed in the square\" as a generic support mask, and one of the built-in constructors can generate such a circular mask:","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"ig = ImageGeom(MaskCircle() ; dims=(40,32), deltas=(1mm,1mm))","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"That last line shows that 716 of 1280=40*32 mask pixels are nonzero.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"jim(ig)","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Note that jim displays the axes with the units naturally; see MIRTjim.jl.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"A 3D mask can be hard to visualize, so there is a mask_or method that collapses it to 2D:","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"ig = ImageGeom(MaskAllButEdge() ; dims=(32,32,16))\n\njim(ig)","category":"page"},{"location":"generated/examples/2-mask/#Mask-operations","page":"Support mask","title":"Mask operations","text":"","category":"section"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Often we need to extract the pixel values within a mask:","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"ig = ImageGeom(MaskAllButEdge() ; dims=(6,4))\nx = 1:size(ig,1)\ny = 1:size(ig,2)\nramp = x .+ 10*y'\n\nig.mask\n\ncore = ramp[ig.mask]","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Or equivalently:","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"maskit(ramp, ig.mask)","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Conversely, we can embed that list of pixels back into an array:","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"array = embed(core, ig.mask)","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"There are in-place versions of these two operations:","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"core = Array{Float32}(undef, sum(ig.mask))\ngetindex!(core, ramp, ig.mask)","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"array = collect(zeros(Float16, ig))\nembed!(array, core, ig.mask)","category":"page"},{"location":"generated/examples/2-mask/#Mask-outline","page":"Support mask","title":"Mask outline","text":"","category":"section"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"Sometimes we need the outline of the mask.","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"ig = ImageGeom(MaskCircle() ; dims=(40,32))\noutline = mask_outline(ig.mask)\njim(\n jim(ig.mask, \"Mask\"; prompt=false),\n jim(outline, \"Outline\"; prompt=false),\n)","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"","category":"page"},{"location":"generated/examples/2-mask/","page":"Support mask","title":"Support mask","text":"This page was generated using Literate.jl.","category":"page"},{"location":"methods/#Methods-list","page":"Methods","title":"Methods list","text":"","category":"section"},{"location":"methods/","page":"Methods","title":"Methods","text":"","category":"page"},{"location":"methods/#Methods-usage","page":"Methods","title":"Methods usage","text":"","category":"section"},{"location":"methods/","page":"Methods","title":"Methods","text":"Modules = [ImageGeoms]","category":"page"},{"location":"methods/#ImageGeoms.ImageGeoms","page":"Methods","title":"ImageGeoms.ImageGeoms","text":"ImageGeoms\n\nModule for describing image geometries.\n\n\n\n\n\n","category":"module"},{"location":"methods/#ImageGeoms.ImageGeom","page":"Methods","title":"ImageGeoms.ImageGeom","text":"ImageGeom{D,S,M}\n\nImage geometry struct with essential grid parameters.\n\ndims::Dims{D} image dimensions\ndeltas::S where S <: NTuple{D} pixel sizes, where each Δ is usually Real or Unitful.Length\noffsets::NTuple{D,Float32} unitless\nmask::M where M <: AbstractArray{Bool,D} logical mask, often FillArrays.Trues(dims).\n\n\n\n\n\n","category":"type"},{"location":"methods/#ImageGeoms.ImageGeom-Tuple{Mask}","page":"Methods","title":"ImageGeoms.ImageGeom","text":"ig = ImageGeom(masktype::Mask ; kwargs...)\n\nConstructor with specified mask, e.g., ImageGeom(MaskCircle() ; dims=(6,8)).\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.ImageGeom-Union{Tuple{M}, Tuple{S}, Tuple{D}, Tuple{Tuple{Vararg{Int64, D}}, S, Union{Symbol, Tuple{Vararg{Real, D}}}, M}} where {D, S<:Tuple{Vararg{Number, D}}, M<:AbstractArray{Bool, D}}","page":"Methods","title":"ImageGeoms.ImageGeom","text":"ig = ImageGeom(dims::Dims, deltas, offsets, [, mask])\n\nConstructor for ImageGeom of dimensions dims.\n\nThe deltas elements (tuple of grid spacings) should each be Real or a Unitful.Length; default (1,…,1).\nThe offsets (tuple of grid offsets) must be unitless;  default (0,…,0).\nThe dims, deltas and offsets tuples must be same length.\nDefault mask is FillArrays.Trues(dims) which is akin to trues(dims).\n\nUsing offsets = :dsp means offsets = 0.5 .* iseven.(dims).\n\nExample\n\njulia> ImageGeom((5,7), (2.,3.))\nImageGeom{2, NTuple{2,Float64}, FillArrays.Trues{2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}}\n dims::NTuple{2,Int64} (5, 7)\n deltas::NTuple{2,Float64} (2.0, 3.0)\n offsets::NTuple{2,Float32} (0.0f0, 0.0f0)\n mask: 5×7 Ones{Bool} {35 of 35}\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.ImageGeom-Union{Tuple{}, Tuple{M}, Tuple{D}} where {D, M<:(AbstractArray{Bool})}","page":"Methods","title":"ImageGeoms.ImageGeom","text":"ig = ImageGeom( ; dims=(nx,ny), deltas=(1,1), offsets=(0,0), mask=Trues )\n\nConstructor using named keywords. One can use fovs as an alternate keyword, in which case deltas = fovs ./ dims. The keyword fov applies to all dimensions.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.Mask","page":"Methods","title":"ImageGeoms.Mask","text":"Mask\n\nAbstract type for describing the support of an image (i.e., which pixels will be reconstructed in solving an inverse problem).\n\n\n\n\n\n","category":"type"},{"location":"methods/#Base.show-Union{Tuple{D}, Tuple{IO, MIME{Symbol(\"text/plain\")}, ImageGeom{D, S, M} where {S<:Tuple{Vararg{Number, D}}, M<:AbstractArray{Bool, D}}}} where D","page":"Methods","title":"Base.show","text":"show(io::IO, ::MIME\"text/plain\", ig::ImageGeom)\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.downsample!-Union{Tuple{D}, Tuple{BitArray{D}, Union{BitArray{D}, AbstractArray{Bool, D}}, Tuple{Vararg{Int64, D}}}} where D","page":"Methods","title":"ImageGeoms.downsample!","text":"downsample!(y, x, down::NTuple{Int})\n\nNon-allocating version of y = downsample(x, down). Requires size(y) = ceil(size(x) / down).\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.downsample-Union{Tuple{D}, Tuple{Union{BitArray{D}, AbstractArray{Bool, D}}, Tuple{Vararg{Int64, D}}}} where D","page":"Methods","title":"ImageGeoms.downsample","text":"y = downsample(x, down::NTuple{Int})\n\nDown-sample a Bool array x by \"max pooling\" in all dimensions. Output size will be ceil(size(x) / down). Thus, in a typical case where size(x) is integer multiple of down, the output size will be size(x) ÷ down.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.downsample-Union{Tuple{M}, Tuple{S}, Tuple{D}, Tuple{ImageGeom{D, S, M}, Tuple{Vararg{Int64, D}}}} where {D, S, M}","page":"Methods","title":"ImageGeoms.downsample","text":"ig_down = downsample(ig, down::Tuple{Int})\n\nDown sample an image geometry by the factor down. Image size ig.dims must be ≥ down. cf image_geom_downsample.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.ellipse-Tuple{ImageGeom{2, S, M} where {S<:Tuple{Number, Number}, M<:AbstractMatrix{Bool}}}","page":"Methods","title":"ImageGeoms.ellipse","text":"ellipse(ig::ImageGeom{2} ; ...)\n\nEllipse that just inscribes the rectangle, but keeping a 1 pixel border due to some regularizer limitations.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.embed!-Union{Tuple{D}, Tuple{T}, Tuple{AbstractArray{T, D}, AbstractVector{<:Number}, AbstractArray{Bool, D}}} where {T, D}","page":"Methods","title":"ImageGeoms.embed!","text":"embed!(array, v, mask ; filler=0)\n\nEmbed vector v of length count(mask) into elements of array where mask is true, setting the remaining elements to filler (default 0).\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.embed-Tuple{AbstractMatrix{<:Number}, AbstractArray{Bool}}","page":"Methods","title":"ImageGeoms.embed","text":"array = embed(matrix::AbstractMatrix{<:Number}, mask::AbstractArray{Bool})\n\nEmbed each column of matrix into mask then cat along next dimension\n\nIn:\n\nmatrix [count(mask) L]\nmask [(N)]\n\nOut:\n\narray [(N) L]\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.embed-Union{Tuple{T}, Tuple{AbstractVector{T}, AbstractArray{Bool}}} where T<:Number","page":"Methods","title":"ImageGeoms.embed","text":"array = embed(v, mask ; filler=0)\n\nEmbed vector v of length count(mask) into elements of an array where mask is true; see embed!.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.expand_nz-Union{Tuple{M}, Tuple{S}, Tuple{ImageGeom{3, S, M}, Int64}} where {S, M}","page":"Methods","title":"ImageGeoms.expand_nz","text":"ig_new = expand_nz(ig::ImageGeom{3}, nz_pad::Int)\n\nPad both ends along z.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.fovs-Tuple{ImageGeom}","page":"Methods","title":"ImageGeoms.fovs","text":"fovs(ig::ImageGeom) = ig.dims .* ig.deltas\n\nReturn tuple of the field of view (FOV) values for all D axes.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.getindex!-Union{Tuple{D}, Tuple{T}, Tuple{AbstractVector, AbstractArray{T, D}, AbstractArray{Bool, D}}} where {T, D}","page":"Methods","title":"ImageGeoms.getindex!","text":"getindex!(y::AbstractVector, x::AbstractArray{T,D}, mask::AbstractArray{Bool,D})\n\nEquivalent to the in-place y .= x[mask] but is non-allocating.\n\nFor non-Boolean indexing, just use @views y .= A[index], per https://discourse.julialang.org/t/efficient-non-allocating-in-place-getindex-for-bitarray/42268\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.mask_or-Tuple{AbstractMatrix{Bool}}","page":"Methods","title":"ImageGeoms.mask_or","text":"mask_or(mask)\n\ncompress 3D mask to 2D by logical or along z direction\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.mask_outline-Tuple{AbstractMatrix{Bool}}","page":"Methods","title":"ImageGeoms.mask_outline","text":"mask_outline(mask)\n\nReturn outer boundary of 2D mask (or mask_or for 3D).\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.maskit-Tuple{AbstractArray, AbstractArray{Bool}}","page":"Methods","title":"ImageGeoms.maskit","text":"maskit(x::AbstractArray{<:Number}, mask)\n\nopposite of embed\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.oversample-Union{Tuple{S}, Tuple{D}, Tuple{ImageGeom{D, S, M} where M<:AbstractArray{Bool, D}, Tuple{Vararg{Int64, D}}}} where {D, S}","page":"Methods","title":"ImageGeoms.oversample","text":"ig_over = oversample(ig::ImageGeom, over::Int or NTuple)\n\nOver-sample an image geometry by the factor over.\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.upsample!-Union{Tuple{D}, Tuple{BitArray{D}, Union{BitArray{D}, AbstractArray{Bool, D}}, Tuple{Vararg{Int64, D}}}} where D","page":"Methods","title":"ImageGeoms.upsample!","text":"upsample!(y, x, up::NTuple{Int})\n\nNon-allocating version of y = upsample(x, up). Requires size(y) = ceil(size(x) * up).\n\n\n\n\n\n","category":"method"},{"location":"methods/#ImageGeoms.upsample-Union{Tuple{D}, Tuple{Union{BitArray{D}, AbstractArray{Bool, D}}, Tuple{Vararg{Int64, D}}}} where D","page":"Methods","title":"ImageGeoms.upsample","text":"y = upsample(x, up::NTuple{Int})\n\nUp-sample a Bool array x by \"repeating\" in all dimensions. Output size will be size(x) * up.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ImageGeoms","category":"page"},{"location":"#ImageGeoms.jl-Documentation","page":"Home","title":"ImageGeoms.jl Documentation","text":"","category":"section"},{"location":"#Overview","page":"Home","title":"Overview","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This Julia package ImageGeoms.jl exports a composite type ImageGeom and corresponding constructors for describing the image sampling geometry for (typically tomographic) image reconstruction. It allows one to specify a pixel or voxel grid in terms of the dimensions and spacing, optionally with physical units.","category":"page"},{"location":"","page":"Home","title":"Home","text":"See the \"Examples\" for details.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The Michigan Image Reconstruction Toolbox (MIRT) currently has an older interface image_geom similar to the function of the same name in the Matlab version of MIRT provided for backward compatibility. Using ImageGeom is recommended for Julia work.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"EditURL = \"../../../lit/examples/1-overview.jl\"","category":"page"},{"location":"generated/examples/1-overview/#1-overview","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"This page explains the Julia package ImageGeoms.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"This page comes from a single Julia file: 1-overview.jl.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"You can access the source code for such Julia documentation using the 'Edit on GitHub' link in the top right. You can view the corresponding notebook in nbviewer here: 1-overview.ipynb, or open it in binder here: 1-overview.ipynb.","category":"page"},{"location":"generated/examples/1-overview/#Setup","page":"ImageGeoms overview","title":"Setup","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"Packages needed here.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"using ImageGeoms: ImageGeom, axis, axisf, axesf, downsample, grids, oversample\nimport ImageGeoms # ellipse\nusing AxisArrays\nusing MIRTjim: jim, prompt\nusing Plots: scatter, plot!, default; default(markerstrokecolor=:auto)\nusing Unitful: mm, s\nusing InteractiveUtils: versioninfo","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"The following line is helpful when running this file as a script; this way it will prompt user to hit a key after each figure is displayed.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"isinteractive() ? jim(:prompt, true) : prompt(:draw);\nnothing #hide","category":"page"},{"location":"generated/examples/1-overview/#Overview","page":"ImageGeoms overview","title":"Overview","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"When performing tomographic image reconstruction, one must specify the geometry of the grid of image pixels. (In contrast, for image denoising and image deblurring problems, one works with the given discrete image and no physical coordinates are needed.)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"The key parameters of a grid of image pixels are","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"the size (dimensions) of the grid, e.g., 128 × 128,\nthe spacing of the pixels, e.g., 1mm × 1mm,\nthe offset of the pixels relative to the origin, e.g., (0,0)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"The data type ImageGeom describes such a geometry, for arbitrary dimensions (2D, 3D, etc.).","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"There are several ways to construct this structure. The default is a 128 × 128 grid with pixel size Delta_X = Delta_Y = 1 (unitless) and zero offset:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom()","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"Here is a 3D example with non-cubic voxel size:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( (512,512,128), (1,1,2), (0,0,0) )","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"To avoid remembering the order of the arguments, named keyword pairs are also supported:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(512,512,128), deltas=(1,1,2), offsets=(0,0,0) )","category":"page"},{"location":"generated/examples/1-overview/#Units","page":"ImageGeoms overview","title":"Units","text":"","category":"section"},{"location":"generated/examples/1-overview/#","page":"ImageGeoms overview","title":"","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"The pixel dimensions deltas can (and should!) be values with units.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"Here is an example for a video (2D+time) with 12 frames per second:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(640,480,1000), deltas=(1mm,1mm,(1//12)s) )","category":"page"},{"location":"generated/examples/1-overview/#Methods","page":"ImageGeoms overview","title":"Methods","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"An ImageGeom object has quite a few methods; axes and axis are especially useful:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(7,8), deltas=(3,2), offsets=(0,0.5) )\naxis(ig, 2)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"or an axis of length n with spacing Δ (possibly with units) and (always unitless but possibly non-integer) offset the axis is a subtype of AbstractRange of the form ( (0:n-1) .- ((n - 1)/2 + offset) ) * Δ","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"These axes are useful for plotting:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(10,8), deltas=(1mm,1mm), offsets=(0.5,0.5) )","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"_ticks(x, off) = [x[1]; # hopefully helpful tick marks\n    iseven(length(x)) && iszero(off) ?\n        oneunit(eltype(x)) * [-0.5,0.5] : zero(eltype(x)); x[end]]\nshowgrid = (ig) -> begin # x,y grid locations of pixel centers\n    x = axis(ig, 1)\n    y = axis(ig, 2)\n    (xg, yg) = grids(ig)\n    scatter(xg, yg; label=\"\", xlabel=\"x\", ylabel=\"y\",\n        xlims = extrema(x) .+ (ig.deltas[1] * 0.5) .* (-1,1),\n        xticks = _ticks(x, ig.offsets[1]),\n        ylims = extrema(y) .+ (ig.deltas[2] * 0.5) .* (-1,1),\n        yticks = _ticks(y, ig.offsets[2]),\n        widen = true, aspect_ratio = 1, title = \"offsets $(ig.offsets)\")\nend\nshowgrid(ig)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"Axes labels can have units","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"prompt()","category":"page"},{"location":"generated/examples/1-overview/#Offsets-(unitless-translation-of-grid)","page":"ImageGeoms overview","title":"Offsets (unitless translation of grid)","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"The default offsets are zeros, corresponding to symmetric sampling around origin:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(12,10), deltas=(1mm,1mm) )\np = showgrid(ig)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"prompt();\nnothing #hide","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"That default for offsets is natural for tomography when considering finite pixel size:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"square = (x,y,Δ,p) -> plot!(p, label=\"\", color=:black,\n    x .+ Δ[1] * ([0,1,1,0,0] .- 0.5),\n    y .+ Δ[2] * ([0,0,1,1,0] .- 0.5),\n)\nsquare2 = (x,y) -> square(x, y, ig.deltas, p)\nsquare2.(grids(ig)...)\nplot!(p)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"prompt();\nnothing #hide","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"In that default geometry, the center (0,0) of the image is at a corner of the middle 4 pixels (for even image sizes). That default is typical for tomographic imaging (e.g., CT, PET, SPECT). One must be careful when using operations like imrotate or fft.","category":"page"},{"location":"generated/examples/1-overview/#Odd-dimensions","page":"ImageGeoms overview","title":"Odd dimensions","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"If an image axis has an odd dimension, then each middle pixel along that axis is centered at 0, for the default offset=0.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"igo = ImageGeom( dims=(7,6) )\npo = showgrid(igo)\nsquare2 = (x,y) -> square(x, y, igo.deltas, po)\nsquare2.(grids(igo)...)\nplot!(po)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"prompt();\nnothing #hide","category":"page"},{"location":"generated/examples/1-overview/#AxisArrays","page":"ImageGeoms overview","title":"AxisArrays","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"There is a natural connection between ImageGeom and AxisArrays. Note the automatic labeling of units (when relevant) on all axes by MIRTjim.jim.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(60,48), deltas=(1.5mm,1mm) )\nza = AxisArray( ImageGeoms.ellipse(ig) * 10/mm ; x=axis(ig,1), y=axis(ig,2) )\njim(za, \"AxisArray example\")","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"prompt();\nnothing #hide","category":"page"},{"location":"generated/examples/1-overview/#Resizing","page":"ImageGeoms overview","title":"Resizing","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"Often we have a target grid in mind but want coarser sampling for debugging. The downsample method is useful for this.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims = (512,512), deltas = (500mm,500mm) ./ 512 )\nig_down = downsample(ig, 4)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"Other times we want to avoid an \"inverse crime\" by using finer sampling to simulate data; use oversample for this.","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig_over = oversample(ig, (2,2))","category":"page"},{"location":"generated/examples/1-overview/#Frequency-domain-axes","page":"ImageGeoms overview","title":"Frequency domain axes","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"For related packages like ImagePhantoms, there are also axisf and axesf methods that return the frequency axes associated with an FFT-based approximation to a Fourier transform, where Δ_f Δ_X = 1N","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"ig = ImageGeom( dims=(4,5), deltas=(1mm,1mm) )\naxesf(ig)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"axisf(ig, 1)","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"axisf(ig, 2)","category":"page"},{"location":"generated/examples/1-overview/#Reproducibility","page":"ImageGeoms overview","title":"Reproducibility","text":"","category":"section"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"This page was generated with the following version of Julia:","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"using InteractiveUtils: versioninfo\nio = IOBuffer(); versioninfo(io); split(String(take!(io)), '\\n')","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"And with the following package versions","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"import Pkg; Pkg.status()","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"","category":"page"},{"location":"generated/examples/1-overview/","page":"ImageGeoms overview","title":"ImageGeoms overview","text":"This page was generated using Literate.jl.","category":"page"}]
}
