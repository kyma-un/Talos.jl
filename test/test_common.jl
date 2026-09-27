using Test
using StaticArrays
using Talos: Se2, Se3, Rot2, IsHomog2, IsRot2, trplot

@testset "IsHomog2 / IsRot2" begin
    T = Se2(1.0, 2.0, π/2)
    @test IsHomog2(T)
    @test IsHomog2(T; valid=true)
    @test !IsHomog2(Se3(T))

    R = Rot2(π/2)
    @test IsRot2(R)
    @test IsRot2(R; valid=true)
    @test !IsRot2(@SMatrix [1.0 0.0; 0.0 2.0]; valid=true)
end

@testset "trplot" begin
    @test_throws ErrorException trplot(Se3(Se2(0.0, 0.0, 0.0)))
end
