# ImageGeoms.jl

https://github.com/JuliaImageRecon/ImageGeoms.jl

[![action status][action-img]][action-url]
[![pkgeval status][pkgeval-img]][pkgeval-url]
[![codecov][codecov-img]][codecov-url]
[![license][license-img]][license-url]
[![docs-stable][docs-stable-img]][docs-stable-url]
[![docs-dev][docs-dev-img]][docs-dev-url]
[![code-style][code-blue-img]][code-blue-url]

This repo exports the type `ImageGeom`
and corresponding constructor methods.

For an explanation see the

## Getting started

```julia
using Pkg
Pkg.add("ImageGeoms")
```


## Example

```julia
using ImageGeoms
ig2d = ImageGeom((128,128), (1,1), (0,0))
ig3d = ImageGeom( dims=(128,128,64), deltas=(1,1,2), offsets=(0,0,0) )
```

For more examples with graphics,
see the
[documentation](https://juliaimagerecon.github.io/ImageGeoms.jl/stable).


Used in the following packages
* [Michigan Image Reconstruction Toolbox (MIRT)](https://github.com/JeffFessler/MIRT.jl)
* [Sinograms.jl](https://github.com/todo/Sinograms.jl)
* [SPECTrecon.jl](https://github.com/todo/SPECTrecon.jl)


### Compatibility

Tested with Julia ≥ 1.6.

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
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat
[license-url]: LICENSE
