"""
    Se3(T2::SMatrix{3,3})

Embed an SE(2) transform (XY plane) into SE(3).
"""
function Se3(T2::SMatrix{3,3})
    T = eltype(T2)
    R, t = T2[1:2, 1:2], T2[1:2, 3]
    return @SMatrix [
        R[1, 1]  R[1, 2]  zero(T)  t[1]
        R[2, 1]  R[2, 2]  zero(T)  t[2]
        zero(T)  zero(T)  one(T)   zero(T)
        zero(T)  zero(T)  zero(T)  one(T)
    ]
end

"""
    Se3(T::AbstractMatrix)

Return `T` as a 4×4 `SMatrix{4,4,Float64}`. A 4×4 input is copied as is; a 3×3
input is read as an SE(2) transform and embedded (see `Se3(::SMatrix{3,3})`).
"""
function Se3(T::AbstractMatrix)
    sz = size(T)
    sz == (4, 4) && return SMatrix{4,4,Float64}(T)
    sz == (3, 3) && return Se3(SMatrix{3,3,Float64}(T))
    throw(ArgumentError("Se3 expects a 3×3 (SE(2)) or 4×4 (SE(3)) matrix, got size $sz"))
end

"""
    Se3(R::AbstractMatrix, t::AbstractVector)

SE(3) transform from a 3×3 rotation `R` and a translation `t` of length 3.
"""
function Se3(R::AbstractMatrix, t::AbstractVector)
    size(R) == (3, 3) || throw(ArgumentError("R must be 3×3, got size $(size(R))"))
    length(t) == 3    || throw(ArgumentError("t must have length 3, got $(length(t))"))
    T = float(promote_type(eltype(R), eltype(t)))
    return SMatrix{4,4,T}(
        R[1, 1], R[2, 1], R[3, 1], 0,
        R[1, 2], R[2, 2], R[3, 2], 0,
        R[1, 3], R[2, 3], R[3, 3], 0,
        t[1],    t[2],    t[3],    1,
    )
end

"""
    Se3(x, y, z, roll, pitch, yaw; deg=false)

General SE(3) transform: translation `(x, y, z)` and rotation
`R = Rz(yaw) * Ry(pitch) * Rx(roll)`. `deg=true` reads the angles in degrees.
"""
function Se3(x, y, z, roll, pitch, yaw; deg::Bool=false)
    R = Rotz(yaw; deg) * Roty(pitch; deg) * Rotx(roll; deg)
    return Se3(R, SVector(float(x), float(y), float(z)))
end
