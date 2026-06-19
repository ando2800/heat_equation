function solve_heat_1d(;
    nx::Int,
    nt::Int,
    output_every::Int,
    dt::Float64,
    alpha::Float64,
    lx::Float64,
    output_dir::String,
    initial::String,
    boundary::String,
    vtk::Bool,
    method::String,
)
    dx = lx / nx
    r  = alpha * dt / (dx * dx)

    if method == "euler" && r > 0.5
        dt_max = 0.5 * dx * dx / alpha
        error("unstable time step: r=$r  (dt_max = $dt_max)")
    end

    temp      = set_initial_1d(initial, nx, lx)
    next_temp = similar(temp)
    apply_boundary_1d!(temp, nx, boundary)

    frame = 0
    write_profile(output_dir, frame, temp, dx, lx)
    if vtk
        write_vtk_1d(output_dir, frame, temp, dx, lx)
    end

    for step in 1:nt
        if method == "euler"
            _euler_step!(next_temp, temp, nx, dx, alpha, dt)

        elseif method == "rk4"
            _rk4_step!(next_temp, temp, nx, dx, alpha, dt, boundary)

        else
            error("unknown method: $method")
        end

        apply_boundary_1d!(next_temp, nx, boundary)
        temp, next_temp = next_temp, temp   # バッファを交換（アロケーションなし）

        if step % output_every == 0
            frame += 1
            write_profile(output_dir, frame, temp, dx, lx)
            if vtk
                write_vtk_1d(output_dir, frame, temp, dx, lx)
            end
        end
    end
end

# ---- Euler ----------------------------------------------------------------

function _euler_step!(
    next::Vector{Float64},
    temp::Vector{Float64},
    nx::Int, dx::Float64, alpha::Float64, dt::Float64,
)
    inv_dx2 = 1.0 / (dx * dx)
    for i in 2:nx
        lap = (temp[i+1] - 2.0 * temp[i] + temp[i-1]) * inv_dx2
        next[i] = temp[i] + alpha * dt * lap
    end
end

# ---- RK4 ------------------------------------------------------------------

function _laplacian_interior!(k::Vector{Float64}, u::Vector{Float64}, nx::Int, inv_dx2::Float64, alpha::Float64, dt::Float64)
    for i in 2:nx
        k[i] = alpha * dt * (u[i+1] - 2.0 * u[i] + u[i-1]) * inv_dx2
    end
end

function _rk4_step!(
    next::Vector{Float64},
    temp::Vector{Float64},
    nx::Int, dx::Float64, alpha::Float64, dt::Float64,
    boundary::String,
)
    inv_dx2 = 1.0 / (dx * dx)
    work = copy(temp)
    k1 = similar(temp)
    k2 = similar(temp)
    k3 = similar(temp)
    k4 = similar(temp)

    _laplacian_interior!(k1, temp, nx, inv_dx2, alpha, dt)

    work .= temp;  for i in 2:nx; work[i] = temp[i] + 0.5 * k1[i]; end
    apply_boundary_1d!(work, nx, boundary)
    _laplacian_interior!(k2, work, nx, inv_dx2, alpha, dt)

    work .= temp;  for i in 2:nx; work[i] = temp[i] + 0.5 * k2[i]; end
    apply_boundary_1d!(work, nx, boundary)
    _laplacian_interior!(k3, work, nx, inv_dx2, alpha, dt)

    work .= temp;  for i in 2:nx; work[i] = temp[i] + k3[i]; end
    apply_boundary_1d!(work, nx, boundary)
    _laplacian_interior!(k4, work, nx, inv_dx2, alpha, dt)

    for i in 2:nx
        next[i] = temp[i] + (k1[i] + 2.0 * k2[i] + 2.0 * k3[i] + k4[i]) / 6.0
    end
end
