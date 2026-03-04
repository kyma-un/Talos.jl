using LinearAlgebra
using StaticArrays
using RoboticsToolbox.Common: IsRot2
using RoboticsToolbox.HomogenousTransforms: Rot2, Se2

# ----------------------------------------
# 1. Single 2D rotation
# ----------------------------------------
R1 = Rot2(pi/4)
println("R1 = \n", R1)
println("Is R1 a 2D rotation matrix? ", IsRot2(R1))
println("Is R1 valid (det ≈ 1)? ", IsRot2(R1; valid=true))

# ----------------------------------------
# 2. Rotation from Se2
# ----------------------------------------
T1 = Se2(1.0, 2.0, pi/3)
R2 = T1[1:2, 1:2]   # extrae submatriz 2x2 de Se2
println("\nR2 extracted from Se2 = \n", R2)
println("Is R2 a 2D rotation matrix? ", IsRot2(R2))
println("Is R2 valid? ", IsRot2(R2; valid=true))
# ----------------------------------------
# 3. Array of rotations
# ----------------------------------------
R_array = zeros(2,2,3)
R_array[:,:,1] = SMatrix(Rot2(pi/6))
R_array[:,:,2] = SMatrix(Rot2(pi/3))
R_array[:,:,3] = SMatrix(Rot2(pi/2))

println("\nArray of 2D rotations:")
println(IsRot2(R_array))
println("Array with det check:")
println(IsRot2(R_array; valid=true))

# ----------------------------------------
# 4. Invalid rotation
# ----------------------------------------
R_invalid = [1.0 0.0; 0.0 2.0]
println("\nR_invalid = \n", R_invalid)
println("Is R_invalid a 2D rotation matrix? ", IsRot2(R_invalid))
println("Is R_invalid valid? ", IsRot2(R_invalid; valid=true))
