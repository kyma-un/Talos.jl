using LinearAlgebra
using StaticArrays
using RoboticsToolbox.Common: IsHomog2
using RoboticsToolbox.HomogenousTransforms: Se2, Se3

# ----------------------------------------
# 1. Single SE(2) transformation using Se2
# ----------------------------------------
T1 = Se2(2.0, 3.0, pi/4)  # x=2, y=3, θ=45°

println("T1 (Se2) = \n", T1)
println("Is T1 a SE(2) homogeneous transform? ", IsHomog2(T1))
println("Is T1 valid (rotation check)? ", IsHomog2(T1, valid=true))

# ----------------------------------------
# 2. Single SE(3) transformation using Se3
# ----------------------------------------
T2 = Se3(T1)  

println("\nT2 (Se3) = \n", T2)
println("Is T2 a SE(2) homogeneous transform? ", IsHomog2(T2))  # Should be false
println("Is T2 valid (rotation check)? ", IsHomog2(T2, valid=true)) # Should also be false

# ----------------------------------------
# 3. Array of SE(2) transformations
# ----------------------------------------
T_array = zeros(3,3,3)
T_array[:,:,1] = Matrix(T1)
T_array[:,:,2] = @SMatrix [0.0 -1.0 1.0;
                           1.0  0.0 2.0;
                           0.0  0.0 1.0]
T_array[:,:,3] = @SMatrix [1.0 0.0 0.0;
                           0.0 1.0 0.0;
                           0.0 0.0 1.0]

println("\nArray of SE(2) transformations:")
println(IsHomog2(T_array))
println("Array with rotation check:")
println(IsHomog2(T_array, valid=true))

# ----------------------------------------
# 4. Invalid transformation (wrong size)
# ----------------------------------------
T_invalid = @SMatrix [1.0 0.0; 0.0 1.0]
println("\nT_invalid = \n", T_invalid)
println("Is T_invalid a SE(2) homogeneous transform? ", IsHomog2(T_invalid))