using Test
using StaticArrays
using LinearAlgebra
using Talos: Se2, Se3, Trinterp, Trmove, Rotx, Roty, Rotz, Transl

@testset "Se3 – general constructors" begin
    T = Se3(1.0, 2.0, 3.0, 0.0, 0.0, 90.0; deg=true)
    @test size(T) == (4, 4)
    @test T[1:3, 4] ≈ [1.0, 2.0, 3.0]
    @test T[1:3, 1:3] ≈ Rotz(90; deg=true)
    @test T[4, :] == [0.0, 0.0, 0.0, 1.0]

    # R = Rz·Ry·Rx
    a, b, c = 0.3, -0.5, 1.1
    @test Se3(0, 0, 0, a, b, c)[1:3, 1:3] ≈ Rotz(c) * Roty(b) * Rotx(a)

    R = Rotx(0.4)
    @test Se3(R, [1, 2, 3])[1:3, 1:3] ≈ R
    @test Se3(R, [1, 2, 3])[1:3, 4] == [1.0, 2.0, 3.0]
    @test_throws ArgumentError Se3(R, [1, 2])

    # AbstractMatrix: 4×4 as is, 3×3 embedded as SE(2)
    @test Se3(Matrix(Transl(1.0, 2.0, 3.0))) == Transl(1.0, 2.0, 3.0)
    @test Se3(Matrix(Se2(1.0, 2.0, 0.5))) ≈ Se3(Se2(1.0, 2.0, 0.5))
    @test_throws ArgumentError Se3(ones(2, 2))
end

@testset "Trinterp" begin
    T0 = Se3(1.0, 0.0, 0.0, 10.0, 20.0, 30.0; deg=true)
    T1 = Se3(-2.0, 3.0, 1.0, -40.0, 10.0, 120.0; deg=true)

    @testset "Endpoints" begin
        for mode in (:simultaneous, :rot_then_trans, :trans_then_rot)
            @test Trinterp(T0, T1, 0.0; mode) ≈ T0
            @test Trinterp(T0, T1, 1.0; mode) ≈ T1
        end
        @test Trinterp(T0, T1, -1.0) ≈ T0      # s is clamped
        @test Trinterp(T0, T1, 2.0) ≈ T1
    end

    @testset "Result is a valid SE(3)" begin
        for s in 0:0.1:1, mode in (:simultaneous, :rot_then_trans, :trans_then_rot)
            T = Trinterp(T0, T1, s; mode, ease=true)
            R = T[1:3, 1:3]
            @test R' * R ≈ I(3) atol = 1e-12
            @test det(R) ≈ 1 atol = 1e-12
            @test T[4, :] == [0.0, 0.0, 0.0, 1.0]
        end
    end

    @testset "Pure rotation: angle grows linearly" begin
        Ta = Se3(0, 0, 0, 0, 0, 0)
        Tb = Se3(0, 0, 0, 0, 0, 90.0; deg=true)
        @test Trinterp(Ta, Tb, 0.5) ≈ Se3(0, 0, 0, 0, 0, 45.0; deg=true)
        @test Trinterp(Ta, Tb, 0.25) ≈ Se3(0, 0, 0, 0, 0, 22.5; deg=true)
    end

    @testset "Pure translation: linear" begin
        Ta = Transl(0.0, 0.0, 0.0)
        Tb = Transl(2.0, 4.0, 6.0)
        @test Trinterp(Ta, Tb, 0.5) ≈ Transl(1.0, 2.0, 3.0)
    end

    @testset "Modes schedule rotation and translation" begin
        Ta = Se3(0, 0, 0, 0, 0, 0)
        Tb = Se3(2, 0, 0, 0, 0, 90.0; deg=true)
        # rotate first: at s = 0.5 rotation is complete, translation has not started
        Th = Trinterp(Ta, Tb, 0.5; mode=:rot_then_trans)
        @test Th[1:3, 1:3] ≈ Rotz(90; deg=true)
        @test Th[1:3, 4] ≈ [0.0, 0.0, 0.0] atol = 1e-12
        # translate first
        Th = Trinterp(Ta, Tb, 0.5; mode=:trans_then_rot)
        @test Th[1:3, 1:3] ≈ I(3) atol = 1e-12
        @test Th[1:3, 4] ≈ [2.0, 0.0, 0.0]
        @test_throws ArgumentError Trinterp(Ta, Tb, 0.5; mode=:nope)
    end

    @testset "≈180° rotation" begin
        Ta = Se3(0, 0, 0, 0, 0, 0)
        for θ in (179.0, 179.999999, 180.0)
            Tb = Se3(0, 0, 0, 0, 0, θ; deg=true)
            T = Trinterp(Ta, Tb, 1.0)
            @test T[1:3, 1:3] ≈ Tb[1:3, 1:3] atol = 1e-8
        end
    end

    @testset "SE(2) inputs are embedded" begin
        A, B = Se2(0.0, 0.0, 0.0), Se2(2.0, 0.0, π / 2)
        @test Trinterp(A, B, 1.0) ≈ Se3(B)
        @test Trinterp(A, B, 0.5) ≈ Se3(1.0, 0.0, 0.0, 0, 0, π / 4)
    end
