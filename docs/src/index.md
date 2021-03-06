```@meta
CurrentModule = ImageGeoms
```

# ImageGeoms.jl Documentation

## Overview

This Julia package
[ImageGeoms.jl](https://github.com/JuliaImageRecon/ImageGeoms.jl)
exports a composite type `ImageGeom`
and corresponding constructors
for describing the image sampling geometry
for (typically tomographic) image reconstruction.
It allows one to specify a pixel or voxel grid
in terms of the dimensions and spacing,
optionally with physical units.

See the "Examples" for details.

The
[Michigan Image Reconstruction Toolbox (MIRT)](https://github.com/JeffFessler/MIRT.jl)
currently has an older interface `image_geom`
similar to the function of the same name in the
[Matlab version of MIRT](https://github.com/JeffFessler/mirt)
provided for backward compatibility.
Using `ImageGeom` is recommended for Julia work.
