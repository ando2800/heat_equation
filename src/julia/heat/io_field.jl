using Printf

function write_profile(output_dir::String, index::Int, temp::Vector{Float64}, dx::Float64, lx::Float64)
    mkpath(output_dir)
    filename = joinpath(output_dir, @sprintf("temp.%04d", index))
    open(filename, "w") do f
        for (i, val) in enumerate(temp)
            x = (i - 1) * dx - lx / 2.0
            @printf(f, "%.12e %.12e\n", x, val)
        end
    end
end

function write_vtk_1d(output_dir::String, index::Int, temp::Vector{Float64}, dx::Float64, lx::Float64)
    mkpath(output_dir)
    filename = joinpath(output_dir, @sprintf("temp.%04d.vtk", index))
    nx = length(temp) - 1
    open(filename, "w") do f
        println(f, "# vtk DataFile Version 3.0")
        println(f, "1-D heat equation")
        println(f, "ASCII")
        println(f, "DATASET STRUCTURED_GRID")
        println(f, "DIMENSIONS $(nx + 1) 1 1")
        println(f, "POINTS $(nx + 1) float")
        for i in 1:(nx + 1)
            @printf(f, "%.12e 0.0 0.0\n", (i - 1) * dx - lx / 2.0)
        end
        println(f, "POINT_DATA $(nx + 1)")
        println(f, "SCALARS temperature float 1")
        println(f, "LOOKUP_TABLE default")
        for val in temp
            @printf(f, "%.12e\n", val)
        end
    end
end
