"""Extract complete wand fronts from a plain-background concept sheet.

This script is a review-stage helper. It never writes into an upload folder.
It produces normalized candidates, a contact sheet, a mask preview, and JSON evidence.
"""

from __future__ import annotations

import argparse
import json
from array import array
from collections import deque
from pathlib import Path
from statistics import median

from PIL import Image, ImageChops, ImageDraw, ImageFilter


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--expected-count", type=int, required=True)
    parser.add_argument("--canvas", default="1024x2048")
    parser.add_argument("--object-height", type=int, default=1720)
    parser.add_argument("--edge-margin", type=int, default=8)
    parser.add_argument("--padding", type=int, default=64)
    return parser.parse_args()


def background_color(image: Image.Image) -> tuple[int, int, int]:
    pixels = image.load()
    w, h = image.size
    strip = max(2, min(w, h) // 80)
    samples = []
    for y in range(h):
        for x in range(w):
            if x < strip or x >= w - strip or y < strip or y >= h - strip:
                samples.append(pixels[x, y])
    return tuple(int(median(channel)) for channel in zip(*samples))


def make_mask(image: Image.Image, bg: tuple[int, int, int]) -> Image.Image:
    pixels = image.load()
    w, h = image.size
    mask = Image.new("L", image.size, 0)
    out = mask.load()
    for y in range(h):
        for x in range(w):
            r, g, b = pixels[x, y]
            max_diff = max(abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2]))
            saturation = max(r, g, b) - min(r, g, b)
            darkness = 255 - max(r, g, b)
            score = max(max_diff, saturation, darkness - (255 - max(bg)))
            if score >= 12:
                out[x, y] = 255
    # Bridge antialias gaps without joining neighboring wands.
    return mask.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(3))


def components(mask: Image.Image) -> tuple[list[dict], array]:
    w, h = mask.size
    data = mask.load()
    seen = bytearray(w * h)
    labels = array("H", [0]) * (w * h)
    found = []
    next_label = 1
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if seen[idx] or data[x, y] == 0:
                continue
            component_label = next_label
            next_label += 1
            queue = deque([(x, y)])
            seen[idx] = 1
            labels[idx] = component_label
            min_x = max_x = x
            min_y = max_y = y
            area = 0
            while queue:
                cx, cy = queue.popleft()
                area += 1
                min_x = min(min_x, cx)
                max_x = max(max_x, cx)
                min_y = min(min_y, cy)
                max_y = max(max_y, cy)
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h:
                        nidx = ny * w + nx
                        if not seen[nidx] and data[nx, ny] != 0:
                            seen[nidx] = 1
                            labels[nidx] = component_label
                            queue.append((nx, ny))
            box_w = max_x - min_x + 1
            box_h = max_y - min_y + 1
            if box_h >= h * 0.45 and area >= w * h * 0.001:
                found.append(
                    {
                        "bbox": [min_x, min_y, max_x + 1, max_y + 1],
                        "area": area,
                        "width": box_w,
                        "height": box_h,
                        "center_x": (min_x + max_x) / 2,
                        "label": component_label,
                    }
                )
    return sorted(found, key=lambda item: item["center_x"]), labels


def soft_alpha(crop: Image.Image, bg: tuple[int, int, int]) -> Image.Image:
    alpha = Image.new("L", crop.size, 0)
    src = crop.load()
    dst = alpha.load()
    for y in range(crop.height):
        for x in range(crop.width):
            r, g, b = src[x, y]
            diff = max(abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2]))
            saturation = max(r, g, b) - min(r, g, b)
            score = max(diff, saturation)
            if score <= 4:
                value = 0
            elif score >= 20:
                value = 255
            else:
                value = round((score - 4) / 16 * 255)
            dst[x, y] = value
    return alpha.filter(ImageFilter.GaussianBlur(0.6))


