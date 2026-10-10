param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [string]$OutputRoot = "",

    [string]$Name = "",

    [string]$ImportNamePrefix = "",

    [int]$TextureSize = 1024,

    [ValidateSet("jpg", "png")]
    [string]$TextureFormat = "jpg",

    [string]$BlenderExe = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $workflowRoot = Split-Path -Parent $PSScriptRoot
    $documentsRoot = [Environment]::GetFolderPath("MyDocuments")
    if ([string]::IsNullOrWhiteSpace($documentsRoot)) {
        $OutputRoot = Join-Path $workflowRoot "outputs"
    }
    else {
        $OutputRoot = Join-Path $documentsRoot "RobloxImportPackages"
    }
}

function Get-SafeName {
    param([string]$Value)
    $safe = $Value -replace '[^A-Za-z0-9_\-]+', '_'
    $safe = $safe.Trim('_')
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return "weapon_asset"
    }
    return $safe
}

function Test-IsZipFile {
    param([string]$Path)
    if ((Get-Item -LiteralPath $Path).PSIsContainer) {
        return $false
    }
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        if ($stream.Length -lt 2) { return $false }
        $b1 = $stream.ReadByte()
        $b2 = $stream.ReadByte()
        return ($b1 -eq 0x50 -and $b2 -eq 0x4B)
    }
    finally {
        $stream.Dispose()
    }
}

function Get-PrimaryFbx {
    param([string]$RootPath)

    if (-not (Test-Path -LiteralPath $RootPath)) {
        return $null
    }

    $item = Get-Item -LiteralPath $RootPath
    if (-not $item.PSIsContainer) {
        if ($item.Extension -ieq ".fbx") {
            return $item
        }
        return $null
    }

    $allowExtractedRoot = $item.Name -eq "_extracted"
    Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Filter *.fbx |
        Where-Object {
            ($allowExtractedRoot -or $_.FullName -notmatch '\\_extracted(\\|$)') -and
            ($allowExtractedRoot -or $_.FullName -notmatch '\\[^\\]+_roblox_direct(\\|$)') -and
            $_.FullName -notmatch '\\Roblox_Ready(\\|$)' -and
            $_.FullName -notmatch '\\Roblox_Import[^\\]*(\\|$)' -and
            $_.FullName -notmatch '\.fbm(\\|$)'
        } |
        Sort-Object Length -Descending |
        Select-Object -First 1
}

