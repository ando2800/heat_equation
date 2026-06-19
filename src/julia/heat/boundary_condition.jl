function apply_boundary_1d!(temp::Vector{Float64}, nx::Int, boundary::String)
    if boundary == "dirichlet"
        temp[1]      = 0.0
        temp[nx + 1] = 0.0
    elseif boundary == "neumann"
        temp[1]      = temp[2]
        temp[nx + 1] = temp[nx]
    elseif boundary == "periodic"
        temp[1]      = temp[nx]
        temp[nx + 1] = temp[2]
    else
        error("unknown 1-D boundary condition: $boundary")
    end
end
