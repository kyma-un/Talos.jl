using Test
using StaticArrays
using LinearAlgebra
using RoboticsToolbox: Se2

# ============================================================
# Test suite for SE(2) homogeneous transformations
# ============================================================

@testset "SE2 – Homogeneous transformations" begin

    # --------------------------------------------------------
    # Basic case: x, y, θ given in radians
    # --------------------------------------------------------
    @testset "Basic case (x, y, θ in radians)" begin
        T = Se2(1.0, 2.0, pi/2)

        @test size(T) == (3, 3)

        # Rotation matrix
        @test isapprox(T[1,1],  0.0; atol=1e-8)
        @test isapprox(T[1,2], -1.0; atol=1e-8)
        @test isapprox(T[2,1],  1.0; atol=1e-8)
        @test isapprox(T[2,2],  0.0; atol=1e-8)

        # Translation
        @test T[1,3] == 1.0
        @test T[2,3] == 2.0

        # Homogeneous row
        @test T[3, :] == [0.0, 0.0, 1.0]
    end

    # --------------------------------------------------------
    # Angle specified in degrees
    # --------------------------------------------------------
    @testset "Angle in degrees" begin
        T = Se2(0.0, 0.0, 90.0; deg=true)

        @test isapprox(T[1,1],  0.0; atol=1e-8)
        @test isapprox(T[1,2], -1.0; atol=1e-8)
        @test isapprox(T[2,1],  1.0; atol=1e-8)
        @test isapprox(T[2,2],  0.0; atol=1e-8)
    end

    # --------------------------------------------------------
    # Input as SVector{2}: translation only
    # --------------------------------------------------------
    @testset "Input as SVector{2}" begin
        xy = @SVector [3.0, 4.0]
        T = Se2(xy)

        # Identity rotation
        @test T[1:2, 1:2] ≈ I(2)

        # Translation
        @test T[1,3] == 3.0
        @test T[2,3] == 4.0
    end

    # --------------------------------------------------------
    # Input as SVector{2} with θ in radians
    # --------------------------------------------------------
    @testset "Input as SVector{2} with θ (radians)" begin
        xy = @SVector [1.0, 2.0]
        θ  = pi

        T = Se2(xy, θ)

        @test isapprox(T[1,1], -1.0; atol=1e-8)
        @test isapprox(T[2,2], -1.0; atol=1e-8)
        @test T[1,3] == 1.0
        @test T[2,3] == 2.0
    end

    # --------------------------------------------------------
    # Input as SVector{2} with θ in degrees
    # --------------------------------------------------------
    @testset "Input as SVector{2} with θ (degrees)" begin
        xy = @SVector [1.0, 2.0]
        θ  = 180

        T = Se2(xy, θ; deg=true)

        @test isapprox(T[1,1], -1.0; atol=1e-8)
        @test isapprox(T[2,2], -1.0; atol=1e-8)
        @test T[1,3] == 1.0
        @test T[2,3] == 2.0
    end

    # --------------------------------------------------------
    # Input as SVector{3}: (x, y, θ) in radians
    # --------------------------------------------------------
    @testset "Input as SVector{3} (radians)" begin
        xyt = @SVector [1.0, 2.0, pi/2]
        T = Se2(xyt)

        @test isapprox(T[1,1],  0.0; atol=1e-8)
        @test isapprox(T[2,1],  1.0; atol=1e-8)
        @test T[1,3] == 1.0
        @test T[2,3] == 2.0
    end

    # --------------------------------------------------------
    # Input as SVector{3} with θ in degrees
    # --------------------------------------------------------
    @testset "Input as SVector{3} (degrees)" begin
        xyt = @SVector [1.0, 2.0, 90.0]
        T = Se2(xyt; deg=true)

        @test isapprox(T[1,1],  0.0; atol=1e-8)
        @test isapprox(T[2,1],  1.0; atol=1e-8)
        @test T[1,3] == 1.0
        @test T[2,3] == 2.0
    end

    # --------------------------------------------------------
    # Identity transformation
    # --------------------------------------------------------
    @testset "Identity" begin
        T = Se2(0.0, 0.0, 0.0)
        @test T ≈ I(3)
    end

end
