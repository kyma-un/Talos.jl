# Talos es una herramienta desarrollada por Kyma. https://kyma-un.github.io
module Common

using LinearAlgebra
using StaticArrays

include("ishomog2.jl")
include("isrot2.jl")

export IsHomog2, IsRot2

end
