using Test
using StaticArrays
using LinearAlgebra
using RoboticsToolbox.HomogenousTransforms: Transl2

@testset "Transl2 – SE(2) pure translation" begin

    @testset "Constructor with x, y" begin
        T = Transl2(1.0, 2.0)

        @test size(T) == (3, 3)
        @test T ≈ @SMatrix [
            1.0  0.0  1.0
            0.0  1.0  2.0
            0.0  0.0  1.0
        ]
    end

    @testset "Constructor from SVector{2}" begin
        p = @SVector [3.0, -1.0]
        T = Transl2(p)

        @test T[1,3] == 3.0
        @test T[2,3] == -1.0
    end

    @testset "Constructor from N×2 matrix (trajectory)" begin
        P = [
            0.0  0.0
            1.0  2.0
            -1.0 3.0
        ]

        Ts = Transl2(P)

        @test length(Ts) == 3
        @test Ts[2][1,3] == 1.0
        @test Ts[2][2,3] == 2.0
    end

    @testset "Extract translation from SE(2) matrix" begin
        T = @SMatrix [
            1.0  0.0  4.0
            0.0  1.0 -2.0
            0.0  0.0  1.0
        ]

        p = Transl2(T)

        @test p == @SVector [4.0, -2.0]
    end

    @testset "Extract translation from sequence of transforms" begin
        Ts = [
            Transl2(0.0, 0.0),
            Transl2(1.0, 2.0),
            Transl2(-1.0, 3.0)
        ]

        P = Transl2(Ts)

        @test length(P) == 3
        @test P[3] == @SVector [-1.0, 3.0]
    end

end
