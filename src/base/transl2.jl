# ============================================================
# SE(2) pure translation
# ============================================================

"""
    Transl2(x, y)

Create an SE(2) homogeneous transform representing
a pure translation by `(x, y)`.
"""
function Transl2(x, y)
    x, y = promote(float(x), float(y))

    return @SMatrix [
        1.0  0.0  x
        0.0  1.0  y
        0.0  0.0  1.0
    ]
end

"""
    Transl2(p::SVector{2})

Create an SE(2) pure translation from a 2D vector.
"""
Transl2(p::SVector{2}) =
    Transl2(p[1], p[2])

"""
    Transl2(P::AbstractMatrix)

Create a sequence of SE(2) translations from an `N×2` matrix.
Each row represents a translation.
"""
function Transl2(P::AbstractMatrix)
    size(P,2) == 2 || throw(ArgumentError("Expected an N×2 matrix"))

    return [Transl2(P[i,1], P[i,2]) for i in axes(P,1)]
end

"""
    Transl2(T::SMatrix{3,3})

Extract the translation vector from an SE(2) homogeneous transform.
"""
Transl2(T::SMatrix{3,3}) =
    @SVector [T[1,3], T[2,3]]

"""
    Transl2(Ts::AbstractVector{<:SMatrix{3,3}})

Extract translations from a sequence of SE(2) transforms.
"""
Transl2(Ts::AbstractVector{<:SMatrix{3,3}}) =
    [Transl2(T) for T in Ts]