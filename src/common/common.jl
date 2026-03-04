module Common

using LinearAlgebra
using StaticArrays
using Rotations

include("ishomog2.jl")
include("isrot2.jl")

export IsHomog2, IsRot2
end # module
