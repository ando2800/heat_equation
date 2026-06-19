module Heat

include("initial_condition.jl")
include("boundary_condition.jl")
include("io_field.jl")
include("solver_1d.jl")

export solve_heat_1d

end
