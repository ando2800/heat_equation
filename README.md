# Heat Equation

1次元・2次元の熱伝導方程式を Python と Fortran で解くための作業ディレクトリです。

## Directory Layout

```text
heat_equation/
├── src/
│   ├── python/      # Python source files
│   ├── fortran/     # Fortran source files
│   └── julia/       # Julia source files
├── scripts/         # Plotting and helper scripts
├── figure/          # Figures and animations
├── output/          # Simulation output files
└── bin/             # Executable files
```

## Top-Level Commands

```sh
make build        # Build Fortran executables
make run-python   # Run Python 1-D and 2-D solvers
make run-fortran  # Run Fortran 1-D and 2-D solvers
make animation    # Create Python/Fortran animations
make clean        # Remove generated output, figures, and Fortran binaries
```

## Python Solvers

```sh
python3 src/python/run_1d.py --initial gaussian --boundary neumann
python3 src/python/run_2d.py --initial sine --boundary periodic
```

Available initial conditions:

- 1-D: `semicircle`, `gaussian`, `sine`
- 2-D: `square`, `gaussian`, `sine`

Available boundary conditions:

- `dirichlet`
- `neumann`
- `periodic`

Default outputs:

- `output/python/1d/temp.0000`, `temp.0000.vtk`, ...
- `output/python/2d/field.0000`, `field.0000.vtk`, ...
- `output/python/2d/result.dat`
- `output/python/2d/result.vtk`

The `.vtk` files can be opened in ParaView.

## Create Animations

```sh
python3 scripts/animate_heat_1d.py
python3 scripts/animate_heat_2d.py
```

Default outputs:

- `figure/heat_1d.mp4`
- `figure/heat_1d.gif`
- `figure/heat_2d.mp4`
- `figure/heat_2d.gif`

## Fortran Solvers

```sh
make build
./bin/heat_1d output/fortran/1d gaussian neumann
./bin/heat_2d output/fortran/2d sine periodic
```

Default build output:

- `bin/heat_1d`
- `bin/heat_2d`
- `src/fortran/tmp/*.mod`

Fortran positional arguments:

```text
heat_1d [output_dir] [initial] [boundary] [no-vtk]
heat_2d [output_dir] [initial] [boundary] [no-vtk]
```
