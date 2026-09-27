"""
    IsHomog2(T; valid=false)

`true` when `T` is 3×3. With `valid=true`, also checks `det(R) ≈ 1`.
"""
function IsHomog2(T; valid::Bool=false)
    dims = size(T)
    if ndims(T) == 2
        ok = dims == (3, 3)
        if ok && valid
            ok = isapprox(det(T[1:2, 1:2]), 1.0; atol=eps())
        end
        return ok
    elseif ndims(T) == 3 && dims[1:2] == (3, 3)
        ok = trues(dims[3])
        if valid
            for i in 1:dims[3]
                ok[i] = isapprox(det(T[1:2, 1:2, i]), 1.0; atol=eps())
            end
        end
        return ok
    end
    return false
end
