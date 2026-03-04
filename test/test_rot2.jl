using Test
using StaticArrays
using LinearAlgebra
using RoboticsToolbox.HomogenousTransforms: Rot2

# ============================================================
# Test suite for 2D rotation matrices (SO(2))
# ============================================================

@testset "Rot2 – 2D Rotation Matrices" begin

    # --------------------------------------------------------
    # Basic case: angle in radians
    # --------------------------------------------------------
    @testset "Angle in radians" begin
        θ = pi/2
        R = Rot2(θ)

        @test size(R) == (2, 2)
        @test isapprox(R[1,1],  0.0; atol=1e-8)
        @test isapprox(R[1,2], -1.0; atol=1e-8)
        @test isapprox(R[2,1],  1.0; atol=1e-8)
        @test isapprox(R[2,2],  0.0; atol=1e-8)

        # Orthogonality check: R * R' == I
        @test isapprox(R * R', I(2); atol=1e-8)
        @test isapprox(det(R), 1.0; atol=1e-8)
    end

    # --------------------------------------------------------
    # Angle in degrees
    # --------------------------------------------------------
    @testset "Angle in degrees" begin
        θ_deg = 90
        R = Rot2(θ_deg; deg=true)

        @test size(R) == (2, 2)
        @test isapprox(R[1,1],  0.0; atol=1e-8)
        @test isapprox(R[1,2], -1.0; atol=1e-8)
        @test isapprox(R[2,1],  1.0; atol=1e-8)
        @test isapprox(R[2,2],  0.0; atol=1e-8)

        # Orthogonality check
        @test isapprox(R * R', I(2); atol=1e-8)
        @test isapprox(det(R), 1.0; atol=1e-8)
    end

    # --------------------------------------------------------
    # Zero rotation
    # --------------------------------------------------------
    @testset "Zero rotation" begin
        R = Rot2(0.0)
        @test R ≈ I(2)
    end

end
