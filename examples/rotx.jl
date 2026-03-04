using LinearAlgebra
using Rotations
using RoboticsToolbox.HomogenousTransforms: Rotx

# ----------------------------------------
# 1. Rotation about X-axis (radians)
# ----------------------------------------
θ = pi/4
R = Rotx(θ)

println("Rotation matrix about X (θ = π/4 radians):")
println(R)

# ----------------------------------------
# 2. Verify rotation properties
# ----------------------------------------
# Orthogonality: R * R' ≈ I
println("\nCheck R * R' ≈ I (orthogonal):")
println(isapprox(R * R', I(3); atol=1e-8))

# Determinant: det(R) = 1
println("Check det(R) ≈ 1 (proper rotation):")
println(isapprox(det(R), 1.0; atol=1e-8))

# ----------------------------------------
# 3. Rotation using degrees
# ----------------------------------------
R_deg = Rotx(90; deg=true)
println("\nRotation matrix about X (90 degrees):")
println(R_deg)

println("\nCheck det(R_deg) ≈ 1:")
println(isapprox(det(R_deg), 1.0; atol=1e-8))

# ----------------------------------------
# 4. Rotate a vector
# ----------------------------------------
v = [0.0, 1.0, 0.0]  # Unit vector along Y-axis
v_rot = R * v
println("\nOriginal vector:", v)
println("Rotated vector around X-axis:", v_rot)