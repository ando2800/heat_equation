from __future__ import annotations


Grid1D = list[float]
Grid2D = list[list[float]]


def apply_boundary_1d(values: Grid1D, boundary: str) -> None:
    nx = len(values) - 1

    if boundary == "dirichlet":
        values[0] = 0.0
        values[nx] = 0.0
    elif boundary == "neumann":
        values[0] = values[1]
        values[nx] = values[nx - 1]
    elif boundary == "periodic":
        values[0] = values[nx - 1]
        values[nx] = values[1]
    else:
        raise ValueError(f"unknown 1-D boundary condition: {boundary}")


def apply_boundary_2d(field: Grid2D, boundary: str) -> None:
    nx = len(field) - 1
    ny = len(field[0]) - 1

    if boundary == "dirichlet":
        for i in range(nx + 1):
            field[i][0] = 0.0
            field[i][ny] = 0.0
        for j in range(ny + 1):
            field[0][j] = 0.0
            field[nx][j] = 0.0
    elif boundary == "neumann":
        for i in range(1, nx):
            field[i][0] = field[i][1]
            field[i][ny] = field[i][ny - 1]
        for j in range(1, ny):
            field[0][j] = field[1][j]
            field[nx][j] = field[nx - 1][j]
        field[0][0] = field[1][1]
        field[0][ny] = field[1][ny - 1]
        field[nx][0] = field[nx - 1][1]
        field[nx][ny] = field[nx - 1][ny - 1]
    elif boundary == "periodic":
        for i in range(1, nx):
            field[i][0] = field[i][ny - 1]
            field[i][ny] = field[i][1]
        for j in range(1, ny):
            field[0][j] = field[nx - 1][j]
            field[nx][j] = field[1][j]
        field[0][0] = field[nx - 1][ny - 1]
        field[0][ny] = field[nx - 1][1]
        field[nx][0] = field[1][ny - 1]
        field[nx][ny] = field[1][1]
    else:
        raise ValueError(f"unknown 2-D boundary condition: {boundary}")
