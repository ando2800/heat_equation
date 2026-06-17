from __future__ import annotations

from .boundary_condition import apply_boundary_2d
from .config import Config2D
from .initial_condition import initial_2d
from .io import write_field, write_vtk_2d


def solve(config: Config2D) -> None:
    dx = config.lx / config.nx
    dy = config.ly / config.ny
    dt = config.dt if config.dt is not None else 0.25 * min(dx, dy) ** 2 / config.alpha
    stability_limit = 1.0 / (2.0 * config.alpha * (1.0 / (dx * dx) + 1.0 / (dy * dy)))

    if dt > stability_limit:
        raise ValueError(f"unstable time step: dt={dt:.6g}. Use dt <= {stability_limit:.6g}")

    field = initial_2d(config.initial, config.nx, config.ny, config.lx, config.ly)
    next_field = [[0.0 for _ in range(config.ny + 1)] for _ in range(config.nx + 1)]
    apply_boundary_2d(field, config.boundary)

    frame = 0
    write_field(config.output_dir / f"field.{frame:04d}", field, dx, dy)
    if config.vtk:
        write_vtk_2d(config.output_dir / f"field.{frame:04d}.vtk", field, dx, dy)

    for step in range(1, config.nt + 1):
        apply_boundary_2d(field, config.boundary)

        for i in range(1, config.nx):
            for j in range(1, config.ny):
                d2x = (field[i + 1][j] - 2.0 * field[i][j] + field[i - 1][j]) / (dx * dx)
                d2y = (field[i][j + 1] - 2.0 * field[i][j] + field[i][j - 1]) / (dy * dy)
                next_field[i][j] = field[i][j] + config.alpha * dt * (d2x + d2y)

        apply_boundary_2d(next_field, config.boundary)
        field, next_field = next_field, field

        if step % config.output_every == 0:
            frame += 1
            write_field(config.output_dir / f"field.{frame:04d}", field, dx, dy)
            if config.vtk:
                write_vtk_2d(config.output_dir / f"field.{frame:04d}.vtk", field, dx, dy)

        if step % 100 == 0:
            print(f"Step: {step}")

    write_field(config.output_dir / "result.dat", field, dx, dy)
    if config.vtk:
        write_vtk_2d(config.output_dir / "result.vtk", field, dx, dy)
