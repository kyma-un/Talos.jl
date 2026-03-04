using Test
using StaticArrays
using LinearAlgebra
using RoboticsToolbox.HomogenousTransforms: Transl

# ============================================================
# Test suite for Transl — SE(3) pure translations
# ============================================================

@testset "Transl — SE(3) translations" begin

    # --------------------------------------------------------
    # Basic case: Transl(x, y, z)
    # --------------------------------------------------------
    @testset "Create translation from scalars" begin
        T = Transl(1.0, 2.0, 3.0)
        @test size(T) == (4, 4)

        # Rotation part should be identity
        @test T[1:3, 1:3] ≈ I(3)

        # Translation
        @test T[1,4] == 1.0
        @test T[2,4] == 2.0
        @test T[3,4] == 3.0

        # Homogeneous row
        @test T[4, :] == [0.0, 0.0, 0.0, 1.0]
    end


    # --------------------------------------------------------
    # Input as SVector{3}
    # --------------------------------------------------------
    @testset "Create translation from SVector{3}" begin
        p = @SVector [4.0, 5.0, 6.0]
        T = Transl(p)

        @test T[1:3, 1:3] ≈ I(3)
        @test T[1:3, 4] == p
        @test T[4, :] == [0.0, 0.0, 0.0, 1.0]
    end


    # --------------------------------------------------------
    # Extract translation from SE(3) matrix
    # --------------------------------------------------------
    @testset "Extract translation from SE(3)" begin
        T = Transl(7.0, 8.0, 9.0)
        p = Transl(T)

        @test p isa SVector{3}
        @test p == @SVector [7.0, 8.0, 9.0]
    end


    # --------------------------------------------------------
    # Translation sequence (trajectory)
    # --------------------------------------------------------
    @testset "Extract translations from a trajectory" begin
        Ts = [
            Transl(1.0, 0.0, 0.0),
            Transl(0.0, 2.0, 0.0),
            Transl(0.0, 0.0, 3.0)
        ]

        ps = Transl(Ts)

        @test length(ps) == 3
        @test ps[1] == @SVector [1.0, 0.0, 0.0]
        @test ps[2] == @SVector [0.0, 2.0, 0.0]
        @test ps[3] == @SVector [0.0, 0.0, 3.0]
    end


    # --------------------------------------------------------
    # Identity translation
    # --------------------------------------------------------
    @testset "Identity translation" begin
        T = Transl(0.0, 0.0, 0.0)

        @test T ≈ I(4)
        @test Transl(T) == @SVector [0.0, 0.0, 0.0]
    end

end