function Get-PrimaryTexture {
    param(
        [string]$RootPath,
        [System.IO.FileInfo]$PreferredFbx
    )

    if (-not (Test-Path -LiteralPath $RootPath)) {
        return $null
    }

    $item = Get-Item -LiteralPath $RootPath
    $searchRoot = if ($item.PSIsContainer) { $item.FullName } else { Split-Path -Parent $item.FullName }
    $fbxFolder = if ($PreferredFbx) { Split-Path -Parent $PreferredFbx.FullName } else { "" }
    $allowExtractedRoot = $item.PSIsContainer -and $item.Name -eq "_extracted"
    $preferredFbmPrefix = ""
    if ($PreferredFbx) {
        $preferredFbmFolder = Join-Path (Split-Path -Parent $PreferredFbx.FullName) "$($PreferredFbx.BaseName).fbm"
        $preferredFbmPrefix = $preferredFbmFolder.TrimEnd('\') + '\'
    }

    $images = Get-ChildItem -LiteralPath $searchRoot -Recurse -File |
        Where-Object {
            $inPreferredFbmFolder = $preferredFbmPrefix -and $_.FullName.StartsWith($preferredFbmPrefix, [System.StringComparison]::OrdinalIgnoreCase)
            $_.Extension -in ".png", ".jpg", ".jpeg" -and
            ($allowExtractedRoot -or $_.FullName -notmatch '\\_extracted(\\|$)') -and
            ($allowExtractedRoot -or $_.FullName -notmatch '\\[^\\]+_roblox_direct(\\|$)') -and
            $_.FullName -notmatch '\\Roblox_Ready(\\|$)' -and
            $_.FullName -notmatch '\\Roblox_Import[^\\]*(\\|$)' -and
            ($inPreferredFbmFolder -or $_.FullName -notmatch '\.fbm(\\|$)')
        }

    if (-not $images) {
        return $null
    }

    $ranked = foreach ($image in $images) {
        $name = $image.BaseName.ToLowerInvariant()
        $score = 0
        if ($image.DirectoryName -eq $fbxFolder) { $score += 1000 }
        if ($name -match 'base.?color|albedo|diffuse|color|texture') { $score += 300 }
        if ($name -match 'normal|rough|metal|metallic|emit|emissive|ao|height|opacity') { $score -= 500 }

        [PSCustomObject]@{
            Item = $image
            Score = $score
            Length = $image.Length
        }
    }

    $ranked |
        Sort-Object @{ Expression = "Score"; Descending = $true }, @{ Expression = "Length"; Descending = $true } |
        Select-Object -First 1 |
        ForEach-Object { $_.Item }
}

function Resize-Texture {
    param(
        [string]$SourcePath,
        [string]$OutputPath,
        [int]$Size,
        [string]$Format
    )

    Add-Type -AssemblyName System.Drawing

    $img = [System.Drawing.Image]::FromFile($SourcePath)
    try {
        $bmp = New-Object System.Drawing.Bitmap $Size, $Size
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.Clear([System.Drawing.Color]::Black)
            $g.DrawImage($img, 0, 0, $Size, $Size)

            if ($Format -eq "jpg") {
                $jpgCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
                    Where-Object { $_.MimeType -eq "image/jpeg" }
                $encParams = New-Object System.Drawing.Imaging.EncoderParameters 1
                $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter (
                    [System.Drawing.Imaging.Encoder]::Quality,
                    90L
                )
                $bmp.Save($OutputPath, $jpgCodec, $encParams)
            }
            else {
                $bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            }
        }
        finally {
            $g.Dispose()
            $bmp.Dispose()
        }
    }
    finally {
        $img.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "InputPath does not exist: $InputPath"
}

if (-not (Test-Path -LiteralPath $BlenderExe)) {
    throw "BlenderExe does not exist: $BlenderExe"
}

$inputItem = Get-Item -LiteralPath $InputPath
$inputIsDirectory = [bool]$inputItem.PSIsContainer
if ([string]::IsNullOrWhiteSpace($Name)) {
    if ($inputIsDirectory) {
        $Name = $inputItem.Name
    }
    else {
        $Name = [System.IO.Path]::GetFileNameWithoutExtension($inputItem.Name)
    }
}
$safeName = Get-SafeName $Name
$safeImportNamePrefix = if ([string]::IsNullOrWhiteSpace($ImportNamePrefix)) {
    $safeName
}
else {
    Get-SafeName $ImportNamePrefix
}
$outDir = Join-Path $OutputRoot "${safeName}_roblox_direct"
$extractDir = Join-Path $outDir "_extracted"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$staleOutputPatterns = @(
    "${safeName}_direct_*tex.fbx",
    "${safeName}_direct_*tex.glb",
    "${safeName}_embedded_*tex.fbx",
    "${safeName}_mesh_only.fbx",
    "${safeName}_texture_*.*",
    "${safeName}_faces*_direct_*tex.fbx",
    "${safeName}_faces*_direct_*tex.glb",
    "${safeName}_faces*_embedded_*tex.fbx",
    "${safeName}_faces*_mesh_only.fbx",
    "${safeName}_faces*_texture_*.*",
    "_tmp_${safeName}_texture_*.*"
)
foreach ($pattern in $staleOutputPatterns) {
    Get-ChildItem -LiteralPath $outDir -File -Filter $pattern -ErrorAction SilentlyContinue |
        Remove-Item -Force
}
$staleOutputDirectoryPatterns = @(
    "${safeName}_direct_*tex.fbm",
    "${safeName}_embedded_*tex.fbm",
    "${safeName}_faces*_direct_*tex.fbm",
    "${safeName}_faces*_embedded_*tex.fbm"
)
foreach ($pattern in $staleOutputDirectoryPatterns) {
    Get-ChildItem -LiteralPath $outDir -Directory -Filter $pattern -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force
}

$sourceFbx = $null
$sourceTexture = $null
$isZip = $false

if ($inputIsDirectory) {
    $sourceFbx = Get-PrimaryFbx -RootPath $inputItem.FullName
    if ($sourceFbx) {
        $sourceTexture = Get-PrimaryTexture -RootPath $inputItem.FullName -PreferredFbx $sourceFbx
    }
}
else {
    $isZip = Test-IsZipFile $inputItem.FullName
}

if (-not $inputIsDirectory -and $isZip) {
    if (Test-Path -LiteralPath $extractDir) {
        Remove-Item -LiteralPath $extractDir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $extractDir | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($inputItem.FullName, $extractDir)
    $sourceFbx = Get-PrimaryFbx -RootPath $extractDir
    if ($sourceFbx) {
        $sourceTexture = Get-PrimaryTexture -RootPath $extractDir -PreferredFbx $sourceFbx
    }
}
elseif (-not $inputIsDirectory) {
    $sourceFbx = Get-PrimaryFbx -RootPath $inputItem.FullName
    if ($sourceFbx) {
        $sourceFolder = Split-Path -Parent $sourceFbx.FullName
        $sourceTexture = Get-PrimaryTexture -RootPath $sourceFolder -PreferredFbx $sourceFbx
    }
}

if (-not $sourceFbx) {
    throw "No FBX found. InputPath can be a directory, a real FBX file, or a Meshy ZIP-like FBX package: $InputPath"
}

$textureTempOut = $null
if ($sourceTexture) {
    $textureTempOut = Join-Path $outDir "_tmp_${safeName}_texture_${TextureSize}.${TextureFormat}"
    Resize-Texture -SourcePath $sourceTexture.FullName -OutputPath $textureTempOut -Size $TextureSize -Format $TextureFormat
}

$pyPath = Join-Path $outDir "_prepare_in_blender.py"
$metadataPath = Join-Path $outDir "_export_metadata.json"

$hasTexture = [bool]$textureTempOut
$pyHasTexture = if ($hasTexture) { "True" } else { "False" }
$py = @"
import bpy
import os
import shutil
import json
import struct

src_fbx = r'''$($sourceFbx.FullName)'''
out_dir = r'''$outDir'''
texture_temp_path = r'''$textureTempOut'''
metadata_path = r'''$metadataPath'''
safe_name = r'''$safeName'''
import_name_prefix = r'''$safeImportNamePrefix'''
texture_size = $TextureSize
texture_format = r'''$TextureFormat'''
has_texture = $pyHasTexture
source_texture_mode = 'external_file' if has_texture else 'none'

os.makedirs(out_dir, exist_ok=True)

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.import_scene.fbx(filepath=src_fbx)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']

if not meshes:
    raise RuntimeError('No mesh object imported from FBX')

source_polygon_count = sum(len(o.data.polygons) for o in meshes)
def _triangulated_face_count(objects):
    total = 0
    for mesh_obj in objects:
        mesh_obj.data.calc_loop_triangles()
        total += len(mesh_obj.data.loop_triangles)
    return total

face_count = _triangulated_face_count(meshes)
face_label = 'faces' + str(face_count)
import_name = import_name_prefix + '_' + face_label + '_' + str(texture_size) + 'tex'
export_stem = safe_name + '_' + face_label
direct_fbx = os.path.join(out_dir, export_stem + '_direct_' + str(texture_size) + 'tex.fbx')
direct_glb = os.path.join(out_dir, export_stem + '_direct_' + str(texture_size) + 'tex.glb')
embedded_fbx = os.path.join(out_dir, export_stem + '_embedded_' + str(texture_size) + 'tex.fbx')
mesh_only_fbx = os.path.join(out_dir, export_stem + '_mesh_only.fbx')
# The imported objects have their rotation and scale applied below. Export FBX
# at the same world scale as GLB; a hard-coded 0.01 only works for sources that
# still carry a 100x node scale and shrinks already-normalized assets.
fbx_global_scale = 1.0
fbx_scale_mode = 'match_glb_world_scale'
texture_path = ''
if has_texture and os.path.exists(texture_temp_path):
    texture_path = os.path.join(out_dir, export_stem + '_texture_' + str(texture_size) + '.' + texture_format)
    shutil.copyfile(texture_temp_path, texture_path)

def _image_score(img):
    name = (img.name or os.path.basename(getattr(img, 'filepath', '') or '')).lower()
    if not getattr(img, 'has_data', False):
        return -100000
    if len(img.size) < 2 or img.size[0] <= 0 or img.size[1] <= 0:
        return -100000
    if getattr(img, 'source', '') == 'VIEWER':
        return -100000
    score = 0
    if getattr(img, 'packed_file', None):
        score += 100
    if any(token in name for token in ['basecolor', 'base_color', 'albedo', 'diffuse', 'color', 'texture_pbr', 'texture']):
        score += 300
    if any(token in name for token in ['normal', 'rough', 'metal', 'metallic', 'emit', 'emissive', 'ao', 'height', 'opacity']):
        score -= 500
    score += min(max(img.size[0], img.size[1]), 8192) / 8192.0
    return score

def _find_embedded_base_color_image():
    linked_images = []
    node_images = []
    for mat in bpy.data.materials:
        if not mat.use_nodes or not mat.node_tree:
            continue
        for node in mat.node_tree.nodes:
            if node.bl_idname != 'ShaderNodeTexImage' or not node.image:
                continue
            node_images.append(node.image)
            color_output = node.outputs.get('Color')
            if not color_output:
                continue
            for link in color_output.links:
                if link.to_socket and link.to_socket.name in {'Base Color', 'BaseColor'}:
                    linked_images.append(node.image)
    candidates = linked_images or node_images or list(bpy.data.images)
    candidates = [img for img in candidates if _image_score(img) > -100000]
    if not candidates:
        return None
    return sorted(candidates, key=_image_score, reverse=True)[0]

def _save_image_as_sidecar(img, output_path):
    try:
        img.scale(texture_size, texture_size)
        img.filepath_raw = output_path
        img.file_format = 'JPEG' if texture_format.lower() in {'jpg', 'jpeg'} else 'PNG'
        img.save()
        return os.path.exists(output_path)
    except Exception as exc:
        print('embedded_texture_extract_failed=' + repr(exc))
        return False

if not has_texture:
    embedded_img = _find_embedded_base_color_image()
    if embedded_img:
        texture_path = os.path.join(out_dir, export_stem + '_texture_' + str(texture_size) + '.' + texture_format)
        if _save_image_as_sidecar(embedded_img, texture_path):
            has_texture = True
            source_texture_mode = 'embedded_packed_image'
            print('embedded_texture_extracted=' + embedded_img.name)

def _read_glb_json_and_bin(path):
    with open(path, 'rb') as f:
        data = f.read()
    magic, version, total_len = struct.unpack_from('<4sII', data, 0)
    if magic != b'glTF' or version != 2:
        raise RuntimeError('Not a GLB v2 file: ' + path)
    offset = 12
    json_chunk = None
    bin_chunk = None
    while offset < len(data):
        chunk_len, chunk_type = struct.unpack_from('<II', data, offset)
        offset += 8
        chunk = data[offset:offset + chunk_len]
        offset += chunk_len
        if chunk_type == 0x4E4F534A:
            json_chunk = chunk
        elif chunk_type == 0x004E4942:
            bin_chunk = chunk
    if json_chunk is None:
        raise RuntimeError('GLB JSON chunk missing: ' + path)
    gltf = json.loads(json_chunk.rstrip(b' \t\r\n\0').decode('utf-8'))
    return gltf, bin_chunk

def _write_glb_json_and_bin(path, gltf, bin_chunk):
    json_bytes = json.dumps(gltf, ensure_ascii=False, separators=(',', ':')).encode('utf-8')
    json_bytes += b' ' * ((4 - len(json_bytes) % 4) % 4)
    chunks = [(0x4E4F534A, json_bytes)]
    if bin_chunk is not None:
        chunks.append((0x004E4942, bin_chunk))
    total_len = 12 + sum(8 + len(chunk) for _, chunk in chunks)
    out = bytearray(struct.pack('<4sII', b'glTF', 2, total_len))
    for chunk_type, chunk in chunks:
        out += struct.pack('<II', len(chunk), chunk_type)
        out += chunk
    with open(path, 'wb') as f:
        f.write(out)

def _indexed_name(base, suffix, idx):
    if idx == 0:
        return base + '_' + suffix
    return base + '_' + suffix + '_' + str(idx + 1).zfill(2)

def _rewrite_glb_internal_names(path, base):
    gltf, bin_chunk = _read_glb_json_and_bin(path)
    for idx, scene in enumerate(gltf.get('scenes', [])):
        scene['name'] = base if idx == 0 else base + '_scene_' + str(idx + 1).zfill(2)
    for idx, node in enumerate(gltf.get('nodes', [])):
        node['name'] = base if idx == 0 else base + '_node_' + str(idx + 1).zfill(2)
    for idx, mesh in enumerate(gltf.get('meshes', [])):
        mesh['name'] = _indexed_name(base, 'mesh', idx)
    for idx, mat_item in enumerate(gltf.get('materials', [])):
        mat_item['name'] = _indexed_name(base, 'mat', idx)
    _write_glb_json_and_bin(path, gltf, bin_chunk)
    names = []
    names.extend(scene.get('name', '') for scene in gltf.get('scenes', []))
    names.extend(node.get('name', '') for node in gltf.get('nodes', []))
    names.extend(mesh.get('name', '') for mesh in gltf.get('meshes', []))
    names.extend(mat_item.get('name', '') for mat_item in gltf.get('materials', []))
    return all(base in name for name in names if name) and ('Scene' not in names)

bpy.context.scene.name = import_name
mat = bpy.data.materials.new(import_name + '_mat')
mat.diffuse_color = (0.9, 0.72, 0.28, 1.0)

if has_texture and os.path.exists(texture_path):
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    output = nodes.new(type='ShaderNodeOutputMaterial')
    output.location = (420, 0)
    bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf.location = (150, 0)
    tex_node = nodes.new(type='ShaderNodeTexImage')
    tex_node.location = (-220, 80)
    img = bpy.data.images.load(texture_path)
    img.name = os.path.basename(texture_path)
    img.filepath = texture_path
    tex_node.image = img
    mat.node_tree.links.new(tex_node.outputs['Color'], bsdf.inputs['Base Color'])
    mat.node_tree.links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])
    if 'Roughness' in bsdf.inputs:
        bsdf.inputs['Roughness'].default_value = 0.55
    if 'Metallic' in bsdf.inputs:
        bsdf.inputs['Metallic'].default_value = 0.15
