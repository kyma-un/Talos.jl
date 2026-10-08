<p align="center">
  <img src="docs/src/assets/logo.jpg" alt="Talos.jl" width="280">
</p>

<p align="center">
  <a href="https://github.com/kyma-un/JuliaRobTB/actions/workflows/CI.yml"><img src="https://github.com/kyma-un/JuliaRobTB/actions/workflows/CI.yml/badge.svg?branch=main" alt="Build Status"></a>
  <a href="https://kyma-un.github.io/JuliaRobTB/dev"><img src="https://img.shields.io/badge/docs-dev-blue.svg" alt="Documentation"></a>
</p>

<p align="center">
  Transformaciones homogéneas y rotaciones para robótica en Julia.
</p>

## Quickstart

```julia
using Pkg
Pkg.add(url="https://github.com/kyma-un/Talos.jl")

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

### Animar marcos de referencia

`tranimate` es un `trplot` animado (sin interfaz gráfica; funciona en Pluto con `WGLMakie`),
y `trframes_gui` abre una interfaz donde se añaden N cuerpos y se escribe la traslación y
rotación deseadas:

```julia
using GLMakie
Ta = Se3(2.0, 0.0, 0.0, 0, 0, 90.0; deg=true)   # x y z roll pitch yaw
Tb = Se2(-1.5, 1.0, π/3)

tranimate([Ta, Tb]; mode=:rot_then_trans)       # Figure con slider y botón ▶
tranimate([Ta, Tb]; record="anim.mp4")          # graba un vídeo
Trinterp(Ta, Tb, 0.5)                           # pose intermedia hacia una pose ABSOLUTA (s ∈ [0,1])

# Movimiento RELATIVO: el orden de composición importa (pre vs post-multiplicación)
M = ([1.0, 2.0, 0.0], Rotz(90; deg=true))        # trasladar d y rotar Q
Trmove(Ta, M...,  1.0; frame=:body,  order=:trans_then_rot)   # Ta * Transl(d) * Rot(Q)
Trmove(Ta, M...,  1.0; frame=:world, order=:trans_then_rot)   # Rot(Q) * Transl(d) * Ta
tranimate_move(Ta, M; frame=:world, order=:rot_then_trans)    # lo anima

wait(display(trframes_gui()))                   # interfaz gráfica
```

Ver `examples/tranimate.jl`, `examples/trframes_gui.jl` y el notebook `examples/pluto_tranimate.jl`.

En un clon local:

```julia
using Pkg
Pkg.develop(path=".")
```
