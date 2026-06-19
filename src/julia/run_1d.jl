include(joinpath(@__DIR__, "heat", "Heat.jl"))
using .Heat

const NX           = 32
const NT           = 2500
const OUTPUT_EVERY = 50
const DT           = 1.0e-3
const ALPHA        = 1.0
const LX           = 2.0

output_dir = get(ARGS, 1, "output/julia/1d")
initial    = get(ARGS, 2, "semicircle")
boundary   = get(ARGS, 3, "dirichlet")
method     = get(ARGS, 4, "euler")
vtk        = !(length(ARGS) >= 5 && ARGS[5] == "no-vtk")

solve_heat_1d(
    nx           = NX,
    nt           = NT,
    output_every = OUTPUT_EVERY,
    dt           = DT,
    alpha        = ALPHA,
    lx           = LX,
    output_dir   = output_dir,
    initial      = initial,
    boundary     = boundary,
    vtk          = vtk,
    method       = method,
)

println("Calculation finished. Output directory: $output_dir")