else:
    mat.use_nodes = False

for idx, obj in enumerate(meshes):
    obj.name = import_name if idx == 0 else import_name + '_node_' + str(idx + 1).zfill(2)
    obj.data.name = _indexed_name(import_name, 'mesh', idx)
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    try:
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    except Exception:
        pass
    for poly in obj.data.polygons:
        poly.use_smooth = True
    wn = obj.modifiers.new('WeightedNormal_RobloxPreview', 'WEIGHTED_NORMAL')
    wn.keep_sharp = True

bpy.ops.object.select_all(action='DESELECT')
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]

# Mesh-only fallback: no embedded texture, useful if Roblox texture upload fails.
for obj in meshes:
    obj.data.materials.clear()
    fallback = bpy.data.materials.new(import_name + '_plain_mat')
    fallback.diffuse_color = (0.85, 0.72, 0.42, 1.0)
    obj.data.materials.append(fallback)
bpy.ops.export_scene.fbx(
    filepath=mesh_only_fbx,
    use_selection=True,
    object_types={'MESH'},
    use_mesh_modifiers=True,
    add_leaf_bones=False,
    bake_anim=False,
    global_scale=fbx_global_scale,
    apply_unit_scale=True,
    apply_scale_options='FBX_SCALE_ALL',
    path_mode='AUTO',
    embed_textures=False,
)

