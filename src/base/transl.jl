# ============================================================
# Transl — Create or extract SE(3) translation
# ============================================================

"""
    Transl(x, y, z)
Create an SE(3) homogeneous transformation representing a pure translation
by `(x, y, z)`.
"""
function Transl(x, y, z)
    x, y, z = promote(float(x), float(y), float(z))
    T = eltype(x)

    return @SMatrix [
        one(T)  zero(T) zero(T) x
        zero(T) one(T)  zero(T) y
        zero(T) zero(T) one(T)  z
        zero(T) zero(T) zero(T) one(T)
    ]
end


"""
    Transl(p::SVector{3})

Create an SE(3) homogeneous transformation representing a pure translation
by `p = [x, y, z]`.
"""
Transl(p::SVector{3}) = Transl(p[1], p[2], p[3])


"""
    Transl(T::SMatrix{4,4})

Extract the translational part of an SE(3) homogeneous transformation.

Returns a 3-element `SVector`.
"""
function Transl(T::SMatrix{4,4})
    return @SVector [T[1,4], T[2,4], T[3,4]]
end


"""
    Transl(Ts::AbstractVector{<:SMatrix{4,4}})

Extract translations from a sequence of SE(3) transformations.

Returns a vector of `SVector{3}`.
"""
function Transl(Ts::AbstractVector{<:SMatrix{4,4}})
    return [Transl(T) for T in Ts]
end

