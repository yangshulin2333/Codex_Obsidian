import math
import os
import random
from pathlib import Path

import bpy
from mathutils import Vector


OUT_DIR = Path(os.environ.get("OUT_DIR", Path(__file__).parent))
random.seed(61502)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def make_mat(name, color, metallic=0.0, roughness=0.45, emission=None, strength=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = color
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        if emission and "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = emission
        if emission and "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = strength
    return mat


MAT = {
    "void": make_mat("void black core", (0.015, 0.006, 0.045, 1), roughness=0.25),
    "void_hi": make_mat("dark violet inner facets", (0.055, 0.025, 0.14, 1), roughness=0.35),
    "magenta": make_mat("magenta energy rim", (1.0, 0.0, 0.95, 1), roughness=0.18, emission=(1, 0, 0.9, 1), strength=1.8),
    "violet": make_mat("blue violet crystal", (0.34, 0.24, 0.92, 1), roughness=0.33),
    "violet_dark": make_mat("deep purple metal", (0.12, 0.07, 0.38, 1), roughness=0.42),
    "violet_light": make_mat("light crystal facet", (0.58, 0.48, 1.0, 1), roughness=0.30),
    "gold": make_mat("ivory gold metal", (0.92, 0.68, 0.28, 1), metallic=0.25, roughness=0.34),
    "gold_light": make_mat("warm gold facet", (1.0, 0.86, 0.46, 1), metallic=0.18, roughness=0.30),
    "gold_dark": make_mat("aged gold edge", (0.46, 0.29, 0.09, 1), metallic=0.35, roughness=0.42),
    "crack": make_mat("painted cyan cracks", (0.80, 0.92, 1.0, 1), roughness=0.2, emission=(0.55, 0.82, 1.0, 1), strength=0.35),
}


def assign(obj, mat):
    obj.data.materials.append(mat)
    return obj


def create_extruded_polygon(name, points_xz, thickness, mat, y_center=0.0):
    verts = []
    faces = []
    y_front = y_center - thickness / 2.0
    y_back = y_center + thickness / 2.0
    for x, z in points_xz:
        verts.append((x, y_front, z))
    for x, z in points_xz:
        verts.append((x, y_back, z))
    n = len(points_xz)
    faces.append(tuple(range(n)))
    faces.append(tuple(range(n, 2 * n))[::-1])
    for i in range(n):
        j = (i + 1) % n
        faces.append((i, j, j + n, i + n))
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    assign(obj, mat)
    return obj


def create_face_polygon(name, points_xz, y, mat, flip=False):
    verts = [(x, y, z) for x, z in points_xz]
    face = tuple(range(len(verts)))
    if flip:
        face = face[::-1]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], [face])
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    assign(obj, mat)
    return obj


def create_bipyramid(name, loc, radius_x, radius_y, half_height, mat, rot_z=0.0):
    cx, cy, cz = loc
    base = [
        Vector((radius_x, 0, 0)),
        Vector((0, radius_y, 0)),
        Vector((-radius_x, 0, 0)),
        Vector((0, -radius_y, 0)),
    ]
    ca, sa = math.cos(rot_z), math.sin(rot_z)
    eq = []
    for v in base:
        eq.append((cx + v.x * ca - v.y * sa, cy + v.x * sa + v.y * ca, cz))
    verts = [(cx, cy, cz + half_height), (cx, cy, cz - half_height)] + eq
    faces = [
        (0, 2, 3), (0, 3, 4), (0, 4, 5), (0, 5, 2),
        (1, 3, 2), (1, 4, 3), (1, 5, 4), (1, 2, 5),
    ]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    assign(obj, mat)
    return obj


