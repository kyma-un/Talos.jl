"""
    Transl(x, y, z)
    Transl(p::SVector{3})
    Transl(T::SMatrix{4,4})

Build a pure SE(3) translation, or read the translation out of one.
"""
function Transl(x, y, z)
    x, y, z = promote(float(x), float(y), float(z))
    T = eltype(x)
    return @SMatrix [
        one(T)   zero(T)  zero(T)  x
        zero(T)  one(T)   zero(T)  y
        zero(T)  zero(T)  one(T)   z
        zero(T)  zero(T)  zero(T)  one(T)
    ]
end

Transl(p::SVector{3}) = Transl(p[1], p[2], p[3])

Transl(T::SMatrix{4,4}) = @SVector [T[1, 4], T[2, 4], T[3, 4]]

Transl(Ts::AbstractVector{<:SMatrix{4,4}}) = [Transl(T) for T in Ts]
