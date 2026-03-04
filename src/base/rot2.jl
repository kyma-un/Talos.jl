# ============================================================
# SO(2) rotation matrix using Rotations.jl
# ============================================================

"""
    Rot2(theta; deg=false)

Create a 2×2 SO(2) rotation matrix representing a rotation
of `theta` radians. If `deg=true`, `theta` is interpreted in degrees.
"""
function Rot2(θ::Real; deg::Bool=false)
    θf = float(θ)
    θf = deg ? deg2rad(θf) : θf

    # Create a 2D rotation
    R = RotMatrix(θf)

    # Convert to static 2×2 matrix for consistency
    return SMatrix{2,2,Float64}(R)
end