def create_crystal_blade():
    sections = [
        (0.45, 0.78, 0.24),
        (-0.70, 0.95, 0.30),
        (-2.85, 0.70, 0.24),
        (-3.85, 0.24, 0.12),
    ]
    verts = []
    for z, width, thick in sections:
        verts += [(-width / 2, 0, z), (0, -thick / 2, z), (width / 2, 0, z), (0, thick / 2, z)]
    bottom_index = len(verts)
    verts.append((0, 0, -4.55))
    faces = []
    for s in range(len(sections) - 1):
        a = s * 4
        b = (s + 1) * 4
        faces += [(a, b, b + 1, a + 1), (a + 1, b + 1, b + 2, a + 2), (a + 2, b + 2, b + 3, a + 3), (a + 3, b + 3, b, a)]
    last = (len(sections) - 1) * 4
    faces += [(last, bottom_index, last + 1), (last + 1, bottom_index, last + 2), (last + 2, bottom_index, last + 3), (last + 3, bottom_index, last)]
    faces.append((0, 1, 2, 3))
    mesh = bpy.data.meshes.new("lowerCrystalBladeMesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new("lower faceted blue violet crystal blade", mesh)
    bpy.context.collection.objects.link(obj)
    assign(obj, MAT["violet"])
    return obj


def add_cylinder(name, radius, depth, loc, mat, vertices=8):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    assign(obj, mat)
    return obj


def add_segmented_grip():
    z = 1.82
    for i in range(8):
        h = 0.24
        radius1 = 0.245 - i * 0.010
        radius2 = 0.210 - i * 0.009
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=radius1, radius2=radius2, depth=h, location=(0, 0, z + h / 2))
        obj = bpy.context.object
        obj.name = "faceted segmented purple grip"
        assign(obj, MAT["violet"] if i % 2 == 0 else MAT["violet_dark"])
        z += h * 0.96
    add_cylinder("dark upper core rod", 0.13, 0.38, (0, 0, 3.85), MAT["violet_dark"], 8)


def add_cracks(prefix, y, z_min=-3.9, z_max=0.15, x_limit=0.33, count=22):
    for i in range(count):
        z = random.uniform(z_min, z_max)
        x = random.uniform(-x_limit, x_limit)
        length = random.uniform(0.12, 0.28)
        dx = random.choice([-1, 1]) * random.uniform(0.03, 0.12)
        curve = bpy.data.curves.new(prefix + str(i), "CURVE")
        curve.dimensions = "3D"
        curve.resolution_u = 2
        curve.bevel_depth = 0.005
        curve.bevel_resolution = 0
        spl = curve.splines.new("POLY")
        spl.points.add(2)
        pts = [(x, y, z), (x + dx, y, z + length * 0.55), (x + dx * 0.4, y, z + length)]
        for p, co in zip(spl.points, pts):
            p.co = (co[0], co[1], co[2], 1)
        obj = bpy.data.objects.new(prefix + str(i), curve)
        bpy.context.collection.objects.link(obj)
        obj.data.materials.append(MAT["crack"])


def add_wing_guard():
    left = [
        (-0.18, 1.10), (-0.68, 1.35), (-1.24, 1.08), (-1.02, 0.62),
        (-1.38, 0.42), (-0.98, 0.20), (-1.18, -0.28), (-0.62, -0.10),
        (-0.43, -1.05), (-0.16, -0.24),
    ]
    right = [(-x, z) for x, z in left]
    create_extruded_polygon("left ivory gold wing guard", left, 0.22, MAT["gold"])
    create_extruded_polygon("right ivory gold wing guard", right, 0.22, MAT["gold"])
    inset_left = [(-0.37, 0.94), (-0.75, 1.10), (-1.02, 0.92), (-0.74, 0.28), (-0.52, -0.55), (-0.31, -0.07)]
    inset_right = [(-x, z) for x, z in inset_left]
    create_face_polygon("front left warm gold facet", inset_left, -0.125, MAT["gold_light"])
    create_face_polygon("front right warm gold facet", inset_right, -0.125, MAT["gold_light"])
    create_face_polygon("back left warm gold facet", inset_left, 0.125, MAT["gold_light"], flip=True)
    create_face_polygon("back right warm gold facet", inset_right, 0.125, MAT["gold_light"], flip=True)
    spine = [(0, 0.62), (0.33, 0.10), (0.18, -1.35), (0, -2.16), (-0.18, -1.35), (-0.33, 0.10)]
    create_face_polygon("front long ivory gold spine", spine, -0.165, MAT["gold_light"])
    create_face_polygon("back long ivory gold spine", spine, 0.165, MAT["gold"], flip=True)
    for z in [0.0, -0.42, -0.83]:
        create_bipyramid("small purple gem on gold spine", (0, -0.19, z), 0.055, 0.025, 0.10, MAT["violet_light"])
        create_bipyramid("rear small purple gem on gold spine", (0, 0.19, z), 0.055, 0.025, 0.10, MAT["violet_light"])


def add_orb_and_rings():
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=0.36, location=(0, 0, 0.92))
    orb = bpy.context.object
    orb.name = "central black void orb"
    assign(orb, MAT["void"])
    for y in (-0.38, 0.38):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.39, minor_radius=0.035, major_segments=48, minor_segments=8, location=(0, y, 0.92), rotation=(math.radians(90), 0, 0))
        ring = bpy.context.object
        ring.name = "magenta orb ring"
        assign(ring, MAT["magenta"])


