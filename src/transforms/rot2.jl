"""
    Rot2(θ; deg=false)

2×2 rotation. `deg=true` reads `θ` in degrees.
"""
function Rot2(θ::Real; deg::Bool=false)
    θ = float(θ)
    θ = deg ? deg2rad(θ) : θ
    return SMatrix{2,2,Float64}(RotMatrix(θ))
end
