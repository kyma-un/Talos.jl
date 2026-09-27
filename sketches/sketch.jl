
using Talos
using StaticArrays

T = Se2(1.0, 2.0, π/2)

printstyled(T)
p = T * @SVector [1.0, 0.0, 1.0]

H = Se3(T)
q = H * @SVector [1.0, 0.0, 0.0, 1.0]

R = Rotz(90; deg=true)