# Restore textured material before direct exports. The primary FBX keeps the
# texture as a sidecar file because Roblox handles this more reliably than
# Blender's embedded FBX texture blocks.
for obj in meshes:
    obj.data.materials.clear()
    obj.data.materials.append(mat)

bpy.ops.export_scene.fbx(
    filepath=direct_fbx,
    use_selection=True,
    object_types={'MESH'},
    use_mesh_modifiers=True,
    add_leaf_bones=False,
    bake_anim=False,
    global_scale=fbx_global_scale,
    apply_unit_scale=True,
    apply_scale_options='FBX_SCALE_ALL',
    path_mode='RELATIVE',
    embed_textures=False,
)

if has_texture and os.path.exists(texture_path):
    bpy.ops.export_scene.fbx(
        filepath=embedded_fbx,
        use_selection=True,
        object_types={'MESH'},
        use_mesh_modifiers=True,
        add_leaf_bones=False,
        bake_anim=False,
        global_scale=fbx_global_scale,
        apply_unit_scale=True,
        apply_scale_options='FBX_SCALE_ALL',
        path_mode='COPY',
        embed_textures=True,
    )

bpy.ops.export_scene.gltf(
    filepath=direct_glb,
    export_format='GLB',
    use_selection=True,
    export_apply=True,
    export_yup=True,
    export_materials='EXPORT',
    export_texcoords=True,
    export_normals=True,
    export_draco_mesh_compression_enable=False,
)
glb_internal_names_include_faces = _rewrite_glb_internal_names(direct_glb, import_name)

