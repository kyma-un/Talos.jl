"""
    Roty(θ; deg=false)

3×3 rotation about y.
"""
function Roty(θ::Real; deg::Bool=false)
    θ = deg ? deg2rad(float(θ)) : float(θ)
    return SMatrix{3,3,Float64}(RotY(θ))
end
