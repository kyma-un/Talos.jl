using LinearAlgebra          
using StaticArrays           
using RoboticsToolbox.HomogenousTransforms: Rot2       

# ----------------------------------------
# 1. Create a 2D rotation (Rot2)
# ----------------------------------------
# Angle in radians
θ = pi/2                     
R = Rot2(θ)                  # Create a 2D rotation matrix

println("Rot2 matrix (R):")
println(R)

# ----------------------------------------
# 2. Verify rotation properties
# ----------------------------------------
# Orthogonality: R * R' = I
println("\nCheck R * R' ≈ I (orthogonal):")
println(isapprox(R * R', I(2); atol=1e-8))

# Determinant: det(R) = 1
println("Check det(R) ≈ 1 (proper rotation):")
println(isapprox(det(R), 1.0; atol=1e-8))

# ----------------------------------------
# 3. Rotate a vector
# ----------------------------------------
v = SVector(1.0, 0.0)       # Unit vector along x-axis
v_rot = R * v

println("\nOriginal vector: ", v)
println("Rotated vector: ", v_rot)

# ----------------------------------------
# 4. Rotate the vector repeatedly until it returns to original
# ----------------------------------------
# Number of rotations needed to return to original vector
n_rotations = Int(round(2*pi / θ))
println("\nNumber of rotations to return to original: ", n_rotations)

v_repeat = v
for i in 1:n_rotations
    global v_repeat = R * v_repeat
    println("After rotation $i: ", v_repeat)
end

println("\nFinal vector after $n_rotations rotations: ", v_repeat)
println("Original vector: ", v)
println("Approximately equal? ", isapprox(v_repeat, v; atol=1e-8))