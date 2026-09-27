module RoboticsToolboxMakieExt

using RoboticsToolbox
using Makie

function RoboticsToolbox.Plotting.trplot(T::AbstractMatrix{<:Real}; scale=1.0, linewidth=2)
    size(T) == (4, 4) || throw(ArgumentError("trplot expects a 4×4 homogeneous transform"))
    o = T[1:3, 4]
    axes = ntuple(i -> o .+ scale .* T[1:3, i], 3)
    colors = (:red, :green, :blue)

    fig = Figure()
    ax = Axis3(fig[1, 1]; xlabel="X", ylabel="Y", zlabel="Z", aspect=:data)
    for (tip, color) in zip(axes, colors)
        lines!(ax, [o[1], tip[1]], [o[2], tip[2]], [o[3], tip[3]]; color, linewidth)
    end
    scatter!(ax, [o[1]], [o[2]], [o[3]]; color=:black, markersize=8)
    return fig
end

end
