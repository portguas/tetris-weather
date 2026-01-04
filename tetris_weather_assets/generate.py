#!/usr/bin/env python3
"""Generate Tetris Weather prototype SVGs and PNGs.

Creates a main app mock and three widget sizes using only stdlib + ImageMagick.
"""

from __future__ import annotations

from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent

PALETTE = {
    "B": "#4CC3FF",  # cold blue
    "C": "#73E8FF",  # ice cyan
    "G": "#7CF2C7",  # mild green
    "O": "#F7C266",  # warm orange
    "R": "#FF6B6B",  # hot / stormy
    "M": "#9C6BFF",  # unstable purple
    "H": "#8BF4FF",  # highlight / falling block
    ".": None,
}


def rect(
    x: float,
    y: float,
    w: float,
    h: float,
    *,
    fill: str,
    stroke: str | None = None,
    stroke_width: float = 1,
    rx: float | None = 0,
    opacity: float = 1.0,
) -> str:
    parts = [
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}"',
        f' opacity="{opacity}"' if opacity != 1 else "",
        f' stroke="{stroke}" stroke-width="{stroke_width}"' if stroke else "",
        f' rx="{rx}"' if rx else "",
        " />",
    ]
    return "".join(parts)


def text(
    x: float,
    y: float,
    content: str,
    *,
    size: int = 28,
    fill: str = "#e5edff",
    weight: int = 600,
    opacity: float = 1.0,
) -> str:
    return (
        f'<text x="{x}" y="{y}" fill="{fill}" font-family="Inter, SF Pro Display, sans-serif"'
        f' font-size="{size}" font-weight="{weight}" opacity="{opacity}">{content}</text>'
    )


def svg_doc(width: int, height: int, body: str, defs: str = "") -> str:
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg width="{width}px" height="{height}px" viewBox="0 0 {width} {height}"'
        ' xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">\n'
        f"<defs>{defs}</defs>\n{body}\n</svg>\n"
    )


def draw_grid(data: list[str], origin: tuple[int, int], cell: int, *, inset: int = 8) -> str:
    ox, oy = origin
    rows = len(data)
    cols = len(data[0])
    cells: list[str] = []
    grid_fill = "#121c33"
    for y in range(rows):
        for x in range(cols):
            cx = ox + x * cell
            cy = oy + y * cell
            cells.append(rect(cx, cy, cell, cell, fill=grid_fill, rx=10, opacity=0.35))
            code = data[y][x]
            if code == ".":
                continue
            color = PALETTE.get(code, PALETTE["G"])
            cells.append(
                rect(
                    cx + inset,
                    cy + inset,
                    cell - inset * 2,
                    cell - inset * 2,
                    fill=color,
                    rx=12,
                    stroke="#0c182c",
                    stroke_width=1.2,
                )
            )
    return "\n".join(cells)


def draw_piece(cells: list[tuple[int, int]], origin: tuple[int, int], cell: int) -> str:
    ox, oy = origin
    blocks: list[str] = []
    inset = 6
    for x, y in cells:
        cx = ox + x * cell
        cy = oy + y * cell
        blocks.append(
            rect(
                cx + inset,
                cy + inset,
                cell - inset * 2,
                cell - inset * 2,
                fill=PALETTE["H"],
                rx=14,
                stroke="#9cf6ff",
                stroke_width=2,
            )
        )
    return "\n".join(blocks)


def make_app() -> tuple[str, str]:
    width, height = 1080, 1920
    cell = 60
    grid_origin = (220, 280)
    grid_data = [
        "..........",
        "..........",
        ".....C....",
        "....CC....",
        "...BCG....",
        "...BCGG...",
        "..BBGGG...",
        "..BBGGGO..",
        ".BBGGGRO..",
        ".BBGGRRO..",
        "BBGGRROO..",
        "BBGGRROOR.",
        "BBGGRROORR",
        "BBGGRROORR",
    ]
    falling_piece = [(5, 0), (4, 1), (5, 1), (6, 1)]

    defs = """
    <linearGradient id="bgMain" x1="0%" x2="100%" y1="0%" y2="100%">
      <stop offset="0%" stop-color="#0b1220" />
      <stop offset="100%" stop-color="#0f1c3a" />
    </linearGradient>
    <linearGradient id="card" x1="0%" x2="0%" y1="0%" y2="100%">
      <stop offset="0%" stop-color="#101a2f" />
      <stop offset="100%" stop-color="#0c1324" />
    </linearGradient>
    """

    body = [
        rect(0, 0, width, height, fill="url(#bgMain)"),
        rect(200, 230, 680, 970, fill="url(#card)", rx=28, stroke="#1c2740", stroke_width=2),
        text(80, 130, "Tetris Weather", size=30, fill="#7cf2c7", weight=600),
        text(80, 180, "St. Petersburg · 09:30", size=48, fill="#e5edff", weight=700),
        text(80, 230, "Light Snow · Feels -6°C", size=26, fill="#a6c8ff", weight=500),
        draw_grid(grid_data, grid_origin, cell),
        draw_piece(falling_piece, grid_origin, cell),
        text(80, 1260, "Today is messy", size=40, fill="#e5edff", weight=700),
        text(80, 1310, "Chaotic stacking, expect flurries and gusts", size=24, fill="#8aa0c2", weight=500),
    ]

    chips = [
        (80, 1380, "Precip 70%"),
        (300, 1380, "Wind 22 km/h"),
        (560, 1380, "Pressure ↓"),
    ]
    for x, y, label in chips:
        body.append(rect(x, y - 32, 180, 54, fill="#142038", rx=18, stroke="#1f2d4b", stroke_width=1.5))
        body.append(text(x + 18, y, label, size=22, fill="#d8e3ff", weight=600))

    tips = [
        (80, 1455, "Swipe down for details"),
        (80, 1500, "Widgets mirror the stack hourly"),
    ]
    for x, y, label in tips:
        body.append(text(x, y, label, size=22, fill="#7384a9", weight=500))

    return "app_main", svg_doc(width, height, "\n".join(body), defs)


