from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Config1D:
    nx: int = 32
    nt: int = 2500
    dt: float = 1.0e-3
    alpha: float = 1.0
    lx: float = 2.0
    output_every: int = 50
    output_dir: Path = Path("output/python/1d")
    initial: str = "semicircle"
    boundary: str = "dirichlet"
    vtk: bool = True


@dataclass(frozen=True)
class Config2D:
    nx: int = 50
    ny: int = 50
    nt: int = 500
    dt: float | None = None
    alpha: float = 0.01
    lx: float = 1.0
    ly: float = 1.0
    output_dir: Path = Path("output/python/2d")
    output_every: int = 10
    initial: str = "square"
    boundary: str = "dirichlet"
    vtk: bool = True