def _bounds_dimensions(objects):
    points = []
    for obj in objects:
        points.extend([obj.matrix_world @ mathutils.Vector(corner) for corner in obj.bound_box])
    if not points:
        return (0.0, 0.0, 0.0)
    mins = [min(p[i] for p in points) for i in range(3)]
    maxs = [max(p[i] for p in points) for i in range(3)]
    return tuple(maxs[i] - mins[i] for i in range(3))

def _reimport_dimensions(path, file_type):
    before = set(bpy.data.objects)
    if file_type == 'fbx':
        bpy.ops.import_scene.fbx(filepath=path)
    else:
        bpy.ops.import_scene.gltf(filepath=path)
    imported = [obj for obj in bpy.data.objects if obj not in before]
    imported_meshes = [obj for obj in imported if obj.type == 'MESH']
    dimensions = _bounds_dimensions(imported_meshes)
    for obj in imported:
        data = obj.data if obj.type == 'MESH' else None
        bpy.data.objects.remove(obj, do_unlink=True)
        if data and data.users == 0:
            bpy.data.meshes.remove(data)
    return dimensions

# Export success is not enough: FBX and GLB must preserve the same world size.
# This catches accidental 100x or 0.01x FBX scaling before delivery.
import mathutils
fbx_dimensions = _reimport_dimensions(direct_fbx, 'fbx')
glb_dimensions = _reimport_dimensions(direct_glb, 'glb')
dimension_relative_error = [
    abs(fbx_dimensions[i] - glb_dimensions[i]) / max(abs(glb_dimensions[i]), 1e-9)
    for i in range(3)
]
scale_match = max(dimension_relative_error) <= 1e-4
if not scale_match:
    raise RuntimeError(
        'FBX/GLB dimension mismatch: fbx=' + repr(fbx_dimensions) +
        ', glb=' + repr(glb_dimensions) +
        ', relative_error=' + repr(dimension_relative_error)
    )

