#!/usr/bin/env python3
"""Create a 2-D heat-equation heatmap animation."""

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


Color = tuple[int, int, int]
Grid = list[list[float]]
Image = list[list[Color]]


def color_map(value: float, value_min: float, value_max: float) -> Color:
    if value_max <= value_min:
        t = 0.0
    else:
        t = max(0.0, min(1.0, (value - value_min) / (value_max - value_min)))

    if t < 0.5:
        q = 2.0 * t
        return (round(40 * (1 - q) + 245 * q), round(80 * (1 - q) + 245 * q), 230)

    q = 2.0 * (t - 0.5)
    return (245, round(245 * (1 - q) + 50 * q), round(230 * (1 - q) + 40 * q))


def apply_boundary(field: Grid, nx: int, ny: int) -> None:
    for i in range(nx + 1):
        field[i][0] = 0.0
        field[i][ny] = 0.0

    for j in range(ny + 1):
        field[0][j] = 0.0
        field[nx][j] = 0.0


def write_ppm(path: Path, image: Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    height = len(image)
    width = len(image[0])

    with path.open("wb") as file:
        file.write(f"P6\n{width} {height}\n255\n".encode())
        for row in image:
            for color in row:
                file.write(bytes(color))


def render_heatmap(path: Path, field: Grid, nx: int, ny: int, image_size: int = 512) -> None:
    values = [field[i][j] for i in range(nx + 1) for j in range(ny + 1)]
    value_min = min(values)
    value_max = max(values)
    image: Image = []

    for py in range(image_size):
        row: list[Color] = []
        j = ny - round(py / (image_size - 1) * ny)
        for px in range(image_size):
            i = round(px / (image_size - 1) * nx)
            row.append(color_map(field[i][j], value_min, value_max))
        image.append(row)

    write_ppm(path, image)


def encode_animation(frames_dir: Path, output_base: Path, fps: int) -> None:
    ffmpeg = shutil.which("ffmpeg")
    if ffmpeg is None:
        print(f"ffmpeg not found. Frames were written to {frames_dir}")
        return

    output_base.parent.mkdir(parents=True, exist_ok=True)
    pattern = str(frames_dir / "frame_%04d.ppm")
    mp4 = output_base.with_suffix(".mp4")
    gif = output_base.with_suffix(".gif")

    subprocess.run(
        [ffmpeg, "-y", "-framerate", str(fps), "-i", pattern, "-pix_fmt", "yuv420p", str(mp4)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        [ffmpeg, "-y", "-framerate", str(fps), "-i", pattern, str(gif)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def create_animation(
    nx: int,
    ny: int,
    nt: int,
    alpha: float,
    lx: float,
    ly: float,
    frame_every: int,
    frames_dir: Path,
    output: Path,
    fps: int,
) -> None:
    dx = lx / nx
    dy = ly / ny
    dt = 0.25 * min(dx, dy) ** 2 / alpha

    field = [[0.0 for _ in range(ny + 1)] for _ in range(nx + 1)]
    next_field = [[0.0 for _ in range(ny + 1)] for _ in range(nx + 1)]

    for i in range(nx // 4, 3 * nx // 4 + 1):
        for j in range(ny // 4, 3 * ny // 4 + 1):
            field[i][j] = 1.0

    frames_dir.mkdir(parents=True, exist_ok=True)
    for old_frame in frames_dir.glob("frame_*.ppm"):
        old_frame.unlink()

    frame_index = 0
    render_heatmap(frames_dir / f"frame_{frame_index:04d}.ppm", field, nx, ny)

    for step in range(1, nt + 1):
        apply_boundary(field, nx, ny)

        for i in range(1, nx):
            for j in range(1, ny):
                d2x = (field[i + 1][j] - 2.0 * field[i][j] + field[i - 1][j]) / (dx * dx)
                d2y = (field[i][j + 1] - 2.0 * field[i][j] + field[i][j - 1]) / (dy * dy)
                next_field[i][j] = field[i][j] + alpha * dt * (d2x + d2y)

        apply_boundary(next_field, nx, ny)
        field, next_field = next_field, field

        if step % frame_every == 0:
            frame_index += 1
            render_heatmap(frames_dir / f"frame_{frame_index:04d}.ppm", field, nx, ny)

    encode_animation(frames_dir, output, fps)
    print(f"Animation written to {output.with_suffix('.mp4')} and {output.with_suffix('.gif')}")


def read_field(path: Path) -> tuple[Grid, int, int]:
    points: list[tuple[float, float, float]] = []
    xs: set[float] = set()
    ys: set[float] = set()

    with path.open(encoding="utf-8") as file:
        for line in file:
            if not line.strip():
                continue
            x, y, value = line.split()[:3]
            point = (float(x), float(y), float(value))
            points.append(point)
            xs.add(point[0])
            ys.add(point[1])

    sorted_xs = sorted(xs)
    sorted_ys = sorted(ys)
    x_index = {x: i for i, x in enumerate(sorted_xs)}
    y_index = {y: j for j, y in enumerate(sorted_ys)}
    nx = len(sorted_xs) - 1
    ny = len(sorted_ys) - 1
    field = [[0.0 for _ in range(ny + 1)] for _ in range(nx + 1)]

    for x, y, value in points:
        field[x_index[x]][y_index[y]] = value

    return field, nx, ny


def create_animation_from_files(input_dir: Path, frames_dir: Path, output: Path, fps: int) -> None:
    files = sorted(file for file in input_dir.glob("field.*") if file.suffix != ".vtk")
    if not files:
        raise FileNotFoundError(f"no field files found in {input_dir}")

    frames_dir.mkdir(parents=True, exist_ok=True)
    for old_frame in frames_dir.glob("frame_*.ppm"):
        old_frame.unlink()

    for frame_index, file in enumerate(files):
        field, nx, ny = read_field(file)
        render_heatmap(frames_dir / f"frame_{frame_index:04d}.ppm", field, nx, ny)

    encode_animation(frames_dir, output, fps)
    print(f"Animation written to {output.with_suffix('.mp4')} and {output.with_suffix('.gif')}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create a 2-D heat-equation animation.")
    parser.add_argument("--input-dir", type=Path, default=None)
    parser.add_argument("--nx", type=int, default=50)
    parser.add_argument("--ny", type=int, default=50)
    parser.add_argument("--nt", type=int, default=500)
    parser.add_argument("--alpha", type=float, default=0.01)
    parser.add_argument("--lx", type=float, default=1.0)
    parser.add_argument("--ly", type=float, default=1.0)
    parser.add_argument("--frame-every", type=int, default=10)
    parser.add_argument("--frames-dir", type=Path, default=Path("figure/frames_2d"))
    parser.add_argument("--output", type=Path, default=Path("figure/heat_2d"))
    parser.add_argument("--fps", type=int, default=12)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.input_dir is not None:
        create_animation_from_files(
            input_dir=args.input_dir,
            frames_dir=args.frames_dir,
            output=args.output,
            fps=args.fps,
        )
        return

    create_animation(
        nx=args.nx,
        ny=args.ny,
        nt=args.nt,
        alpha=args.alpha,
        lx=args.lx,
        ly=args.ly,
        frame_every=args.frame_every,
        frames_dir=args.frames_dir,
        output=args.output,
        fps=args.fps,
    )


if __name__ == "__main__":
    main()
