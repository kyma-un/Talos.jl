using Test
using StaticArrays
using LinearAlgebra
using RoboticsToolbox.HomogenousTransforms: Se2, Se3

# ============================================================
# Test suite for SE(3) homogeneous transformations
# (Embedding SE(2) into SE(3))
# ============================================================

@testset "SE3 – Embedding SE(2) into SE(3)" begin

    # --------------------------------------------------------
    # Basic embedding from SE(2)
    # --------------------------------------------------------
    @testset "Basic embedding" begin
        T2 = Se2(1.0, 2.0, pi/2)
        T3 = Se3(T2)

        @test size(T3) == (4, 4)
    end

    # --------------------------------------------------------
    # Rotation consistency
    # --------------------------------------------------------
    @testset "Rotation block" begin
        T2 = Se2(0.0, 0.0, pi/2)
        T3 = Se3(T2)

        # XY plane rotation
        @test isapprox(T3[1,1],  0.0; atol=1e-8)
        @test isapprox(T3[1,2], -1.0; atol=1e-8)
        @test isapprox(T3[2,1],  1.0; atol=1e-8)
        @test isapprox(T3[2,2],  0.0; atol=1e-8)

        # Z axis preserved
        @test T3[3,3] == 1.0

        # No coupling with Z
        @test T3[1,3] == 0.0
        @test T3[2,3] == 0.0
        @test T3[3,1] == 0.0
        @test T3[3,2] == 0.0
    end

    # --------------------------------------------------------
    # Translation consistency
    # --------------------------------------------------------
    @testset "Translation block" begin
        T2 = Se2(3.0, 4.0, 0.0)
        T3 = Se3(T2)

        @test T3[1,4] == 3.0
        @test T3[2,4] == 4.0
        @test T3[3,4] == 0.0
    end

    # --------------------------------------------------------
    # Homogeneous bottom row
    # --------------------------------------------------------
    @testset "Homogeneous row" begin
        T2 = Se2(1.0, 2.0, pi/4)
        T3 = Se3(T2)

        @test T3[4, :] == @SVector [0.0, 0.0, 0.0, 1.0]
    end

    # --------------------------------------------------------
    # Identity embedding
    # --------------------------------------------------------
    @testset "Identity case" begin
        T2 = Se2(0.0, 0.0, 0.0)
        T3 = Se3(T2)

        @test T3 ≈ I(4)
    end

    @testset "Manual SE(2) input" begin
        θ = pi/2
        c = cos(θ)
        s = sin(θ)

        # Manually constructed SE(2) homogeneous matrix
        T2 = @SMatrix [
            c   -s   1.0
            s    c   2.0
            0.0  0.0  1.0
        ]

        T3 = Se3(T2)

        # Check rotation embedding
        @test isapprox(T3[1,1],  0.0; atol=1e-8)
        @test isapprox(T3[1,2], -1.0; atol=1e-8)
        @test isapprox(T3[2,1],  1.0; atol=1e-8)
        @test isapprox(T3[2,2],  0.0; atol=1e-8)

        # Z axis untouched
        @test T3[3,3] == 1.0

        # Translation
        @test T3[1,4] == 1.0
        @test T3[2,4] == 2.0
        @test T3[3,4] == 0.0

        # Homogeneous row
        @test T3[4, :] == @SVector [0.0, 0.0, 0.0, 1.0]
    end

end
