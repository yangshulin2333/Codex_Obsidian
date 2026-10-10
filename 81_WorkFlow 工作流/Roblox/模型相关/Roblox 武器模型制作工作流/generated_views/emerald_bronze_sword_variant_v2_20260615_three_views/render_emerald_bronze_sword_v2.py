import math
import os
from pathlib import Path

import bpy
from mathutils import Vector


OUT_DIR = Path(__file__).parent
CANDIDATE_DIR = OUT_DIR / "_candidate_render"
CANDIDATE_DIR.mkdir(parents=True, exist_ok=True)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def make_mat(name, color, metallic=0.0, roughness=0.45, emission=None, strength=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = next((node for node in mat.node_tree.nodes if node.type == "BSDF_PRINCIPLED"), None)
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


def assign(obj, mat):
    obj.data.materials.append(mat)
    return obj


def extruded_poly(name, points_xz, thickness, mat, y_center=0.0):
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


def face_poly(name, points_xz, y, mat, flip=False):
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


def add_cylinder(name, radius, depth, loc, mat, vertices=10, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    assign(obj, mat)
    return obj


def add_cone(name, radius1, radius2, depth, loc, mat, vertices=8, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=loc, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    assign(obj, mat)
    return obj


def add_bipyramid(name, loc, rx, ry, hz, mat):
    cx, cy, cz = loc
    verts = [
        (cx, cy, cz + hz),
        (cx, cy, cz - hz),
        (cx + rx, cy, cz),
        (cx, cy + ry, cz),
        (cx - rx, cy, cz),
        (cx, cy - ry, cz),
    ]
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


def add_bar(name, loc, scale, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    assign(obj, mat)
    bevel = obj.modifiers.new("small low poly bevel", "BEVEL")
    bevel.width = 0.025
    bevel.segments = 1
    return obj


MAT = {
    "bronze": make_mat("clean antique bronze", (0.55, 0.30, 0.13, 1), metallic=0.25, roughness=0.40),
    "bronze_hi": make_mat("warm gold bronze facet", (0.92, 0.57, 0.25, 1), metallic=0.22, roughness=0.32),
    "dark": make_mat("dark green gunmetal", (0.06, 0.11, 0.10, 1), metallic=0.28, roughness=0.48),
    "jade": make_mat("aqua jade glass core", (0.00, 0.62, 0.50, 1), roughness=0.16, emission=(0.00, 0.75, 0.58, 1), strength=0.50),
    "jade_hi": make_mat("bright aqua jade glow", (0.13, 1.0, 0.82, 1), roughness=0.14, emission=(0.08, 1.0, 0.78, 1), strength=1.8),
    "shadow_jade": make_mat("deep aqua rear glass", (0.0, 0.20, 0.18, 1), roughness=0.28, emission=(0.0, 0.32, 0.26, 1), strength=0.25),
    "edge": make_mat("dark ink edge", (0.025, 0.027, 0.025, 1), roughness=0.55),
}


def build_weapon():
    # Long faceted aqua jade blade core.
    blade = [
        (-0.40, 0.26), (-0.28, -0.48), (-0.31, -2.82), (-0.14, -4.18),
        (0, -4.62), (0.14, -4.18), (0.31, -2.82), (0.28, -0.48), (0.40, 0.26),
    ]
    extruded_poly("single shared jade crystal blade", blade, 0.20, MAT["jade"])
    inner = [
        (-0.14, 0.04), (-0.08, -0.70), (-0.09, -3.15), (0, -4.02),
        (0.09, -3.15), (0.08, -0.70), (0.14, 0.04),
    ]
    face_poly("front bright blade core", inner, -0.116, MAT["jade_hi"])
    face_poly("back muted blade core", inner, 0.116, MAT["shadow_jade"], flip=True)

    # Bronze rails on both sides of blade.
    left_rail = [(-0.55, 0.18), (-0.44, -0.85), (-0.45, -4.0), (-0.12, -4.55), (-0.25, -3.7), (-0.25, -0.58)]
    right_rail = [(-x, z) for x, z in left_rail]
    extruded_poly("left bronze blade rail", left_rail, 0.24, MAT["bronze"])
    extruded_poly("right bronze blade rail", right_rail, 0.24, MAT["bronze"])

    # Rear cover plates so back view differs but silhouette stays identical.
    rear_cover = [(-0.26, -0.15), (-0.18, -0.85), (-0.16, -3.72), (0, -4.3), (0.16, -3.72), (0.18, -0.85), (0.26, -0.15)]
    face_poly("rear dark armor cover", rear_cover, 0.145, MAT["dark"], flip=True)
    for z in [-0.55, -1.5, -2.55, -3.45]:
        add_bar("rear small jade seam marker", (0, 0.165, z), (0.12, 0.025, 0.025), MAT["jade_hi"])

    # Guard body and front/back central gems.
    guard = [
        (-0.82, 0.55), (-0.46, 0.98), (-0.18, 0.58), (0, 0.77),
        (0.18, 0.58), (0.46, 0.98), (0.82, 0.55), (0.50, 0.10),
        (0.20, 0.07), (0, -0.28), (-0.20, 0.07), (-0.50, 0.10),
    ]
    extruded_poly("shared bronze lotus guard", guard, 0.42, MAT["bronze"])
    face_poly("front warm guard facets left", [(-0.55, 0.52), (-0.30, 0.78), (-0.12, 0.30), (-0.34, 0.12)], -0.235, MAT["bronze_hi"])
    face_poly("front warm guard facets right", [(0.55, 0.52), (0.30, 0.78), (0.12, 0.30), (0.34, 0.12)], -0.235, MAT["bronze_hi"])
    face_poly("back guard dark cover", [(-0.52, 0.55), (-0.28, 0.82), (0, 0.58), (0.28, 0.82), (0.52, 0.55), (0.24, 0.2), (0, 0.32), (-0.24, 0.2)], 0.235, MAT["dark"], flip=True)
    add_bipyramid("front central jade diamond", (0, -0.27, 0.28), 0.16, 0.05, 0.32, MAT["jade_hi"])
    add_bipyramid("back smaller jade diamond", (0, 0.27, 0.28), 0.12, 0.04, 0.24, MAT["jade"])

    # Teal crescent side crystal wings.
    wing_l = [
        (-0.72, 0.42), (-1.28, 0.68), (-1.16, 0.36), (-1.52, 0.10),
        (-1.04, 0.00), (-0.70, 0.22),
    ]
    wing_r = [(-x, z) for x, z in wing_l]
    extruded_poly("left jade crescent wing", wing_l, 0.18, MAT["jade_hi"])
    extruded_poly("right jade crescent wing", wing_r, 0.18, MAT["jade_hi"])
    face_poly("front left dark wing inset", [(-0.78, 0.38), (-1.12, 0.50), (-1.00, 0.27), (-1.28, 0.08), (-0.98, 0.09), (-0.72, 0.22)], -0.105, MAT["jade"])
    face_poly("front right dark wing inset", [(0.78, 0.38), (1.12, 0.50), (1.00, 0.27), (1.28, 0.08), (0.98, 0.09), (0.72, 0.22)], -0.105, MAT["jade"])
    face_poly("back left muted wing inset", [(-0.78, 0.38), (-1.12, 0.50), (-1.00, 0.27), (-1.28, 0.08), (-0.98, 0.09), (-0.72, 0.22)], 0.105, MAT["jade"], flip=True)
    face_poly("back right muted wing inset", [(0.78, 0.38), (1.12, 0.50), (1.00, 0.27), (1.28, 0.08), (0.98, 0.09), (0.72, 0.22)], 0.105, MAT["jade"], flip=True)

    # Arched loop above guard.
    left_arc = [(-0.08, 1.28), (-0.44, 1.04), (-0.78, 0.59), (-0.58, 0.44), (-0.30, 0.86), (0, 1.05)]
    right_arc = [(-x, z) for x, z in left_arc]
    extruded_poly("left bronze loop guard arm", left_arc, 0.24, MAT["bronze"])
    extruded_poly("right bronze loop guard arm", right_arc, 0.24, MAT["bronze"])

    # Handle, collar, and arrow pommel.
    add_cylinder("round bronze collar", 0.22, 0.35, (0, 0, 1.22), MAT["bronze_hi"], vertices=12)
    add_cylinder("wrapped short handle", 0.15, 1.35, (0, 0, 1.92), MAT["dark"], vertices=10)
    # Blender cylinder depth is along Z, so add diagonal wrap strips as small bars.
    for i, z in enumerate([1.35, 1.62, 1.89, 2.16, 2.43]):
        bar = add_bar("painted bronze handle wrap", (0, -0.155, z), (0.26, 0.025, 0.035), MAT["bronze_hi"])
        bar.rotation_euler[2] = math.radians(22 if i % 2 == 0 else -22)
    add_cylinder("upper bronze ring", 0.18, 0.18, (0, 0, 2.68), MAT["bronze"], vertices=10)
    arrow = [(-0.18, 2.78), (0, 3.16), (0.18, 2.78), (0.08, 2.64), (0, 2.72), (-0.08, 2.64)]
    extruded_poly("faceted arrow pommel", arrow, 0.28, MAT["bronze"])
    add_bipyramid("top small jade jewel", (0, -0.17, 2.86), 0.07, 0.025, 0.12, MAT["jade_hi"])
    add_bipyramid("rear top small jade jewel", (0, 0.17, 2.86), 0.06, 0.022, 0.10, MAT["jade"])

    # Painted motif bars on front blade.
    for z in [-0.88, -1.62, -2.42, -3.20]:
        add_bipyramid("front painted low poly blade motif", (0, -0.13, z), 0.06, 0.018, 0.11, MAT["dark"])


def setup_scene():
    clear_scene()
    bpy.context.scene.render.engine = "BLENDER_EEVEE"
    bpy.context.scene.eevee.taa_render_samples = 64
    bpy.context.scene.world = bpy.data.worlds.new("soft studio world") if bpy.context.scene.world is None else bpy.context.scene.world
    bpy.context.scene.world.color = (0.86, 0.90, 0.92)
    build_weapon()

    bpy.ops.object.light_add(type="AREA", location=(0, -4.0, 5.5))
    key = bpy.context.object
    key.name = "large soft front light"
    key.data.energy = 450
    key.data.size = 5.0
    bpy.ops.object.light_add(type="POINT", location=(-3, 3, 4))
    fill = bpy.context.object
    fill.name = "small rim fill"
    fill.data.energy = 65

    bpy.ops.object.camera_add(location=(0, -8.5, -0.55), rotation=(math.radians(90), 0, 0))
    cam = bpy.context.object
    bpy.context.scene.camera = cam
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 9.0
    bpy.context.scene.render.resolution_x = 900
    bpy.context.scene.render.resolution_y = 1600
    bpy.context.scene.render.film_transparent = True
    bpy.context.scene.view_settings.view_transform = "Standard"
    bpy.context.scene.view_settings.look = "Medium High Contrast"
    bpy.context.scene.view_settings.exposure = 0
    bpy.context.scene.view_settings.gamma = 1


def look_at(obj, target):
    loc = Vector(obj.location)
    direction = Vector(target) - loc
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def render_view(name, camera_location):
    cam = bpy.context.scene.camera
    cam.location = camera_location
    look_at(cam, (0, 0, -0.55))
    bpy.context.scene.render.filepath = str(CANDIDATE_DIR / f"emerald_bronze_sword_variant_v2_{name}_candidate.png")
    bpy.ops.render.render(write_still=True)


def main():
    setup_scene()
    render_view("front", (0, -8.5, -0.55))
    render_view("side", (8.5, 0, -0.55))
    render_view("back", (0, 8.5, -0.55))
    print("EMERALD_BRONZE_SWORD_V2_RENDER_OK")
    print(CANDIDATE_DIR)


if __name__ == "__main__":
    main()
