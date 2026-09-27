"""
    IsRot2(R; valid=false)

`true` when `R` is 2×2. With `valid=true`, also checks `det(R) ≈ 1`.
"""
function IsRot2(R::AbstractArray; valid::Bool=false)
    if ndims(R) == 2
        size(R) == (2, 2) || return false
        return valid ? isapprox(det(R), 1.0; atol=eps()) : true
    elseif ndims(R) == 3
        size(R)[1:2] == (2, 2) || return false
        return valid ? all(isapprox(det(slice), 1.0; atol=eps()) for slice in eachslice(R; dims=3)) : true
    elseif ndims(R) == 1 && all(isa.(R, SMatrix{2,2}))
        return valid ? all(isapprox(det(A), 1.0; atol=eps()) for A in R) : true
    end
    return false
end
