# Talos es una herramienta desarrollada por Kyma. https://kyma-un.github.io
module Plotting

export trplot

"""
    trplot(T; scale=1.0, linewidth=2)

Draw the axes of a 4×4 homogeneous transform. Load `GLMakie` or `CairoMakie` first.
"""
function trplot(args...; kwargs...)
    error("Load GLMakie or CairoMakie before calling trplot.")
end

end
