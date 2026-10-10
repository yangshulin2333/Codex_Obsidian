param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [string]$OutputRoot = "$env:USERPROFILE\Desktop\weapon_upload",

    [string]$Name = "",

    [int]$TextureSize = 1024,

    [ValidateSet("jpg", "png")]
    [string]$TextureFormat = "jpg",

    [string]$BlenderExe = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
)

$ErrorActionPreference = "Stop"

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

    $images = Get-ChildItem -LiteralPath $searchRoot -Recurse -File |
        Where-Object {
            $_.Extension -in ".png", ".jpg", ".jpeg" -and
            ($allowExtractedRoot -or $_.FullName -notmatch '\\_extracted(\\|$)') -and
            ($allowExtractedRoot -or $_.FullName -notmatch '\\[^\\]+_roblox_direct(\\|$)') -and
            $_.FullName -notmatch '\\Roblox_Ready(\\|$)' -and
            $_.FullName -notmatch '\\Roblox_Import[^\\]*(\\|$)' -and
            $_.FullName -notmatch '\.fbm(\\|$)'
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
$outDir = Join-Path $OutputRoot "${safeName}_roblox_direct"
$extractDir = Join-Path $outDir "_extracted"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

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

$textureOut = $null
if ($sourceTexture) {
    $textureOut = Join-Path $outDir "${safeName}_texture_${TextureSize}.${TextureFormat}"
    Resize-Texture -SourcePath $sourceTexture.FullName -OutputPath $textureOut -Size $TextureSize -Format $TextureFormat
}

$directFbx = Join-Path $outDir "${safeName}_direct_${TextureSize}tex.fbx"
$directGlb = Join-Path $outDir "${safeName}_direct_${TextureSize}tex.glb"
$meshOnlyFbx = Join-Path $outDir "${safeName}_mesh_only.fbx"
$pyPath = Join-Path $outDir "_prepare_in_blender.py"

$hasTexture = [bool]$textureOut
$pyHasTexture = if ($hasTexture) { "True" } else { "False" }
$py = @"
import bpy
import os
import shutil

src_fbx = r'''$($sourceFbx.FullName)'''
texture_path = r'''$textureOut'''
direct_fbx = r'''$directFbx'''
direct_glb = r'''$directGlb'''
mesh_only_fbx = r'''$meshOnlyFbx'''
has_texture = $pyHasTexture

os.makedirs(os.path.dirname(direct_fbx), exist_ok=True)

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.import_scene.fbx(filepath=src_fbx)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']

if not meshes:
    raise RuntimeError('No mesh object imported from FBX')

mat = bpy.data.materials.new('${safeName}_roblox_material')
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
    tex_node.image = img
    mat.node_tree.links.new(tex_node.outputs['Color'], bsdf.inputs['Base Color'])
    mat.node_tree.links.new(bsdf.outputs['BSDF'], output.inputs['Surface'])
    if 'Roughness' in bsdf.inputs:
        bsdf.inputs['Roughness'].default_value = 0.55
    if 'Metallic' in bsdf.inputs:
        bsdf.inputs['Metallic'].default_value = 0.15
else:
    mat.use_nodes = False

for obj in meshes:
    obj.name = '${safeName}_mesh'
    obj.data.name = '${safeName}_mesh_data'
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
    fallback = bpy.data.materials.new('${safeName}_plain_material')
    fallback.diffuse_color = (0.85, 0.72, 0.42, 1.0)
    obj.data.materials.append(fallback)
bpy.ops.export_scene.fbx(
    filepath=mesh_only_fbx,
    use_selection=True,
    object_types={'MESH'},
    use_mesh_modifiers=True,
    add_leaf_bones=False,
    bake_anim=False,
    path_mode='AUTO',
    embed_textures=False,
)

# Restore textured material before direct exports.
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

print('ROBLOX_WEAPON_EXPORT_OK')
print('source_fbx=' + src_fbx)
print('texture=' + (texture_path if has_texture else 'none'))
print('faces=' + str(sum(len(o.data.polygons) for o in meshes)))
print('direct_fbx=' + direct_fbx)
print('direct_glb=' + direct_glb)
print('mesh_only_fbx=' + mesh_only_fbx)
"@

Set-Content -Path $pyPath -Value $py -Encoding UTF8
& $BlenderExe --background --python $pyPath
if ($LASTEXITCODE -ne 0) {
    throw "Blender export failed. See console output above."
}
if (-not (Test-Path -LiteralPath $directFbx)) {
    throw "Direct FBX was not generated: $directFbx"
}
if (-not (Test-Path -LiteralPath $directGlb)) {
    throw "Direct GLB was not generated: $directGlb"
}
if (-not (Test-Path -LiteralPath $meshOnlyFbx)) {
    throw "Mesh-only FBX was not generated: $meshOnlyFbx"
}

$inputType = if ($inputIsDirectory) { "directory" } else { "file" }
$sourceTextureReadme = if ($sourceTexture) { $sourceTexture.FullName } else { "none" }
$textureOutReadme = if ($textureOut) { $textureOut } else { "none" }

$readme = @"
# Roblox weapon import package

Input:
$($inputItem.FullName)

Input type:
$inputType

Detected as zip package:
$isZip

Source FBX:
$($sourceFbx.FullName)

Source texture:
$sourceTextureReadme

Recommended import:
$directFbx

GLB fallback:
$directGlb

Mesh-only fallback:
$meshOnlyFbx

Resized texture:
$textureOutReadme

Recommended order:
1. Import the direct FBX first.
2. If Roblox still reports texture upload failure, import the GLB.
3. If both fail because of texture upload, import mesh-only FBX, then upload the resized texture manually and set MeshPart.TextureID.
"@
Set-Content -Path (Join-Path $outDir "README_import_order.txt") -Value $readme -Encoding UTF8

Write-Host ""
Write-Host "Done. Roblox-ready files:"
Get-ChildItem -Path $outDir -File |
    Where-Object { $_.Extension -in ".fbx", ".glb", ".jpg", ".png", ".txt" } |
    Select-Object FullName, Length |
    Format-Table -AutoSize
