module RoboticsToolbox

using LinearAlgebra
using StaticArrays
using Rotations
using CoordinateTransformations

include("base/HomogenousTransforms.jl")
include("plotting/BasePlots.jl")
include("base/se2.jl")

using .HomogenousTransforms
using .BasePlots
using .SE2

# Exportar lo propio
export SE3, HomogenousTransform, Se2, trplot3

# -------------------------------
# Reexportar todo Rotations.jl
# -------------------------------
for name in names(Rotations; all = false)
    # all=false para solo nombres exportados por Rotations
    @eval export $(name)
end

# Reexportar Translation
export Translation

end