print('ROBLOX_WEAPON_EXPORT_OK')
print('source_fbx=' + src_fbx)
print('texture=' + (texture_path if has_texture else 'none'))
print('source_texture_mode=' + source_texture_mode)
print('source_polygon_faces=' + str(source_polygon_count))
print('faces=' + str(face_count))
print('import_name=' + import_name)
print('glb_internal_names_include_faces=' + str(glb_internal_names_include_faces))
print('direct_fbx=' + direct_fbx)
print('direct_fbx_texture_mode=' + ('external_relative' if has_texture else 'none'))
print('fbx_scale_mode=' + fbx_scale_mode)
print('fbx_dimensions=' + repr(fbx_dimensions))
print('glb_dimensions=' + repr(glb_dimensions))
print('fbx_glb_scale_match=' + str(scale_match))
print('direct_glb=' + direct_glb)
print('embedded_fbx=' + (embedded_fbx if has_texture else 'none'))
print('mesh_only_fbx=' + mesh_only_fbx)
with open(metadata_path, 'w', encoding='utf-8') as f:
    json.dump({
        'faces': face_count,
        'source_polygon_faces': source_polygon_count,
        'import_name': import_name,
        'glb_internal_names_include_faces': glb_internal_names_include_faces,
        'source_fbx': src_fbx,
        'texture': texture_path if has_texture else 'none',
        'source_texture_mode': source_texture_mode,
        'direct_fbx': direct_fbx,
        'direct_fbx_texture_mode': 'external_relative' if has_texture else 'none',
        'fbx_scale_mode': fbx_scale_mode,
        'fbx_global_scale': fbx_global_scale,
        'fbx_dimensions': list(fbx_dimensions),
        'glb_dimensions': list(glb_dimensions),
        'fbx_glb_dimension_relative_error': dimension_relative_error,
        'fbx_glb_scale_match': scale_match,
        'direct_glb': direct_glb,
        'embedded_fbx': embedded_fbx if has_texture else 'none',
        'mesh_only_fbx': mesh_only_fbx
    }, f, ensure_ascii=False, indent=2)
