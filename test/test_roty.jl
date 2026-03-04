using Test
using LinearAlgebra
using StaticArrays
using RoboticsToolbox.HomogenousTransforms: Roty

@testset "ROTX Tests" begin

    # --- Test 1: Rotation by π/4 radians ---
    θ = π/4
    R = Roty(θ)
    
    @test size(R) == (3,3)                       # check 3x3 dimensions
    @test isapprox(R * R', I(3); atol=1e-12)    # check orthogonality
    @test isapprox(det(R), 1.0; atol=1e-12)     # check determinant = 1

    # --- Test 2: Rotation by 90 degrees ---
    θ_deg = 90
    R_deg = Roty(θ_deg; deg=true)
    
    @test size(R_deg) == (3,3)
    @test isapprox(R_deg * R_deg', I(3); atol=1e-12)
    @test isapprox(det(R_deg), 1.0; atol=1e-12)

    # --- Test 3: Multiple rotation angles ---
    angles = [0, π/6, π/3, π/2]
    R_array = [Roty(a) for a in angles]
    
    for (i, Ri) in enumerate(R_array)
        @test size(Ri) == (3,3)                       # must be 3x3
        @test isapprox(Ri * Ri', I(3); atol=1e-12)   # orthogonal
        @test isapprox(det(Ri), 1.0; atol=1e-12)    # determinant = 1
    end

end