from __future__ import annotations

import math


Grid1D = list[float]
Grid2D = list[list[float]]


def initial_1d(name: str, nx: int, lx: float) -> Grid1D:
    dx = lx / nx
    values: Grid1D = []

    for i in range(nx + 1):
        x = i * dx - lx / 2.0
        if name == "semicircle":
            value = max(0.0, 1.0 - x * x)
            values.append(math.sqrt(value))
        elif name == "gaussian":
            values.append(math.exp(-40.0 * x * x))
        elif name == "sine":
            values.append(math.sin(math.pi * (x + lx / 2.0) / lx))
        else:
            raise ValueError(f"unknown 1-D initial condition: {name}")

    return values


def initial_2d(name: str, nx: int, ny: int, lx: float, ly: float) -> Grid2D:
    dx = lx / nx
    dy = ly / ny
    field = [[0.0 for _ in range(ny + 1)] for _ in range(nx + 1)]

    if name == "square":
        for i in range(nx // 4, 3 * nx // 4 + 1):
            for j in range(ny // 4, 3 * ny // 4 + 1):
                field[i][j] = 1.0
    elif name == "gaussian":
        for i in range(nx + 1):
            x = i * dx - lx / 2.0
            for j in range(ny + 1):
                y = j * dy - ly / 2.0
                field[i][j] = math.exp(-50.0 * (x * x + y * y))
    elif name == "sine":
        for i in range(nx + 1):
            x = i * dx
            for j in range(ny + 1):
                y = j * dy
                field[i][j] = math.sin(math.pi * x / lx) * math.sin(math.pi * y / ly)
    else:
        raise ValueError(f"unknown 2-D initial condition: {name}")

    return field
