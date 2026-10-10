"""Fast-path exporter for an already-normalized rigid multi-part Blender asset.

The script exports one GLB, reimports that exact GLB into a factory-empty
Blender scene, verifies the assembly contract, and writes a compact JSON audit.
It never saves or modifies the source .blend.

Example:
    blender -b Asset_ROBLOX_EXPORT_v01.blend \
      --python export_multi_part_glb_fast.py -- \
      --asset-name MyWeapon_v01
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

import bpy
from mathutils import Vector


EPSILON = 0.001


class WorkflowError(RuntimeError):
    def __init__(self, code: str, message: str) -> None:
        super().__init__(message)
        self.code = code


def parse_args() -> argparse.Namespace:
    argv = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--asset-name", required=True, help="ASCII package name, preferably including version")
    parser.add_argument("--output-root", help="Defaults to Documents/RobloxImportPackages/<asset>_IMPORT_ONLY")
    parser.add_argument("--parts", help="Optional comma-separated exact mesh object names")
    parser.add_argument("--allow-untextured", action="store_true")
    parser.add_argument("--overwrite", action="store_true")
    return parser.parse_args(argv)


def fail(code: str, message: str) -> None:
    raise WorkflowError(code, message)


def triangle_count(obj: bpy.types.Object) -> int:
    return sum(max(0, len(polygon.vertices) - 2) for polygon in obj.data.polygons)


def world_dimensions(obj: bpy.types.Object) -> list[float]:
    points = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    return [
        round(max(point[index] for point in points) - min(point[index] for point in points), 6)
        for index in range(3)
    ]


def assembly_dimensions(meshes: list[bpy.types.Object]) -> list[float]:
    points: list[Vector] = []
    for obj in meshes:
        points.extend(obj.matrix_world @ Vector(corner) for corner in obj.bound_box)
    return [
        round(max(point[index] for point in points) - min(point[index] for point in points), 6)
        for index in range(3)
    ]


def image_nodes(obj: bpy.types.Object) -> list[bpy.types.Node]:
    nodes: list[bpy.types.Node] = []
    for slot in obj.material_slots:
        material = slot.material
        if material is None or material.node_tree is None:
            continue
        for node in material.node_tree.nodes:
            if node.bl_idname == "ShaderNodeTexImage" and node.image is not None:
                nodes.append(node)
    return nodes


def mesh_record(obj: bpy.types.Object) -> dict:
    materials = [slot.material for slot in obj.material_slots if slot.material]
    nodes = image_nodes(obj)
    return {
        "name": obj.name,
        "vertices": len(obj.data.vertices),
        "triangles": triangle_count(obj),
        "material_count": len(materials),
        "image_count": len({node.image.name for node in nodes}),
        "image_sizes": sorted({tuple(node.image.size) for node in nodes}),
        "location": [round(value, 6) for value in obj.location],
        "rotation": [round(value, 6) for value in obj.rotation_euler],
        "scale": [round(value, 6) for value in obj.scale],
        "dimensions": world_dimensions(obj),
    }


def close_enough(left: list[float], right: list[float]) -> bool:
    return len(left) == len(right) and all(abs(a - b) <= EPSILON for a, b in zip(left, right))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def select_formal_meshes(args: argparse.Namespace) -> list[bpy.types.Object]:
    all_meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    if not all_meshes:
        fail("NO_MESH", "The scene contains no mesh objects")

    if args.parts:
        requested = [name.strip() for name in args.parts.split(",") if name.strip()]
        by_name = {obj.name: obj for obj in all_meshes}
        missing = [name for name in requested if name not in by_name]
        if missing:
            fail("FORMAL_PART_NOT_FOUND", f"Missing requested mesh objects: {missing}")
        meshes = [by_name[name] for name in requested]
    else:
        source_name = Path(bpy.data.filepath).stem.upper()
        if "ROBLOX_EXPORT" not in source_name:
            fail(
                "EXPORT_COPY_REQUIRED",
                "Fast mode without --parts only accepts a *_ROBLOX_EXPORT_vNN.blend copy",
            )
        hidden = [obj.name for obj in all_meshes if obj.hide_get() or obj.hide_viewport]
        if hidden:
            fail(
                "FORMAL_PART_SCOPE_AMBIGUOUS",
                f"Hidden mesh candidates exist; pass --parts with the formal names: {hidden}",
            )
        meshes = all_meshes

    return sorted(meshes, key=lambda obj: obj.name)


def validate_source(meshes: list[bpy.types.Object], allow_untextured: bool) -> dict:
    if any(not obj.name.isascii() for obj in meshes):
        fail("NON_ASCII_PART_NAME", f"Rename formal parts to ASCII: {[obj.name for obj in meshes]}")

    origins = []
    for obj in meshes:
        record = mesh_record(obj)
        if obj.parent is not None or obj.constraints:
            fail("PART_TRANSFORM_NOT_BAKED", f"{obj.name} still has a parent or constraint")
        if obj.data.shape_keys is not None:
            fail("SHAPE_KEYS_UNSUPPORTED", f"{obj.name} contains shape keys; use the full workflow")
        if not close_enough(record["location"], [0.0, 0.0, 0.0]):
            fail("PART_TRANSFORM_NOT_BAKED", f"{obj.name} Location is {record['location']}, expected 0/0/0")
        if not close_enough(record["rotation"], [0.0, 0.0, 0.0]):
            fail("PART_TRANSFORM_NOT_BAKED", f"{obj.name} Rotation is {record['rotation']}, expected 0/0/0")
        if not close_enough(record["scale"], [1.0, 1.0, 1.0]):
            fail("PART_TRANSFORM_NOT_BAKED", f"{obj.name} Scale is {record['scale']}, expected 1/1/1")
        if record["material_count"] != 1 and not allow_untextured:
            fail("MATERIAL_CONTRACT_FAILED", f"{obj.name} has {record['material_count']} materials, expected 1")
        if record["image_count"] < 1 and not allow_untextured:
            fail("TEXTURE_REFERENCE_BROKEN", f"{obj.name} has no image texture")
        if len(obj.data.uv_layers) != 1 and not allow_untextured:
            fail("UV_CONTRACT_FAILED", f"{obj.name} has {len(obj.data.uv_layers)} UV sets, expected 1")
        origins.append(tuple(round(value, 6) for value in obj.matrix_world.translation))

    if len(set(origins)) != 1:
        fail("PART_PIVOT_MISMATCH", f"Formal part origins differ: {origins}")

    return {
        "parts": {obj.name: mesh_record(obj) for obj in meshes},
        "total_dimensions": assembly_dimensions(meshes),
    }


def texture_label(source: dict) -> str:
    sizes = {
        tuple(size)
        for record in source["parts"].values()
        for size in record["image_sizes"]
    }
    if len(sizes) == 1:
        width, height = next(iter(sizes))
        if width == height:
            return f"{width}tex"
    if not sizes:
        return "notex"
    return "mixedtex"


def export_glb(path: Path, meshes: list[bpy.types.Object]) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.hide_set(False)
        obj.hide_viewport = False
        obj.hide_render = False
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    result = bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
        export_texcoords=True,
        export_normals=True,
        export_tangents=False,
        export_animations=False,
        export_skins=False,
        export_morph=False,
        export_lights=False,
        export_cameras=False,
        export_extras=False,
        export_draco_mesh_compression_enable=False,
    )
    if result != {"FINISHED"} or not path.is_file():
        fail("GLB_EXPORT_FAILED", f"Blender export returned {result}")


def verify_glb(path: Path, source: dict, allow_untextured: bool) -> dict:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    result = bpy.ops.import_scene.gltf(filepath=str(path))
    if result != {"FINISHED"}:
        fail("GLB_ROUNDTRIP_FAILED", f"Blender import returned {result}")

    meshes = sorted((obj for obj in bpy.data.objects if obj.type == "MESH"), key=lambda obj: obj.name)
    actual = {
        "parts": {obj.name: mesh_record(obj) for obj in meshes},
        "total_dimensions": assembly_dimensions(meshes) if meshes else [0.0, 0.0, 0.0],
        "extra_objects": sorted(obj.name for obj in bpy.data.objects if obj.type != "MESH"),
    }
    problems: list[str] = []
    if set(source["parts"]) != set(actual["parts"]):
        problems.append(f"part names differ: {sorted(actual['parts'])}")
    for name in sorted(set(source["parts"]) & set(actual["parts"])):
        expected = source["parts"][name]
        imported = actual["parts"][name]
        if expected["triangles"] != imported["triangles"]:
            problems.append(f"{name} triangle count differs")
        if not close_enough(expected["dimensions"], imported["dimensions"]):
            problems.append(f"{name} dimensions differ")
        if not close_enough(expected["location"], imported["location"]):
            problems.append(f"{name} location differs")
        if not close_enough(expected["scale"], imported["scale"]):
            problems.append(f"{name} scale differs")
        if not allow_untextured:
            if imported["material_count"] != expected["material_count"]:
                problems.append(f"{name} material count differs")
            if imported["image_count"] < 1:
                problems.append(f"{name} lost its image texture")
    if not close_enough(source["total_dimensions"], actual["total_dimensions"]):
        problems.append("assembly dimensions differ")
    if actual["extra_objects"]:
        problems.append(f"unexpected non-mesh objects: {actual['extra_objects']}")
    if problems:
        fail("GLB_ROUNDTRIP_FAILED", "; ".join(problems))
    return actual


def main() -> None:
    args = parse_args()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]*", args.asset_name):
        fail("INVALID_ASSET_NAME", "--asset-name must be short ASCII: letters, digits, underscore, hyphen")

    output_root = (
        Path(args.output_root).resolve()
        if args.output_root
        else Path.home() / "Documents" / "RobloxImportPackages" / f"{args.asset_name}_IMPORT_ONLY"
    )
    if not str(output_root).isascii() or " " in str(output_root):
        fail("IMPORT_PATH_RISKY", f"Output path must be short ASCII without spaces: {output_root}")

    meshes = select_formal_meshes(args)
    source = validate_source(meshes, args.allow_untextured)
    total_triangles = sum(record["triangles"] for record in source["parts"].values())
    base_name = f"{args.asset_name}_faces{total_triangles}_{texture_label(source)}"
    output_root.mkdir(parents=True, exist_ok=True)
    glb_path = output_root / f"{base_name}.glb"
    report_path = output_root / f"{base_name}.verification.json"
    if not args.overwrite and (glb_path.exists() or report_path.exists()):
        fail("OUTPUT_EXISTS", f"Use a new asset version or pass --overwrite: {output_root}")

    bpy.context.scene.name = base_name
    export_glb(glb_path, meshes)
    imported = verify_glb(glb_path, source, args.allow_untextured)
    report = {
        "status": "PASS",
        "glb": str(glb_path),
        "sha256": sha256(glb_path),
        "bytes": glb_path.stat().st_size,
        "part_count": len(source["parts"]),
        "total_triangles": total_triangles,
        "source": source,
        "roundtrip": imported,
    }
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print("ROBLOX_MULTI_PART_GLB_FAST_OK=" + json.dumps(report, ensure_ascii=False, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except WorkflowError as exc:
        print(f"ROBLOX_MULTI_PART_GLB_FAST_FAIL={exc.code}: {exc}")
        raise
