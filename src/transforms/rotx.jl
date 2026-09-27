"""
    Rotx(θ; deg=false)

3×3 rotation about x.
"""
function Rotx(θ::Real; deg::Bool=false)
    θ = deg ? deg2rad(float(θ)) : float(θ)
    return SMatrix{3,3,Float64}(RotX(θ))
end