def add_side_shards():
    positions = [
        (-1.34, 0.72, 0.17, 0.07),
        (-1.55, 0.20, 0.14, -0.05),
        (-1.18, -0.34, 0.23, 0.04),
        (-0.92, -0.93, 0.27, -0.04),
        (-0.62, -1.53, 0.22, 0.03),
    ]
    for x, z, rx, ry in positions:
        for s in (-1, 1):
            create_bipyramid("paired blue violet side crystal shard", (s * abs(x), -0.05 * s, z), rx, max(0.055, ry), rx * 1.25, MAT["violet_light"], rot_z=0.35 * s)


def build_weapon():
    create_crystal_blade()
    add_cracks("front crystal crack ", -0.18)
    add_cracks("back crystal crack ", 0.18)
    add_wing_guard()
    add_orb_and_rings()
    add_side_shards()
    add_cylinder("dark lower shaft", 0.105, 0.82, (0, 0, 1.43), MAT["violet_dark"], 8)
    add_segmented_grip()
    create_bipyramid("outer magenta top diamond rim", (0, 0, 4.22), 0.36, 0.15, 0.54, MAT["magenta"])
    create_bipyramid("inner black purple top diamond tip", (0, -0.020, 4.22), 0.29, 0.12, 0.43, MAT["void_hi"])
    front_top_face = [(-0.25, 3.92), (0, 4.65), (0.25, 3.92), (0, 3.55)]
    back_top_face = list(reversed(front_top_face))
    create_face_polygon("front black top diamond face", front_top_face, -0.18, MAT["void_hi"])
    create_face_polygon("back black top diamond face", back_top_face, 0.18, MAT["void_hi"], flip=True)
    # subtle collars near orb and lower blade, matching the reference's segmented dark parts
    add_cylinder("bronze black collar below orb", 0.20, 0.16, (0, 0, 0.33), MAT["gold_dark"], 8)
    add_cylinder("purple collar above orb", 0.16, 0.18, (0, 0, 1.46), MAT["violet_dark"], 8)


def look_at(obj, target):
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def setup_scene():
    try:
        bpy.context.scene.render.engine = "BLENDER_EEVEE_NEXT"
    except Exception:
        bpy.context.scene.render.engine = "BLENDER_EEVEE"
    bpy.context.scene.render.resolution_x = 900
    bpy.context.scene.render.resolution_y = 1600
    bpy.context.scene.render.film_transparent = True
    bpy.context.scene.world = bpy.data.worlds.new("light gray world")
    bpy.context.scene.world.color = (0.86, 0.89, 0.93)
    bpy.context.scene.view_settings.view_transform = "Standard"
    bpy.context.scene.view_settings.look = "Medium High Contrast"
    bpy.context.scene.view_settings.exposure = 0
    bpy.context.scene.view_settings.gamma = 1
    bpy.context.scene.render.use_freestyle = False
    if hasattr(bpy.context.scene, "eevee"):
        for attr in ("use_gtao", "use_bloom"):
            if hasattr(bpy.context.scene.eevee, attr):
                setattr(bpy.context.scene.eevee, attr, True)
    bpy.ops.object.light_add(type="AREA", location=(-3.6, -5.0, 6.0))
    key = bpy.context.object
    key.name = "large softbox key light"
    key.data.energy = 820
    key.data.size = 5.0
    bpy.ops.object.light_add(type="POINT", location=(3.0, 3.5, 3.4))
    fill = bpy.context.object
    fill.name = "small rim fill light"
    fill.data.energy = 140


def render_view(name, location):
    bpy.ops.object.camera_add(location=location)
    cam = bpy.context.object
    cam.name = name + " orthographic camera"
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 10.25
    look_at(cam, (0, 0, 0))
    bpy.context.scene.camera = cam
    bpy.context.scene.render.filepath = str(OUT_DIR / f"amethyst_eclipse_crystal_blade_variant_{name}_view.png")
    bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(cam, do_unlink=True)


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    clear_scene()
    setup_scene()
    build_weapon()
    render_view("front", (0, -10.5, 0.0))
    render_view("side", (10.5, 0, 0.0))
    render_view("back", (0, 10.5, 0.0))


if __name__ == "__main__":
    main()