def main() -> int:
    args = parse_args()
    canvas_w, canvas_h = (int(value) for value in args.canvas.lower().split("x", 1))
    image = Image.open(args.source).convert("RGB")
    bg = background_color(image)
    mask = make_mask(image, bg)
    found, labels = components(mask)

    args.output_dir.mkdir(parents=True, exist_ok=True)
    mask.save(args.output_dir / "_foreground_mask.png")
    report = {
        "source": str(args.source),
        "source_size": list(image.size),
        "background": list(bg),
        "expected_count": args.expected_count,
        "detected_count": len(found),
        "status": "PASS" if len(found) == args.expected_count else "FAIL_COMPONENT_COUNT",
        "objects": [],
    }

    if len(found) != args.expected_count:
        (args.output_dir / "extraction_report.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return 2

    contact = Image.new("RGB", (220 * len(found), 460), (245, 245, 245))
    overlay = image.copy()
    overlay_draw = ImageDraw.Draw(overlay)
    overall_pass = True

    for index, item in enumerate(found, 1):
        left, top, right, bottom = item["bbox"]
        source_distances = {
            "left": left,
            "top": top,
            "right": image.width - right,
            "bottom": image.height - bottom,
        }
        source_edge_pass = min(source_distances.values()) > args.edge_margin
        overall_pass &= source_edge_pass

        local_padding = max(args.padding, round(item["width"] * 0.12))
        crop_box = (
            max(0, left - local_padding),
            max(0, top - local_padding),
            min(image.width, right + local_padding),
            min(image.height, bottom + local_padding),
        )
        crop = image.crop(crop_box)
        alpha = soft_alpha(crop, bg)
        component_alpha = Image.new("L", crop.size, 0)
        component_pixels = component_alpha.load()
        for local_y, source_y in enumerate(range(crop_box[1], crop_box[3])):
            row = source_y * image.width
            for local_x, source_x in enumerate(range(crop_box[0], crop_box[2])):
                if labels[row + source_x] == item["label"]:
                    component_pixels[local_x, local_y] = 255
        component_alpha = component_alpha.filter(ImageFilter.MaxFilter(3))
        alpha = ImageChops.multiply(alpha, component_alpha)
        rgba = crop.convert("RGBA")
        rgba.putalpha(alpha)

        alpha_bbox = alpha.getbbox()
        if alpha_bbox is None:
            object_crop = rgba
        else:
            object_crop = rgba.crop(alpha_bbox)
        scale = min(args.object_height / object_crop.height, (canvas_w - 128) / object_crop.width)
        target_size = (
            max(1, round(object_crop.width * scale)),
            max(1, round(object_crop.height * scale)),
        )
        resized = object_crop.resize(target_size, Image.Resampling.LANCZOS)
        canvas = Image.new("RGB", (canvas_w, canvas_h), bg)
        x = (canvas_w - resized.width) // 2
        y = (canvas_h - resized.height) // 2
        canvas.paste(resized.convert("RGB"), (x, y), resized.getchannel("A"))
        out = args.output_dir / f"front_{index:02d}.png"
        canvas.save(out)

        thumb = canvas.copy()
        thumb.thumbnail((210, 440), Image.Resampling.LANCZOS)
        contact.paste(thumb, ((index - 1) * 220 + (220 - thumb.width) // 2, (460 - thumb.height) // 2))
        color = (40, 190, 80) if source_edge_pass else (220, 40, 40)
        overlay_draw.rectangle((left, top, right - 1, bottom - 1), outline=color, width=2)
        overlay_draw.text((left, max(0, top - 14)), str(index), fill=color)

        report["objects"].append(
            {
                "index": index,
                "source_bbox": item["bbox"],
                "source_edge_distances": source_distances,
                "source_edge_pass": source_edge_pass,
                "safe_crop_bbox": list(crop_box),
                "normalized_size": list(target_size),
                "output": str(out),
            }
        )

    report["status"] = "PASS" if overall_pass else "FAIL_SOURCE_EDGE_TOUCH"
    contact.save(args.output_dir / "_contact_sheet.png")
    overlay.save(args.output_dir / "_source_bbox_overlay.png")
    (args.output_dir / "extraction_report.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if overall_pass else 3


if __name__ == "__main__":
    raise SystemExit(main())
