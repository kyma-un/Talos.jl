function IsHomog2(T; valid=false)
    # Get dimensions
    dims = size(T)

    # Handle 2D matrix
    if ndims(T) == 2
        h = all(dims .== (3, 3))

        # Check rotation submatrix if requested
        if h && valid
            R = T[1:2, 1:2]
            h = isapprox(det(R), 1.0; atol=eps())
        end

        return h

    # Handle array of matrices: 3x3xN
    elseif ndims(T) == 3 && dims[1:2] == (3, 3)
        N = dims[3]
        h_array = trues(N)
        for i in 1:N
            h_array[i] = true
            if valid
                R = T[1:2, 1:2, i]
                h_array[i] = isapprox(det(R), 1.0; atol=eps())
            end
        end
        return h_array
    else
        return false
    end
end