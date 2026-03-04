using StaticArrays
using RoboticsToolbox.HomogenousTransforms: Transl2

println("=== Transl2 examples ===")

# --------------------------------------------------
# Example 1: Pure translation from x, y
# --------------------------------------------------
T1 = Transl2(1.0, 2.0)
println("T1 =")
println(T1)

# --------------------------------------------------
# Example 2: Translation from 2D vector
# --------------------------------------------------
p = @SVector [3.0, -1.0]
T2 = Transl2(p)
println("\nT2 =")
println(T2)

# --------------------------------------------------
# Example 3: Trajectory from N×2 matrix
# --------------------------------------------------
P = [
    0.0  0.0
    1.0  2.0
    2.0  1.0
]

Ts = Transl2(P)

println("\nTrajectory transforms:")
for (i, T) in enumerate(Ts)
    println("T[$i] =")
    println(T)
end

# --------------------------------------------------
# Example 4: Extract translation from transform
# --------------------------------------------------
t = Transl2(T2)
println("\nExtracted translation:")
println(t)

# --------------------------------------------------
# Example 5: Extract translations from trajectory
# --------------------------------------------------
pts = Transl2(Ts)
println("\nExtracted trajectory:")
println(pts)
