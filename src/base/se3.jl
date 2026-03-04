# ============================================================
# SE(3) homogeneous transformation
# Embedding of SE(2) into SE(3)
# ============================================================

"""
    Se3(T2::SMatrix{3,3})

Embed an SE(2) homogeneous transformation into SE(3).

The SE(2) transform is assumed to lie in the XY plane.
"""
function Se3(T2::SMatrix{3,3})
    # type normalization
    T = eltype(T2)

    R2 = T2[1:2, 1:2]
    t2 = T2[1:2, 3]

    return @SMatrix [
        R2[1,1]  R2[1,2]  zero(T)  t2[1]
        R2[2,1]  R2[2,2]  zero(T)  t2[2]
        zero(T)  zero(T)  one(T)   zero(T)
        zero(T)  zero(T)  zero(T)  one(T)
    ]
end