def make_widget_small() -> tuple[str, str]:
    width, height = 320, 320
    cell = 60
    origin = (40, 70)
    grid_data = [
        "BBG.",
        "BBOO",
        ".GRO",
        "..RO",
    ]
    defs = """
    <linearGradient id="bgSmall" x1="0%" x2="100%" y1="0%" y2="100%">
      <stop offset="0%" stop-color="#0f1628" />
      <stop offset="100%" stop-color="#0c1020" />
    </linearGradient>
    """
    body = [
        rect(0, 0, width, height, fill="url(#bgSmall)", rx=26, stroke="#1b233a", stroke_width=2),
        text(24, 46, "Now · -5°C", size=26, fill="#d8e3ff", weight=700),
        text(24, 72, "Snowy, calm", size=18, fill="#8aa0c2", weight=500),
        draw_grid(grid_data, origin, cell),
    ]
    return "widget_small", svg_doc(width, height, "\n".join(body), defs)


def make_widget_medium() -> tuple[str, str]:
    width, height = 460, 340
    cell = 36
    origin = (154, 44)
    grid_data = [
        ".B..",
        "BB..",
        "BG..",
        "BG..",
        "BGG.",
        "BGOO",
        "RGOR",
        "RGOR",
    ]
    defs = """
    <linearGradient id="bgMedium" x1="0%" x2="100%" y1="0%" y2="100%">
      <stop offset="0%" stop-color="#10182c" />
      <stop offset="100%" stop-color="#0c1324" />
    </linearGradient>
    """
    body = [
        rect(0, 0, width, height, fill="url(#bgMedium)", rx=26, stroke="#1b233a", stroke_width=2),
        text(24, 40, "Next 6h", size=26, fill="#d8e3ff", weight=700),
        text(24, 68, "Each column = 1h", size=18, fill="#8aa0c2", weight=500),
        draw_grid(grid_data, origin, cell),
    ]
    return "widget_medium", svg_doc(width, height, "\n".join(body), defs)


def make_widget_large() -> tuple[str, str]:
    width, height = 560, 560
    cell = 54
    origin = (54, 90)
    grid_data = [
        "..CCGG..",
        "..CCGG..",
        ".BBGGGO.",
        ".BBGGOO.",
        ".BBGROO.",
        "BBGGRROO",
        "BBGGRROO",
        "BBGGRROO",
    ]
    defs = """
    <linearGradient id="bgLarge" x1="0%" x2="100%" y1="0%" y2="100%">
      <stop offset="0%" stop-color="#0f182c" />
      <stop offset="100%" stop-color="#0c1020" />
    </linearGradient>
    """
    body = [
        rect(0, 0, width, height, fill="url(#bgLarge)", rx=30, stroke="#1b233a", stroke_width=2),
        text(24, 56, "Today trend", size=28, fill="#d8e3ff", weight=700),
        text(24, 84, "Line clear = sunny break", size=18, fill="#8aa0c2", weight=500),
        draw_grid(grid_data, origin, cell),
        rect(origin[0], origin[1] + cell * 4 - 6, cell * 8, 8, fill="#7cf2c7", opacity=0.5),
    ]
    return "widget_large", svg_doc(width, height, "\n".join(body), defs)


def save_and_convert(items: list[tuple[str, str]]) -> None:
    for name, content in items:
        svg_path = BASE / f"{name}.svg"
        png_path = BASE / f"{name}.png"
        svg_path.write_text(content)
        try:
            subprocess.run(["convert", str(svg_path), str(png_path)], check=True)
        except FileNotFoundError:
            print("convert command not found; SVG only created")
        except subprocess.CalledProcessError as err:
            print(f"convert failed for {name}: {err}")


def main() -> None:
    outputs = [
        make_app(),
        make_widget_small(),
        make_widget_medium(),
        make_widget_large(),
    ]
    save_and_convert(outputs)


if __name__ == "__main__":
    main()
