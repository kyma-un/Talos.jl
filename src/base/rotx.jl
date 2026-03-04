function Rotx(θ::Real; deg::Bool=false)
    θ = deg ? deg2rad(θ) : θ

    R = RotX(θ)           # RotX from Rotations.jl
    return SMatrix{3,3,Float64}(R)      # Convert to standard 3x3 Array
end