"@

Set-Content -Path $pyPath -Value $py -Encoding UTF8
& $BlenderExe --background --python $pyPath
if ($LASTEXITCODE -ne 0) {
    throw "Blender export failed. See console output above."
}
if (-not (Test-Path -LiteralPath $metadataPath)) {
    throw "Export metadata was not generated: $metadataPath"
}
$metadata = Get-Content -LiteralPath $metadataPath -Raw -Encoding UTF8 | ConvertFrom-Json
$faces = [int]$metadata.faces
$importName = if ([string]$metadata.import_name) { [string]$metadata.import_name } else { "${safeImportNamePrefix}_faces${faces}_${TextureSize}tex" }
$glbInternalNamesIncludeFaces = [bool]$metadata.glb_internal_names_include_faces
$directFbx = [string]$metadata.direct_fbx
$embeddedFbx = if ([string]$metadata.embedded_fbx -and [string]$metadata.embedded_fbx -ne "none") { [string]$metadata.embedded_fbx } else { $null }
$directGlb = [string]$metadata.direct_glb
$meshOnlyFbx = [string]$metadata.mesh_only_fbx
$textureOut = if ([string]$metadata.texture -and [string]$metadata.texture -ne "none") { [string]$metadata.texture } else { $null }
$sourceTextureMode = if ([string]$metadata.source_texture_mode) { [string]$metadata.source_texture_mode } else { "none" }
$fbxScaleMode = if ([string]$metadata.fbx_scale_mode) { [string]$metadata.fbx_scale_mode } else { "unknown" }
$fbxGlbScaleMatch = [bool]$metadata.fbx_glb_scale_match
$fbxDimensions = ($metadata.fbx_dimensions | ForEach-Object { [string]$_ }) -join ", "
$glbDimensions = ($metadata.glb_dimensions | ForEach-Object { [string]$_ }) -join ", "
if (-not $fbxGlbScaleMatch) {
    throw "FBX and GLB dimensions do not match."
}
if (-not $glbInternalNamesIncludeFaces) {
    throw "GLB internal names do not include the final face-count import name."
}
if (-not (Test-Path -LiteralPath $directFbx)) {
    throw "Direct FBX was not generated: $directFbx"
}
if (-not (Test-Path -LiteralPath $directGlb)) {
    throw "Direct GLB was not generated: $directGlb"
}
if ($embeddedFbx -and -not (Test-Path -LiteralPath $embeddedFbx)) {
    throw "Embedded FBX was not generated: $embeddedFbx"
}
if (-not (Test-Path -LiteralPath $meshOnlyFbx)) {
    throw "Mesh-only FBX was not generated: $meshOnlyFbx"
}
if ($textureOut -and -not (Test-Path -LiteralPath $textureOut)) {
    throw "Texture was not generated: $textureOut"
}
if ($textureTempOut -and (Test-Path -LiteralPath $textureTempOut)) {
    Remove-Item -LiteralPath $textureTempOut -Force
}

