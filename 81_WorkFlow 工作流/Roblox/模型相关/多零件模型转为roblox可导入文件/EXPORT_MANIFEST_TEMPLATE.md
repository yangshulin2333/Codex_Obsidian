---
type: template
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-14
updated: 2026-08-17
---

# 多零件 Roblox Import Package Manifest 模板

```yaml
asset_name:
version:
created_at:

source:
  blend_path:
  blend_sha256:
  blender_version:

assembly:
  root_part:
  public_pivot_definition:
  target_use: display | tool | npc
  target_dimensions_studs: [x, y, z]
  unit_strategy: BLENDER_UNIT_AS_STUD | METRE_TO_STUD_ONCE
  metres_per_stud: 0.28 | NOT_USED
  axis_forward: -Z
  axis_up: Y

parts:
  - name:
    role:
    vertices:
    triangles:
    location: [0, 0, 0]
    rotation: [0, 0, 0]
    scale: [1, 1, 1]
    dimensions_studs: [x, y, z]
    material:
    uv_sets: 1
    basecolor_path:
    basecolor_size:
    basecolor_format:
    basecolor_sha256:

package:
  root:
  path_is_short_ascii: true
  primary_format: GLB
  import_order:
    - GLB_PRIMARY
    - FBX_EXTERNAL
    - FBX_MESH_ONLY
    - FBX_EMBEDDED

outputs:
  glb_primary:
    path:
    bytes:
    sha256:
    internal_mesh_names: []
    material_count:
    image_count:
  fbx_external:
    status: NOT_GENERATED | GENERATED
    path:
    bytes:
    sha256:
    path_mode: RELATIVE
    embed_textures: false
    sidecar_textures: []
  fbx_mesh_only:
    status: NOT_GENERATED | GENERATED
    path:
    bytes:
    sha256:
    material_count: 0
    image_count: 0
  fbx_embedded:
    status: NOT_GENERATED | GENERATED
    path:
    bytes:
    sha256:
    path_mode: COPY
    embed_textures: true

export_common:
  selected_objects_only: true
  mesh_only: true
  apply_modifiers: true
  triangulate: true
  global_scale: 1
  apply_scalings: FBX_UNIT_SCALE
  add_leaf_bones: false
  bake_animation: false

roundtrip:
  status: NOT_RUN | PASS | FAIL
  verifier:
  files_checked:
    glb_primary: NOT_RUN | PASS | FAIL
    fbx_external: NOT_GENERATED | NOT_RUN | PASS | FAIL
    fbx_mesh_only: NOT_GENERATED | NOT_RUN | PASS | FAIL
    fbx_embedded: NOT_GENERATED | NOT_RUN | PASS | FAIL
  object_count_expected:
  object_count_actual:
  dimensions_expected: [x, y, z]
  dimensions_actual: [x, y, z]
  materials_ok:
  textures_ok:
  extra_objects:
  evidence:

studio:
  import_status: NOT_RUN | PASS | FAIL
  runtime_status: NOT_RECORDED | PASS | FAIL
  place:
  creator:
  imported_file:
  imported_format:
  target_model_path:
  meshpart_count:
  root_part:
  weld_status:
  texture_status:
  play_scatter_test:
  evidence:
  user_confirmation:
```

## 发布门

只有以下两项都满足才能称为“Roblox 已验收版”：

```text
roundtrip.status = PASS
studio.import_status = PASS
studio.runtime_status = PASS
```

仅 `roundtrip=PASS` 时，应称为“本地回导验证包”；`studio.import_status=PASS` 但运行装配未测时，只能称为“Studio 导入已通过”。
