# ImageGeoms.jl

https://github.com/JuliaImageRecon/ImageGeoms.jl

[![docs-stable][docs-stable-img]][docs-stable-url]
[![docs-dev][docs-dev-img]][docs-dev-url]
[![action status][action-img]][action-url]
[![pkgeval status][pkgeval-img]][pkgeval-url]
[![codecov][codecov-img]][codecov-url]
[![license][license-img]][license-url]
[![Aqua QA][aqua-img]][aqua-url]
[![code-style][code-blue-img]][code-blue-url]

This Julia package exports the type `ImageGeom`
and corresponding constructor methods.
It is useful for describing
the pixel or voxel grid
for tomographic image reconstruction.

For an explanation see the documentation
using the blue "docs" links above.

### Getting started

```julia
using Pkg
Pkg.add("ImageGeoms")
```


### Example

```julia
using ImageGeoms
ig2d = ImageGeom((128,128), (1,1), (0,0))
ig3d = ImageGeom( dims=(128,128,64), deltas=(1,1,2), offsets=(0,0,0) )
```

### Documentation

For more examples with graphics,
see the
[documentation](https://juliaimagerecon.github.io/ImageGeoms.jl/stable).


### Dependents

* [Michigan Image Reconstruction Toolbox (MIRT)](https://github.com/JeffFessler/MIRT.jl)
* [ImagePhantoms.jl](https://github.com/JuliaImageRecon/ImagePhantoms.jl)
* [Sinograms.jl](https://github.com/JuliaImageRecon/Sinograms.jl)
* [SPECTrecon.jl](https://github.com/JuliaImageRecon/SPECTrecon.jl)
* See [juliahub](https://juliahub.com/ui/Search?q=ImageGeoms&type=packages)


### Related packages

* [AxisArrays](https://github.com/JuliaArrays/AxisArrays.jl)
* [ImageAxes](https://github.com/JuliaImages/ImageAxes.jl)
* [LazyGrids](https://github.com/JuliaArrays/LazyGrids.jl)


### Compatibility

Tested with Julia ≥ 1.10.

<!-- URLs -->
[action-img]: https://github.com/JuliaImageRecon/ImageGeoms.jl/workflows/CI/badge.svg
[action-url]: https://github.com/JuliaImageRecon/ImageGeoms.jl/actions
[build-img]: https://github.com/JuliaImageRecon/ImageGeoms.jl/workflows/CI/badge.svg?branch=main
[build-url]: https://github.com/JuliaImageRecon/ImageGeoms.jl/actions?query=workflow%3ACI+branch%3Amain
[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageGeoms.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageGeoms.html
[code-blue-img]: https://img.shields.io/badge/code%20style-blue-4495d1.svg
[code-blue-url]: https://github.com/invenia/BlueStyle
[codecov-img]: https://codecov.io/github/JuliaImageRecon/ImageGeoms.jl/coverage.svg?branch=main
[codecov-url]: https://codecov.io/github/JuliaImageRecon/ImageGeoms.jl?branch=main
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JuliaImageRecon.github.io/ImageGeoms.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://JuliaImageRecon.github.io/ImageGeoms.jl/dev
[license-img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
[license-url]: LICENSE
[aqua-img]: https://img.shields.io/badge/Aqua.jl-%F0%9F%8C%A2-aqua.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl
