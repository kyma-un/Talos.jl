"""
    Transl2(x, y)
    Transl2(p::SVector{2})
    Transl2(P::AbstractMatrix)
    Transl2(T::SMatrix{3,3})

Build a pure SE(2) translation, a trajectory from an `N×2` matrix, or read the translation back.
"""
function Transl2(x, y)
    x, y = promote(float(x), float(y))
    T = eltype(x)
    return @SMatrix [
        one(T)   zero(T)  x
        zero(T)  one(T)   y
        zero(T)  zero(T)  one(T)
    ]
end

Transl2(p::SVector{2}) = Transl2(p[1], p[2])

function Transl2(P::AbstractMatrix)
    size(P, 2) == 2 || throw(ArgumentError("Expected an N×2 matrix"))
    return [Transl2(P[i, 1], P[i, 2]) for i in axes(P, 1)]
end

Transl2(T::SMatrix{3,3}) = @SVector [T[1, 3], T[2, 3]]

Transl2(Ts::AbstractVector{<:SMatrix{3,3}}) = [Transl2(T) for T in Ts]