$inputType = if ($inputIsDirectory) { "directory" } else { "file" }
$sourceTextureReadme = if ($sourceTexture) { $sourceTexture.FullName } elseif ($sourceTextureMode -eq "embedded_packed_image") { "embedded packed image extracted from source FBX" } else { "none" }
$textureOutReadme = if ($textureOut) { $textureOut } else { "none" }
$embeddedFbxReadme = if ($embeddedFbx) { $embeddedFbx } else { "none" }
$directFbxTextureModeReadme = if ($textureOut) { "external relative sidecar texture" } else { "none" }

$readme = @"
# Roblox weapon import package

Input:
$($inputItem.FullName)

Input type:
$inputType

Detected as zip package:
$isZip

Faces:
$faces

Source polygon faces before GLB triangulation:
$($metadata.source_polygon_faces)

Final Roblox import name:
$importName

GLB internal names include face-count import name:
$glbInternalNamesIncludeFaces

Source FBX:
$($sourceFbx.FullName)

Source texture:
$sourceTextureReadme

Recommended import:
$directFbx

Direct FBX texture mode:
$directFbxTextureModeReadme

FBX scale mode:
$fbxScaleMode

FBX dimensions:
$fbxDimensions

GLB dimensions:
$glbDimensions

FBX/GLB scale match:
$fbxGlbScaleMatch

GLB fallback:
$directGlb

Embedded FBX compatibility fallback:
$embeddedFbxReadme

Mesh-only fallback:
$meshOnlyFbx

Resized texture:
$textureOutReadme

Recommended order:
1. Import the direct FBX first. Keep the resized texture in the same folder.
2. If Roblox still reports texture upload failure, import the GLB.
3. If the direct FBX fails but GLB works, keep using GLB or test the embedded FBX compatibility fallback.
4. If both fail because of texture upload, import mesh-only FBX, then upload the resized texture manually and set MeshPart.TextureID.
"@
Set-Content -Path (Join-Path $outDir "README_import_order.txt") -Value $readme -Encoding UTF8

foreach ($internalFile in @($pyPath, $metadataPath)) {
    if (Test-Path -LiteralPath $internalFile) {
        Remove-Item -LiteralPath $internalFile -Force
    }
}

Write-Host ""
Write-Host "Done. Roblox-ready files:"
Get-ChildItem -Path $outDir -File |
    Where-Object { $_.Extension -in ".fbx", ".glb", ".jpg", ".png", ".txt" } |
    Select-Object FullName, Length |
    Format-Table -AutoSize
