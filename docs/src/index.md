```@meta
CurrentModule = Talos
```

```@raw html
<p align="center">
  <img src="assets/logo.jpg" alt="Talos.jl" width="280">
</p>
```

Transformaciones homogéneas y rotaciones para robótica en Julia.

## Instalación

```julia
using Pkg
Pkg.add(url="https://github.com/kyma-un/Talos.jl")
```

## Quickstart

```julia
using Talos
using StaticArrays

T = Se2(1.0, 2.0, π/2)
p = T * @SVector [1.0, 0.0, 1.0]

H = Se3(T)
q = H * @SVector [1.0, 0.0, 0.0, 1.0]

R = Rotz(90; deg=true)
```

Para dibujar el marco de `H`, carga un backend de Makie:

```julia
using GLMakie
trplot(H)
```