end

@testset "Trmove – orden de composición (pre/post-multiplicación)" begin
    # T0: en (1,0,0) mirando a +y (yaw 90°).  M: trasladar d=(1,2,0) y rotar Q=Rz(90°).
    T0 = Se3(1.0, 0.0, 0.0, 0, 0, 90.0; deg=true)
    d  = [1.0, 2.0, 0.0]
    Q  = Rotz(90; deg=true)
    Dt = Transl(1.0, 2.0, 0.0)
    Dr = Se3(Q, [0.0, 0.0, 0.0])

    @testset "Pose final = producto de matrices en el orden pedido" begin
        @test Trmove(T0, d, Q, 1.0; frame=:body,  order=:trans_then_rot) ≈ T0 * Dt * Dr
        @test Trmove(T0, d, Q, 1.0; frame=:body,  order=:rot_then_trans) ≈ T0 * Dr * Dt
        @test Trmove(T0, d, Q, 1.0; frame=:world, order=:trans_then_rot) ≈ Dr * Dt * T0
        @test Trmove(T0, d, Q, 1.0; frame=:world, order=:rot_then_trans) ≈ Dt * Dr * T0
    end

    @testset "Las cuatro combinaciones dan posiciones DISTINTAS (mismo giro final)" begin
        pos(f, o) = Transl(Trmove(T0, d, Q, 1.0; frame=f, order=o))
        @test pos(:body,  :trans_then_rot) ≈ [-1.0,  1.0, 0.0] atol = 1e-12
        @test pos(:body,  :rot_then_trans) ≈ [ 0.0, -2.0, 0.0] atol = 1e-12
        @test pos(:world, :trans_then_rot) ≈ [-2.0,  2.0, 0.0] atol = 1e-12
        @test pos(:world, :rot_then_trans) ≈ [ 1.0,  3.0, 0.0] atol = 1e-12
        for f in (:body, :world), o in (:trans_then_rot, :rot_then_trans)
            @test Trmove(T0, d, Q, 1.0; frame=f, order=o)[1:3, 1:3] ≈ Rotz(180; deg=true) atol = 1e-12
        end
    end

    @testset "Extremos y continuidad" begin
        for f in (:body, :world), o in (:trans_then_rot, :rot_then_trans),
            sc in (:sequential, :simultaneous)
            @test Trmove(T0, d, Q, 0.0; frame=f, order=o, schedule=sc) ≈ T0
            @test Trmove(T0, d, Q, 1.0; frame=f, order=o, schedule=sc) ≈
                  Trmove(T0, d, Q, 1.0; frame=f, order=o)
        end
    end

    @testset "Secuencial: a mitad la 1ª operación ya terminó y la 2ª no empezó" begin
        # primero trasladar (cuerpo): en s=0.5 solo T0*Dt
        @test Trmove(T0, d, Q, 0.5; frame=:body, order=:trans_then_rot) ≈ T0 * Dt
        # primero rotar (cuerpo): en s=0.5 solo T0*Dr
        @test Trmove(T0, d, Q, 0.5; frame=:body, order=:rot_then_trans) ≈ T0 * Dr
        # primero trasladar (mundo): en s=0.5 solo Dt*T0
        @test Trmove(T0, d, Q, 0.5; frame=:world, order=:trans_then_rot) ≈ Dt * T0
        # primero rotar (mundo): en s=0.5 solo Dr*T0 (gira alrededor del ORIGEN del mundo)
        @test Trmove(T0, d, Q, 0.5; frame=:world, order=:rot_then_trans) ≈ Dr * T0
    end

    @testset "Simultáneo: valores intermedios" begin
        # cuerpo, trasladar*rotar, s=0.5: recta a lo largo de los ejes del cuerpo
        H = Trmove(T0, d, Q, 0.5; frame=:body, order=:trans_then_rot, schedule=:simultaneous)
        @test Transl(H) ≈ [0.0, 0.5, 0.0] atol = 1e-12
        # mundo, rotar*trasladar...: Rot(sQ)*Transl(s d)*T0, posición Rot(s Q)(p0 + s d)
        H = Trmove(T0, d, Q, 0.5; frame=:world, order=:trans_then_rot, schedule=:simultaneous)
        @test Transl(H) ≈ Rotz(45; deg=true) * [1.5, 1.0, 0.0] atol = 1e-12
    end

    @testset "Entradas inválidas" begin
        @test_throws ArgumentError Trmove(T0, d, Q, 0.5; frame=:otro)
        @test_throws ArgumentError Trmove(T0, d, Q, 0.5; order=:otro)
        @test_throws ArgumentError Trmove(T0, d, Q, 0.5; schedule=:otro)
        @test_throws ArgumentError Trmove(T0, [1.0, 2.0], Q, 0.5)
        @test_throws ArgumentError Trmove(T0, d, ones(2, 2), 0.5)
    end
end
