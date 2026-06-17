#!/usr/bin/env python3
"""Create an animation from 1-D heat-equation profile files."""

from __future__ import annotations

import argparse
import math
import shutil
import subprocess
from pathlib import Path


Color = tuple[int, int, int]
Image = list[list[Color]]


def new_image(width: int, height: int, color: Color = (255, 255, 255)) -> Image:
    return [[color for _ in range(width)] for _ in range(height)]


def set_pixel(image: Image, x: int, y: int, color: Color) -> None:
    if 0 <= y < len(image) and 0 <= x < len(image[0]):
        image[y][x] = color


def draw_line(image: Image, x0: int, y0: int, x1: int, y1: int, color: Color) -> None:
    dx = abs(x1 - x0)
    dy = -abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx + dy

    while True:
        set_pixel(image, x0, y0, color)
        if x0 == x1 and y0 == y1:
            break
        err2 = 2 * err
        if err2 >= dy:
            err += dy
            x0 += sx
        if err2 <= dx:
            err += dx
            y0 += sy


def draw_thick_line(image: Image, x0: int, y0: int, x1: int, y1: int, color: Color, radius: int = 1) -> None:
    for ox in range(-radius, radius + 1):
        for oy in range(-radius, radius + 1):
            draw_line(image, x0 + ox, y0 + oy, x1 + ox, y1 + oy, color)


def draw_rect(image: Image, x0: int, y0: int, x1: int, y1: int, color: Color) -> None:
    for x in range(x0, x1 + 1):
        set_pixel(image, x, y0, color)
        set_pixel(image, x, y1, color)
    for y in range(y0, y1 + 1):
        set_pixel(image, x0, y, color)
        set_pixel(image, x1, y, color)


def write_ppm(path: Path, image: Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    height = len(image)
    width = len(image[0])

    with path.open("wb") as file:
        file.write(f"P6\n{width} {height}\n255\n".encode())
        for row in image:
            for color in row:
                file.write(bytes(color))


def read_profile(path: Path) -> tuple[list[float], list[float]]:
    xs: list[float] = []
    values: list[float] = []

    with path.open(encoding="utf-8") as file:
        for line in file:
            if not line.strip():
                continue
            x, value = line.split()[:2]
            xs.append(float(x))
            values.append(float(value))

    return xs, values


def render_frame(path: Path, xs: list[float], values: list[float], frame_index: int, total_frames: int) -> None:
    width = 800
    height = 500
    margin_left = 70
    margin_right = 35
    margin_top = 35
    margin_bottom = 60
    image = new_image(width, height)

    plot_x0 = margin_left
    plot_x1 = width - margin_right
    plot_y0 = margin_top
    plot_y1 = height - margin_bottom
    draw_rect(image, plot_x0, plot_y0, plot_x1, plot_y1, (40, 40, 40))

    xmin = min(xs)
    xmax = max(xs)
    ymax = max(1.0, max(values))
    ymin = 0.0

    points: list[tuple[int, int]] = []
    for x, value in zip(xs, values):
        px = plot_x0 + round((x - xmin) / (xmax - xmin) * (plot_x1 - plot_x0))
        py = plot_y1 - round((value - ymin) / (ymax - ymin) * (plot_y1 - plot_y0))
        points.append((px, py))

    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        draw_thick_line(image, x0, y0, x1, y1, (220, 40, 40), radius=1)

    progress = frame_index / max(1, total_frames - 1)
    bar_x1 = plot_x0 + round(progress * (plot_x1 - plot_x0))
    for y in range(height - 30, height - 22):
        for x in range(plot_x0, bar_x1 + 1):
            set_pixel(image, x, y, (40, 110, 220))

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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create a 1-D heat-equation animation.")
    parser.add_argument("--input-dir", type=Path, default=Path("output/python/1d"))
    parser.add_argument("--frames-dir", type=Path, default=Path("figure/frames_1d"))
    parser.add_argument("--output", type=Path, default=Path("figure/heat_1d"))
    parser.add_argument("--fps", type=int, default=12)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    files = sorted(file for file in args.input_dir.glob("temp.*") if file.suffix != ".vtk")
    if not files:
        raise FileNotFoundError(f"no profile files found in {args.input_dir}")

    args.frames_dir.mkdir(parents=True, exist_ok=True)
    for old_frame in args.frames_dir.glob("frame_*.ppm"):
        old_frame.unlink()

    for frame_index, file in enumerate(files):
        xs, values = read_profile(file)
        render_frame(args.frames_dir / f"frame_{frame_index:04d}.ppm", xs, values, frame_index, len(files))

    encode_animation(args.frames_dir, args.output, args.fps)
    print(f"Animation written to {args.output.with_suffix('.mp4')} and {args.output.with_suffix('.gif')}")


if __name__ == "__main__":
    main()
