#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from heat.config import Config1D
from heat.solver_1d import solve


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Solve the 1-D heat equation.")
    parser.add_argument("--nx", type=int, default=Config1D.nx)
    parser.add_argument("--nt", type=int, default=Config1D.nt)
    parser.add_argument("--dt", type=float, default=Config1D.dt)
    parser.add_argument("--alpha", type=float, default=Config1D.alpha)
    parser.add_argument("--lx", type=float, default=Config1D.lx)
    parser.add_argument("--output-every", type=int, default=Config1D.output_every)
    parser.add_argument("--output-dir", type=Path, default=Config1D.output_dir)
    parser.add_argument("--initial", choices=["semicircle", "gaussian", "sine"], default=Config1D.initial)
    parser.add_argument("--boundary", choices=["dirichlet", "neumann", "periodic"], default=Config1D.boundary)
    parser.add_argument("--no-vtk", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    solve(
        Config1D(
            nx=args.nx,
            nt=args.nt,
            dt=args.dt,
            alpha=args.alpha,
            lx=args.lx,
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
