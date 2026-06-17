from __future__ import annotations

from pathlib import Path


Grid1D = list[float]
Grid2D = list[list[float]]


def write_profile(output_dir: Path, index: int, values: Grid1D, dx: float, lx: float) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / f"temp.{index:04d}"

    with output_file.open("w", encoding="utf-8") as file:
        for i, value in enumerate(values):
            x = i * dx - lx / 2.0
            file.write(f"{x:.12e} {value:.12e}\n")


def write_field(output_file: Path, field: Grid2D, dx: float, dy: float) -> None:
    output_file.parent.mkdir(parents=True, exist_ok=True)
    nx = len(field) - 1
    ny = len(field[0]) - 1

    with output_file.open("w", encoding="utf-8") as file:
        for j in range(ny + 1):
            for i in range(nx + 1):
                file.write(f"{i * dx:.12e} {j * dy:.12e} {field[i][j]:.12e}\n")
            file.write("\n")


def write_vtk_1d(output_file: Path, values: Grid1D, dx: float, lx: float) -> None:
    output_file.parent.mkdir(parents=True, exist_ok=True)
    nx = len(values) - 1

    with output_file.open("w", encoding="utf-8") as file:
        file.write("# vtk DataFile Version 3.0\n")
        file.write("1-D heat equation\n")
        file.write("ASCII\n")
        file.write("DATASET STRUCTURED_GRID\n")
        file.write(f"DIMENSIONS {nx + 1} 1 1\n")
        file.write(f"POINTS {nx + 1} float\n")
        for i in range(nx + 1):
            file.write(f"{i * dx - lx / 2.0:.12e} 0.0 0.0\n")
        file.write(f"POINT_DATA {nx + 1}\n")
        file.write("SCALARS temperature float 1\n")
        file.write("LOOKUP_TABLE default\n")
        for value in values:
            file.write(f"{value:.12e}\n")


def write_vtk_2d(output_file: Path, field: Grid2D, dx: float, dy: float) -> None:
    output_file.parent.mkdir(parents=True, exist_ok=True)
    nx = len(field) - 1
    ny = len(field[0]) - 1

    with output_file.open("w", encoding="utf-8") as file:
        file.write("# vtk DataFile Version 3.0\n")
        file.write("2-D heat equation\n")
        file.write("ASCII\n")
        file.write("DATASET STRUCTURED_POINTS\n")
        file.write(f"DIMENSIONS {nx + 1} {ny + 1} 1\n")
        file.write("ORIGIN 0.0 0.0 0.0\n")
        file.write(f"SPACING {dx:.12e} {dy:.12e} 1.0\n")
        file.write(f"POINT_DATA {(nx + 1) * (ny + 1)}\n")
        file.write("SCALARS temperature float 1\n")
        file.write("LOOKUP_TABLE default\n")
        for j in range(ny + 1):
            for i in range(nx + 1):
                file.write(f"{field[i][j]:.12e}\n")
