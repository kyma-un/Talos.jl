# --- SO(3) helpers (private) -------------------------------------------------

_eye3() = SMatrix{3,3,Float64}(I)

function _skew(w)
    z = zero(w[1])
    return @SMatrix [
        z     -w[3]   w[2]
        w[3]   z     -w[1]
       -w[2]   w[1]   z
    ]
end

_rot(T) = SMatrix{3,3,Float64}(
    T[1, 1], T[2, 1], T[3, 1],
    T[1, 2], T[2, 2], T[3, 2],
    T[1, 3], T[2, 3], T[3, 3],
)
_pos(T) = SVector{3,Float64}(T[1, 4], T[2, 4], T[3, 4])

# Rodrigues: axis·angle vector → rotation matrix
function _so3exp(w)
    θ = norm(w)
    K = _skew(w)
    θ < 1e-8 && return _eye3() + K + (K * K) / 2
    return _eye3() + (sin(θ) / θ) * K + ((1 - cos(θ)) / θ^2) * (K * K)
end

# Logarithm of SO(3): rotation matrix → axis·angle vector
function _so3log(R)
    v = SVector(R[3, 2] - R[2, 3], R[1, 3] - R[3, 1], R[2, 1] - R[1, 2])  # = 2 sinθ · axis
    θ = atan(norm(v) / 2, (tr(R) - 1) / 2)
    θ < 1e-8 && return v / 2
    if π - θ < 1e-9                     # ≈ 180°: axis from (R + I)/2 ≈ a·aᵀ
        B = (R + _eye3()) / 2
        i = argmax(diag(B))
        a = B[:, i] / sqrt(B[i, i])
        dot(a, v) < 0 && (a = -a)
        return θ * normalize(a)
    end
    return (θ / (2 * sin(θ))) * v
end

function _fractions(s, mode::Symbol)
    mode === :simultaneous   && return (s, s)
    mode === :rot_then_trans && return (clamp(2s, 0.0, 1.0), clamp(2s - 1, 0.0, 1.0))
    mode === :trans_then_rot && return (clamp(2s - 1, 0.0, 1.0), clamp(2s, 0.0, 1.0))
    throw(ArgumentError("mode must be :simultaneous, :rot_then_trans or :trans_then_rot"))
end

"""
    Trinterp(T0, T1, s; mode=:simultaneous, ease=false)

Intermediate pose between `T0` and `T1` for `s ∈ [0, 1]` (4×4 SE(3), or 3×3 SE(2)
which is embedded with `Se3`). Returns a 4×4 `SMatrix`.

The rotation follows the geodesic in SO(3) (a single rotation about the axis of
`R0ᵀ R1`) and the translation is linear.

`Trinterp` goes to an ABSOLUTE target pose: rotation and position are interpolated
independently, which is equivalent to `T1 = Transl(p1 - p0) * T0 * Rot(R0ᵀ R1)`
(translation in the world frame, rotation about the body's own origin). The order
(`mode`) only changes the path, never the final pose. To compose a RELATIVE motion in
a chosen frame (pre- or post-multiplication) use [`Trmove`](@ref).

`mode` chooses how rotation and translation are scheduled along `s`:
`:simultaneous`, `:rot_then_trans` or `:trans_then_rot`. `ease=true` applies a
smoothstep to `s`.
"""
function Trinterp(T0::AbstractMatrix, T1::AbstractMatrix, s::Real;
                  mode::Symbol=:simultaneous, ease::Bool=false)
    A, B = Se3(T0), Se3(T1)
    s = clamp(float(s), 0.0, 1.0)
    ease && (s = s * s * (3 - 2s))
    sr, st = _fractions(s, mode)
    R0, R1 = _rot(A), _rot(B)
    R = R0 * _so3exp(sr * _so3log(R0' * R1))
    t = (1 - st) * _pos(A) + st * _pos(B)
    return Se3(R, t)
end


# --- Movimiento relativo con orden de composición explícito -------------------

"""
    Trmove(T0, d, R, s; frame=:body, order=:trans_then_rot,
           schedule=:sequential, ease=false)

Pose at fraction `s ∈ [0, 1]` of applying the RELATIVE motion "translate by `d`
(3-vector) and rotate by `R` (3×3)" to the pose `T0`, composing the two operations in
an explicit order. With `Dt = Transl(d)` and `Dr = Rot(R)` the final pose (`s = 1`) is:

| `frame`  | `order`            | final pose      | reading                                          |
|:---------|:-------------------|:----------------|:-------------------------------------------------|
| `:body`  | `:trans_then_rot`  | `T0 * Dt * Dr`  | post-multiply: axes of the body itself           |
| `:body`  | `:rot_then_trans`  | `T0 * Dr * Dt`  | post-multiply: translate along the ROTATED axes  |
| `:world` | `:trans_then_rot`  | `Dr * Dt * T0`  | pre-multiply: rotation about the WORLD origin    |
| `:world` | `:rot_then_trans`  | `Dt * Dr * T0`  | pre-multiply: translate along world axes         |

Matrix products are not commutative, so each row is a different pose.

`schedule` decides how `s` is spent: `:sequential` (first operation during
`s ∈ [0, ½]`, second during `[½, 1]`) or `:simultaneous` (both advance together, still
composed in the given order). Partial operations are `Transl(f*d)` and the rotation by
the fraction `f` of `R` (geodesic). `ease=true` applies a smoothstep to `s`.
"""
function Trmove(T0::AbstractMatrix, d::AbstractVector, R::AbstractMatrix, s::Real;
                frame::Symbol=:body, order::Symbol=:trans_then_rot,
                schedule::Symbol=:sequential, ease::Bool=false)
    length(d) == 3    || throw(ArgumentError("d must have length 3, got $(length(d))"))
    size(R) == (3, 3) || throw(ArgumentError("R must be 3×3, got size $(size(R))"))
    frame in (:body, :world) ||
        throw(ArgumentError("frame must be :body or :world"))
    order in (:trans_then_rot, :rot_then_trans) ||
        throw(ArgumentError("order must be :trans_then_rot or :rot_then_trans"))
    schedule in (:sequential, :simultaneous) ||
        throw(ArgumentError("schedule must be :sequential or :simultaneous"))

    A = Se3(T0)
    s = clamp(float(s), 0.0, 1.0)
    ease && (s = s * s * (3 - 2s))

    # fracción de la 1ª y de la 2ª operación ejecutadas
    f1, f2 = schedule === :simultaneous ? (s, s) :
             (clamp(2s, 0.0, 1.0), clamp(2s - 1, 0.0, 1.0))
    ft, fr = order === :trans_then_rot ? (f1, f2) : (f2, f1)

    w  = _so3log(SMatrix{3,3,Float64}(R))
    Dt = Transl(ft * d[1], ft * d[2], ft * d[3])
    Dr = Se3(_so3exp(fr * w), SVector(0.0, 0.0, 0.0))

    if frame === :body           # post-multiplicación: T0 · (operaciones en orden)
        return order === :trans_then_rot ? A * Dt * Dr : A * Dr * Dt
    else                         # pre-multiplicación: (operaciones en orden inverso) · T0
        return order === :trans_then_rot ? Dr * Dt * A : Dt * Dr * A
    end
end
