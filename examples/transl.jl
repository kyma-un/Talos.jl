using StaticArrays
using LinearAlgebra
using RoboticsToolbox.HomogenousTransforms: Transl

println("=== Transl examples (SE(3) pure translation) ===\n")

# ------------------------------------------------------------
# 1. Create translation from scalars
# ------------------------------------------------------------
T1 = Transl(1.0, 2.0, 3.0)
println("T1 = Transl(1.0, 2.0, 3.0)\n", T1, "\n")

# ------------------------------------------------------------
# 2. Create translation from SVector{3}
# ------------------------------------------------------------
p = @SVector [4.0, 5.0, 6.0]
T2 = Transl(p)
println("T2 = Transl(@SVector [4.0, 5.0, 6.0])\n", T2, "\n")

# ------------------------------------------------------------
# 3. Extract translation from SE(3)
# ------------------------------------------------------------
p2 = Transl(T2)
println("p2 = Transl(T2) = ", p2, "\n")

# ------------------------------------------------------------
# 4. Translation trajectory (sequence of transforms)
# ------------------------------------------------------------
Ts = [
    Transl(1.0, 0.0, 0.0),
    Transl(0.0, 2.0, 0.0),
    Transl(0.0, 0.0, 3.0)
]

println("Translation trajectory:")
for (i, T) in enumerate(Ts)
    println("T[$i] =\n", T, "\n")
end

ps = Transl(Ts)
println("Extracted translations:")
for (i, p) in enumerate(ps)
    println("p[$i] = ", p)
end

println()

# ------------------------------------------------------------
# 5. Identity translation
# ------------------------------------------------------------
T0 = Transl(0.0, 0.0, 0.0)
println("T0 = Transl(0, 0, 0)\n", T0)