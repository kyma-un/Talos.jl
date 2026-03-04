using StaticArrays
using RoboticsToolbox.HomogenousTransforms: Se2

println("=== SE(2) examples ===\n")

x = 1.0
y = 2.0
θ = pi/4
θ_deg = 45.0
xy = @SVector [1.0, 2.0]
xyt = @SVector [1.0, 2.0, pi/2]
xyt_deg = @SVector [1.0, 2.0, 90.0]

# ------------------------------------------------------------
# 1. Scalar inputs (x, y, θ) in radians
# ------------------------------------------------------------
println("1) Scalars (x, y, θ) in radians")

T1 = Se2(x, y, θ)
println("T1 =\n", T1, "\n")

# ------------------------------------------------------------
# 2. Scalar inputs (x, y, θ) in degrees
# ------------------------------------------------------------
println("2) Scalars (x, y, θ) in degrees")

T2 = Se2(x, y, θ_deg; deg=true)
println("T2 =\n", T2, "\n")

# ------------------------------------------------------------
# 3. Position vector [x, y] (zero rotation)
# ------------------------------------------------------------
println("3) Position vector SVector{2}")

T3 = Se2(xy)
println("T3 =\n", T3, "\n")

# ------------------------------------------------------------
# 4. Position vector [x, y] with angle in radians
# ------------------------------------------------------------
println("4) Position vector + angle in radians")

θ = pi/2                       
T4 = Se2(xy, θ)
println("T4 =\n", T4, "\n")

# ------------------------------------------------------------
# 5. Position vector [x, y] with angle in degrees
# ------------------------------------------------------------
println("5) Position vector + angle in degrees")

θ_deg = 90.0
T5 = Se2(xy, θ_deg; deg=true)
println("T5 =\n", T5, "\n")

# ------------------------------------------------------------
# 6. Full pose vector [x, y, θ] in radians
# ------------------------------------------------------------
println("6) Full pose vector SVector{3} (radians)")

T6 = Se2(xyt)
println("T6 =\n", T6, "\n")

# ------------------------------------------------------------
# 7. Full pose vector [x, y, θ] in degrees
# ------------------------------------------------------------
println("7) Full pose vector SVector{3} (degrees)")

T7 = Se2(xyt_deg; deg=true)
println("T7 =\n", T7, "\n")

println("=== End of SE(2) examples ===")
