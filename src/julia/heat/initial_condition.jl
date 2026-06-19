function set_initial_1d(name::String, nx::Int, lx::Float64)::Vector{Float64}
    dx = lx / nx
    temp = zeros(Float64, nx + 1)
    for i in 1:(nx + 1)
        x = (i - 1) * dx - lx / 2.0
        if name == "semicircle"
            temp[i] = sqrt(max(0.0, 1.0 - x * x))
        elseif name == "gaussian"
            temp[i] = exp(-40.0 * x * x)
        elseif name == "sine"
            temp[i] = sin(π * (x + lx / 2.0) / lx)
        else
            error("unknown 1-D initial condition: $name")
        end
    end
    return temp
end
