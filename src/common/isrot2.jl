function IsRot2(R::AbstractArray; valid::Bool=false)
    # Single 2x2 matrix
    if ndims(R) == 2
        if size(R) != (2,2)
            return false
        elseif valid
            return isapprox(det(Matrix(R)), 1.0; atol=eps())
        else
            return true
        end

    # 2x2xN array
    elseif ndims(R) == 3
        if !all(size(R)[1:2] .== (2,2))
            return false
        elseif valid
            return all(isapprox(det(Matrix(slice)), 1.0; atol=eps()) for slice in eachslice(R, dims=3))
        else
            return true
        end

    # Vector of SMatrix{2,2}
    elseif ndims(R) == 1 && all(isa.(R, SMatrix{2,2}))
        if valid
            return all(isapprox(det(Matrix(mat)), 1.0; atol=eps()) for mat in R)
        else
            return true
        end
    else
        return false
    end
end
