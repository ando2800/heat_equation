#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from heat.config import Config2D
from heat.solver_2d import solve


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Solve the 2-D heat equation.")
    parser.add_argument("--nx", type=int, default=Config2D.nx)
    parser.add_argument("--ny", type=int, default=Config2D.ny)
    parser.add_argument("--nt", type=int, default=Config2D.nt)
    parser.add_argument("--dt", type=float, default=Config2D.dt)
    parser.add_argument("--alpha", type=float, default=Config2D.alpha)
    parser.add_argument("--lx", type=float, default=Config2D.lx)
    parser.add_argument("--ly", type=float, default=Config2D.ly)
    parser.add_argument("--output-every", type=int, default=Config2D.output_every)
    parser.add_argument("--output-dir", type=Path, default=Config2D.output_dir)
    parser.add_argument("--initial", choices=["square", "gaussian", "sine"], default=Config2D.initial)
    parser.add_argument("--boundary", choices=["dirichlet", "neumann", "periodic"], default=Config2D.boundary)
    parser.add_argument("--no-vtk", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    solve(
        Config2D(
            nx=args.nx,
            ny=args.ny,
            nt=args.nt,
            dt=args.dt,
            alpha=args.alpha,
            lx=args.lx,
            ly=args.ly,
            output_every=args.output_every,
            output_dir=args.output_dir,
            initial=args.initial,
            boundary=args.boundary,
            vtk=not args.no_vtk,
        )
    )
    print(f"Calculation finished. Output directory: {args.output_dir}")


if __name__ == "__main__":
    main()
