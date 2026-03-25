"""
    module RoboticsToolbox

Main entry point for the RoboticsToolbox package.

This module provides a unified public API for common robotics utilities,
including homogeneous transformations and visualization tools. Internal
functionality is delegated to specialized submodules.
"""
module RoboticsToolbox

using Reexport

# ------------------------------------------------------------------
# Internal submodules
# ------------------------------------------------------------------
include("base/HomogenousTransforms.jl")
@reexport using .HomogenousTransforms

include("Documentar/Documentar.jl")
@reexport using .Documentar

include("common/common.jl")
@reexport using .Common

include("plotting/BasePlots.jl")
@reexport using .BasePlots


end # module RoboticsToolbox
