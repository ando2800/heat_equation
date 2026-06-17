from __future__ import annotations

from .boundary_condition import apply_boundary_1d
from .config import Config1D
from .initial_condition import initial_1d
from .io import write_profile, write_vtk_1d


def solve(config: Config1D) -> None:
    dx = config.lx / config.nx
    r = config.alpha * config.dt / (dx * dx)

    if r > 0.5:
        dt_max = 0.5 * dx * dx / config.alpha
        raise ValueError(f"unstable time step: r={r:.6g}. Use dt <= {dt_max:.6g}")

    temperature = initial_1d(config.initial, config.nx, config.lx)
    apply_boundary_1d(temperature, config.boundary)
    frame = 0
    write_profile(config.output_dir, frame, temperature, dx, config.lx)
    if config.vtk:
        write_vtk_1d(config.output_dir / f"temp.{frame:04d}.vtk", temperature, dx, config.lx)

    for step in range(1, config.nt + 1):
        next_temperature = temperature.copy()

        for i in range(1, config.nx):
            laplacian = (temperature[i + 1] - 2.0 * temperature[i] + temperature[i - 1]) / (dx * dx)
            next_temperature[i] = temperature[i] + config.alpha * config.dt * laplacian

        apply_boundary_1d(next_temperature, config.boundary)
        temperature = next_temperature

        if step % config.output_every == 0:
            frame += 1
            write_profile(config.output_dir, frame, temperature, dx, config.lx)
            if config.vtk:
                write_vtk_1d(config.output_dir / f"temp.{frame:04d}.vtk", temperature, dx, config.lx)
