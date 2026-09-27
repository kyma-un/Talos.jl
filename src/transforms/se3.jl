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
