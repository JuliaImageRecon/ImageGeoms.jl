# ImageGeoms.jl

https://github.com/JuliaImageRecon/ImageGeoms.jl

[![docs-stable][docs-stable-img]][docs-stable-url]
[![docs-dev][docs-dev-img]][docs-dev-url]
[![action][action-img]][action-url]
[![Aqua QA][aqua-img]][aqua-url]
[![codecov][codecov-img]][codecov-url]
[![deps][deps-img]][deps-url]
[![license][license-img]][license-url]
[![pkgeval][pkgeval-img]][pkgeval-url]
[![version][ver-img]][ver-url]


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

Tested with Julia ≥ 1.12.

<!-- URLs -->
[action-img]: https://github.com/JuliaImageRecon/ImageGeoms.jl/workflows/CI/badge.svg
[action-url]: https://github.com/JuliaImageRecon/ImageGeoms.jl/actions

[aqua-img]: https://juliatesting.github.io/Aqua.jl/dev/assets/badge.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl

[code-blue-img]: https://img.shields.io/badge/code%20style-blue-4495d1.svg
[code-blue-url]: https://github.com/invenia/BlueStyle

[codecov-img]: https://codecov.io/github/JuliaImageRecon/ImageGeoms.jl/coverage.svg
[codecov-url]: https://codecov.io/github/JuliaImageRecon/ImageGeoms.jl

[deps-img]: https://juliahub.com/docs/ImageGeoms/deps.svg
[deps-url]: https://juliahub.com/ui/Packages/ImageGeoms

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://JuliaImageRecon.github.io/ImageGeoms.jl/dev
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JuliaImageRecon.github.io/ImageGeoms.jl/stable

[license-img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
[license-url]: LICENSE

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageGeoms.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageGeoms.html

[ver-img]: https://juliahub.com/docs/ImageGeoms/version.svg
[ver-url]: https://juliahub.com/ui/Packages/ImageGeoms
