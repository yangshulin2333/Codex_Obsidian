---
title: "Roblox UI Importing Masterclass - Codex Knowledge Pack"
source_video: "https://www.youtube.com/watch?v=_6v86vc-9Xc&t=4153s"
video_title: "Roblox UI Importing Masterclass"
channel: "Kek"
video_duration_from_public_snippets: "3:32:50"
created_at: "2026-06-05"
format_version: "1.0"
intended_reader: "Codex / AI coding agent / Roblox UI implementer"
license_note: "This file is a knowledge extraction and implementation guide, not a verbatim transcript."
transcript_status: "Full caption transcript was not directly accessible in the current environment; chapter map and public companion/tutorial snippets were used, then technical content was normalized against Roblox documentation."
confidence: "High for chapter map and official Roblox class behavior; medium for plugin-specific Kekui details because public snippets expose only feature names."
---

# Roblox UI Importing Masterclass — Codex Knowledge Pack

## 0. What this file is

This file compresses the practical knowledge from the public video **Roblox UI Importing Masterclass** into a format optimized for AI coding agents. It is not a raw transcript. It is a structured implementation brief: definitions, chapter map, workflows, object reference, rules, anti-patterns, and Luau-oriented implementation notes.

Use this file when building, refactoring, or reviewing Roblox UI imported from Photoshop, Figma, Affinity, Photopea, or similar design tools.

## 1. Ultra-condensed mental model

Roblox UI importing is not “turn a screenshot into a game UI.” It is a rebuild pipeline:

1. Design or receive UI in a design tool.
2. Export only the image pieces that must be images.
3. Do **not** export functional text as images.
4. Upload images to Roblox and record asset IDs.
5. Rebuild the UI in Studio using ScreenGui/Frame/ImageLabel/TextLabel/buttons/layout objects.
6. Convert fixed positions into responsive Scale/AnchorPoint/constraints/layouts.
7. Add hitboxes, scripts, states, bars, scroll effects, 9-slice, and dynamic behavior.
8. Test every stage with Device Emulator.

The final UI should behave like a Roblox-native interface, not like a pasted static picture.

## 2. Sources and extraction boundary

- YouTube video: https://www.youtube.com/watch?v=_6v86vc-9Xc&t=4153s
- Roblox DevForum companion tutorial: https://devforum.roblox.com/t/extremely-detailed-roblox-ui-importing-masterclass-w-free-plugin/4619363
- Roblox ScreenGui docs: https://create.roblox.com/docs/reference/engine/classes/ScreenGui
- Roblox UDim2 docs: https://create.roblox.com/docs/reference/engine/datatypes/UDim2
- Roblox GuiObject/AnchorPoint docs: https://create.roblox.com/docs/reference/engine/classes/GuiObject/AnchorPoint
- Roblox ScrollingFrame docs: https://create.roblox.com/docs/reference/engine/classes/ScrollingFrame
- Roblox UIAspectRatioConstraint docs: https://create.roblox.com/docs/reference/engine/classes/UIAspectRatioConstraint
- Roblox UIListLayout docs: https://create.roblox.com/docs/reference/engine/classes/UIListLayout
- Roblox UIGridLayout docs: https://create.roblox.com/docs/reference/engine/classes/UIGridLayout
- Roblox 9-slice UI docs: https://create.roblox.com/docs/ui/9-slice

Important boundary: the YouTube page was discoverable through search snippets, but the full caption transcript was not fetched. Therefore, this document avoids claiming to be a verbatim transcript and instead uses chapter-level parsing plus Roblox official API behavior.

## 3. Chapter map

| # | Timestamp | Topic |
|---:|---|---|
| 1 | 00:00 | Intro |
| 2 | 00:30 | How to get Kekui? |
| 3 | 01:20 | Table of Contents |
| 4 | 01:28 | What is UI Importing? |
| 5 | 02:12 | Exporting vs Importing |
| 6 | 03:13 | Export as PNG or JPG? |
| 7 | 04:14 | Don't Export Text |
| 8 | 05:09 | Use Alt for Importing |
| 9 | 05:40 | Keep Images below 1024px |
| 10 | 06:20 | Always Save while working |
| 11 | 07:08 | Exporting from Photoshop |
| 12 | 12:18 | Exporting from Figma |
| 13 | 17:03 | Exporting from Affinity |
| 14 | 19:57 | Exporting from Photopea |
| 15 | 22:11 | Device Emulator |
| 16 | 23:27 | Uploading Images to Roblox |
| 17 | 26:23 | ScreenGui |
| 18 | 28:28 | BillboardGui |
| 19 | 30:31 | SurfaceGui |
| 20 | 32:26 | Laying Out UIs in a Hierarchy |
| 21 | 33:17 | Frame |
| 22 | 36:53 | TextLabel |
| 23 | 40:04 | ImageLabel |
| 24 | 42:16 | TextBox |
| 25 | 43:44 | TextButton |
| 26 | 44:40 | ImageButton |
| 27 | 45:30 | CanvasGroup |
| 28 | 46:25 | ViewportFrame |
| 29 | 48:47 | ScrollingFrame |
| 30 | 52:45 | UICorner |
| 31 | 53:48 | UIStroke |
| 32 | 57:07 | UIPadding |
| 33 | 57:59 | UIScale |
| 34 | 58:36 | UIAspectRatioConstraint |
| 35 | 59:43 | UIGradient |
| 36 | 01:02:02 | UIListLayout |
| 37 | 01:06:02 | UIGridLayout |
| 38 | 01:08:17 | UIPageLayout |
| 39 | 01:09:47 | UITableLayout |
| 40 | 01:10:18 | Greyscaling |
| 41 | 01:14:30 | What are Hitboxes in UI? |
| 42 | 01:16:04 | Properly Applying Constraints |
| 43 | 01:18:44 | ScrollingFrame Fading Effect |
| 44 | 01:21:07 | Getting Imported Bars to Work |
| 45 | 01:22:55 | Slice / 9-Slice |
| 46 | 01:25:03 | How to make a Round/Circular Bar |
| 47 | 01:29:14 | Kekui: Working with UI |
| 48 | 01:44:03 | (OP) Kekui's Ultra Scale |
| 49 | 01:49:17 | Exporting a Whole Anime UI |
| 50 | 01:51:51 | Importing a Whole Anime UI |
| 51 | 03:32:11 | Outro |

## 4. Core concepts

### UI importing
- **definition:** The process of converting visual UI designs from tools like Photoshop/Figma/Affinity/Photopea into Roblox Studio GUI instances, uploaded image assets, native text, layout modifiers, constraints, and interaction scripts.
- **core_distinction:** Exporting produces image files/assets from the design tool; importing rebuilds the UI inside Roblox Studio as a hierarchy of GUI objects using those assets plus native objects.

### native text rule
- **rule:** Do not export text as part of raster images unless it is purely decorative and never changes.
- **reason:** Native TextLabel/TextButton/TextBox supports localization, resizing, filtering, dynamic updates, accessibility, and scripting. Baked text becomes blurry, uneditable, difficult to localize, and hard to resize.

### image size rule
- **rule:** The video chapter map calls out keeping individual images below 1024 px. Treat 1024 px as a practical importing budget for UI pieces unless the project has a deliberate high-resolution exception.
- **reason:** Smaller pieces are easier to upload, moderate, load, scale, and reuse. Large full-screen raster UI creates memory, sharpness, and responsiveness issues.

### scale vs offset
- **rule:** Use scale for proportional layout across screens; use offset only for intentional pixel-perfect thickness, margins, or icon sizes that must not scale.
- **roblox_model:** UDim2 stores X and Y as scale + pixel offset.

### hierarchy-first UI
- **rule:** Build the UI as a clean tree of containers, controls, and modifiers instead of a flat pile of images.
- **reason:** A good hierarchy makes scaling, animation, scripting, and maintenance possible.

### device testing
- **rule:** Use Roblox Studio Device Emulator early and repeatedly. Test phone, tablet, laptop/desktop, ultrawide, and safe-area/inset cases.

### Kekui
- **definition:** A Roblox Studio plugin referenced by the tutorial for UI importing workflows. Public snippets identify features such as general UI work and Ultra Scale.
- **fallback:** If the plugin is unavailable, reproduce the workflow manually with native Roblox UI objects, Scale/Offset conversions, constraints, and layout objects.

## 5. Canonical end-to-end workflow

### 0_source_design_preflight

**Goal:** Prepare design files so the Roblox rebuild is not a fragile screenshot.

**Steps:**
- Create a clear root frame/canvas matching the intended design reference resolution.
- Name layers semantically: ShopPanel, CloseButton, Icon_Coin, ProgressFill, etc.
- Separate text, decorative imagery, backgrounds, icons, masks, and interactive hitboxes.
- Flatten only the pieces that truly need to be images.
- Keep source editable. Never use the exported PNG folder as the only source of truth.

**Acceptance:**
- Every exported asset has a matching intended Roblox instance type.
- No functional text is baked into an image.

### 1_export_assets

**Goal:** Export clean, reusable image pieces.

**Steps:**
- Use PNG for transparency, icons, panels with alpha, and irregular shapes.
- Use JPG only for large opaque photo-like images where alpha is not needed and compression artifacts are acceptable.
- Crop each asset tightly but preserve padding needed for shadows/glows.
- For resizable panels, export a clean 9-slice-capable asset with intact corners/edges.
- Keep practical UI asset dimensions at or below 1024 px unless intentionally justified.
- Use consistent names: ui_shop_panel_bg.png, ui_shop_button_primary.png, icon_coin.png.

**Acceptance:**
- All assets import without moderation/name issues.
- Assets remain sharp at intended display sizes.

### 2_upload_to_roblox

**Goal:** Turn exported images into Roblox image assets.

**Steps:**
- Upload images through Asset Manager or Creator workflows.
- Use an account/group ownership model that matches the game ownership model.
- Record asset IDs immediately after upload.
- Replace source file names with sanitized names if moderation rejects filenames.
- Create a project asset manifest mapping local filename -> Roblox asset id -> intended instance.

**Acceptance:**
- All imported ImageLabel/ImageButton instances use stable rbxassetid IDs.
- Asset manifest is committed with the UI implementation.

### 3_rebuild_hierarchy_in_studio

**Goal:** Recreate visual design as a maintainable Roblox GUI tree.

**Steps:**
- Create ScreenGui under StarterGui for HUD/menu UI.
- Create Frames for major panels, containers, masks, and invisible groups.
- Insert ImageLabels/ImageButtons only for actual image assets.
- Insert TextLabels/TextButtons/TextBoxes for all functional text.
- Parent modifiers directly under the object they modify: UICorner, UIStroke, UIPadding, UIGradient, UIAspectRatioConstraint, UIScale.
- Use UIListLayout/UIGridLayout for repeated or dynamic children.
- Set ZIndex intentionally, not by trial-and-error.

**Acceptance:**
- Hierarchy is readable by a scripter without looking at the source design.
- Dynamic objects can be found by stable names/paths.

### 4_make_responsive

**Goal:** Make the UI work across screen sizes and aspect ratios.

**Steps:**
- Convert major Position/Size values to scale-based UDim2.
- Use AnchorPoint to define the intended pivot/origin of each object.
- Apply UIAspectRatioConstraint to art that must not stretch.
- Use UIPadding/layout objects instead of hard-coded child positions wherever possible.
- Use Device Emulator after each major rebuild step.
- For full-screen complex art imports, apply a temporary UIScale or Kekui Ultra Scale, then replace fragile offsets with scale/constraints.

**Acceptance:**
- UI remains legible and clickable on phone, tablet, desktop, and safe-area screens.
- No critical controls are hidden by top bar or device notch.

### 5_add_interaction

**Goal:** Wire imported visuals to real UI behavior.

**Steps:**
- Use TextButton/ImageButton or transparent hitbox buttons for interactions.
- Prefer Activated over mouse-only events for cross-input support.
- Store dynamic state in scripts/modules; do not encode state in image file choice unless it is purely visual.
- Create hover/pressed/disabled states with property tweens or alternate images.
- For bars, animate fill Size or mask frame size, not the whole decorative shell.

**Acceptance:**
- Keyboard/gamepad/touch/mouse paths are considered.
- Button hitboxes are large enough and aligned with visuals.

### 6_validate_and_refactor

**Goal:** Make the imported UI production-ready.

**Steps:**
- Run Device Emulator tests.
- Check text overflow and localization length expansion.
- Check image blur, stretching, z-order, hitbox alignment, and scrolling boundaries.
- Replace rasterized shapes with native Frames/UICorner/UIStroke where possible.
- Commit asset manifest, hierarchy notes, and scripts.

**Acceptance:**
- A new developer can edit text, colors, spacing, and asset IDs without reopening the original design app.

## 6. Roblox UI object reference for import work

| Class | Use | Key properties/events | Import notes |
|---|---|---|---|
| `ScreenGui` | Root container for 2D on-screen UI. Parent to StarterGui for cloning to PlayerGui, or to PlayerGui at runtime. | Enabled, DisplayOrder, IgnoreGuiInset, ScreenInsets, ResetOnSpawn, ZIndexBehavior | Use one ScreenGui per major UI system or display-order group. Set IgnoreGuiInset intentionally; do not accidentally place important controls under the top bar/notch. |
| `BillboardGui` | 2D UI attached to a 3D world object, typically nameplates, prompts, floating health bars, and markers. | Adornee, StudsOffset, Size, AlwaysOnTop, MaxDistance, LightInfluence | Use for world-space UI facing the camera, not for HUD overlays. Control visibility by distance and occlusion rules. |
| `SurfaceGui` | 2D UI rendered onto a 3D part surface, such as screens, panels, terminals, signs, or in-world menus. | Adornee, Face, PixelsPerStud, SizingMode, AlwaysOnTop, LightInfluence | Design with physical surface resolution in mind. High detail needs sufficient PixelsPerStud and careful asset size. |
| `Frame` | Generic container, background block, mask base, layout parent, or invisible grouping node. | BackgroundColor3, BackgroundTransparency, Size, Position, AnchorPoint, ClipsDescendants, ZIndex | Use transparent Frames to group related elements. Use ClipsDescendants for bars, masks, and reveal animations. |
| `TextLabel` | Static text output: labels, descriptions, counters, titles, read-only values. | Text, FontFace, TextSize, TextScaled, TextWrapped, TextColor3, TextTransparency, RichText | Replace source design text layers with TextLabels. Avoid TextScaled when precise typography matters; prefer constraints and tested sizes. |
| `TextBox` | User text input fields: search bars, name entry, chat-like inputs, code entry, forms. | Text, PlaceholderText, ClearTextOnFocus, MultiLine, TextEditable, CaptureFocus, ReleaseFocus | Design focus states and placeholder states. Add validation and filtering server-side where relevant. |
| `TextButton` | Clickable button with native text. | Text, AutoButtonColor, Active, Selectable, Modal, MouseButton1Click, Activated | Use Activated for broad input compatibility when possible. Separate button visuals from hitbox if the visual is small. |
| `ImageLabel` | Non-interactive image: icons, backgrounds, decorative art, borders, sprites, imported UI pieces. | Image, ImageColor3, ImageTransparency, ScaleType, SliceCenter, ResampleMode, TileSize | Use PNG when alpha is needed. Use Slice scaling for resizable panels/buttons with protected corners. |
| `ImageButton` | Clickable image, icon button, custom art button. | Image, HoverImage, PressedImage, AutoButtonColor, Activated, Active | Use a larger transparent Frame/TextButton hitbox if the icon is visually small. Keep icon visuals and interaction logic separate when maintaining complex UI. |
| `CanvasGroup` | Group container for opacity and clipping/masking effects across descendants. | GroupTransparency, GroupColor3, ClipsDescendants | Use for fading an entire card/panel without individually tweening every child. Be aware of rendering/memory cost when overused. |
| `ViewportFrame` | Render 3D models inside UI: item previews, avatars, pets, shop models, weapon previews. | CurrentCamera, Ambient, LightColor, LightDirection, ImageTransparency | Requires a Camera and cloned model inside the ViewportFrame. Keep the 3D scene lightweight. |
| `ScrollingFrame` | Scrollable UI container for inventories, lists, shops, menus, settings pages, feeds. | CanvasSize, AutomaticCanvasSize, CanvasPosition, ScrollBarThickness, ScrollingDirection, VerticalScrollBarInset, HorizontalScrollBarInset | Pair with UIListLayout or UIGridLayout for dynamic content. Use AutomaticCanvasSize when content is generated or changes size. |
| `UICorner` | Rounded corners on frames/buttons/images. | CornerRadius | Use UICorner instead of exporting simple rounded rectangles as images. For perfect circles, set aspect ratio 1:1 and CornerRadius roughly 0.5 scale. |
| `UIStroke` | Outline/border around GuiObjects or text. | Color, Thickness, Transparency, ApplyStrokeMode, LineJoinMode | Use native strokes instead of rasterized borders when possible. Check stroke thickness at multiple screen sizes; it is pixel-based unless managed by tooling. |
| `UIPadding` | Internal spacing between container edges and children. | PaddingTop, PaddingRight, PaddingBottom, PaddingLeft | Use padding to preserve spacing while layout objects position children. |
| `UIScale` | Scale an entire subtree uniformly. | Scale | Use sparingly as a global multiplier. Prefer proper scale-based Size/Position for final responsive UI. |
| `UIAspectRatioConstraint` | Maintain a fixed width/height ratio. | AspectRatio, AspectType, DominantAxis | Use for icons, avatars, cards, circular controls, square grid cells, and imported art pieces that must not distort. |
| `UIGradient` | Color/transparency gradient across UI objects; supports visual fades and overlay effects. | Color, Transparency, Rotation, Offset | For scroll fades, place gradient overlays near the top/bottom edges rather than modifying content images. |
| `UIListLayout` | Arrange siblings in a horizontal or vertical list. | FillDirection, HorizontalAlignment, VerticalAlignment, Padding, SortOrder, Wraps | Use for menu lists, tabs, button rows, vertical cards, settings groups. Do not manually position children controlled by a layout unless intentionally overriding. |
| `UIGridLayout` | Arrange siblings into rows/columns. | CellSize, CellPadding, FillDirection, FillDirectionMaxCells, StartCorner, SortOrder | Use for inventories, shops, badges, grids of cards/icons. Pair with UIAspectRatioConstraint when cells must stay square. |
| `UIPageLayout` | Page-by-page layout for carousel, paged menus, onboarding, galleries. | Animated, Circular, EasingDirection, EasingStyle, Padding, TweenTime | Use when only one page/card should be primary at a time. |
| `UITableLayout` | Table-style rows and columns for structured settings/stats layouts. | FillEmptySpaceColumns, FillEmptySpaceRows, MajorAxis, Padding | Use for simple grid-like forms and stat tables. UIGridLayout is often simpler for visual grids. |

## 7. Practical recipes from the tutorial topics

### Photoshop Export
- Organize layers into exportable groups.
- Hide text layers before exporting if text will be native Roblox text.
- Use Export As / Quick Export as PNG for transparent pieces.
- Check canvas bounds and trim excessive transparent pixels only if it does not cut shadows/glows.
- Name files before upload; Roblox moderation can react to filenames as well as image contents.

### Figma Export
- Use frames/components named to match Roblox instances.
- Export selected layers/groups at 1x or the minimum scale that remains sharp in-game.
- Do not export live text unless it is purely decorative art.
- Prefer SVG only as a source format; Roblox UI import commonly uses uploaded raster image assets.
- Keep a manifest of Figma node name -> exported file -> Roblox asset ID.

### Affinity Export
- Use slices or export persona to export individual UI pieces.
- Preserve alpha for icons, panels, glows, and non-rectangular art.
- Check that exported pixel dimensions match the intended Roblox display proportions.

### Photopea Export
- Use Photopea as a browser alternative for PSD-like exports.
- Export selected layers/groups as PNG.
- Verify text layers are not accidentally included in button/background assets.

### Device Emulator Testing
- Test at least: small phone portrait, phone landscape, tablet, laptop, 16:9 desktop, ultrawide.
- Check safe areas/insets, especially top-left/top-right controls and bottom mobile UI.
- Check whether layout changes are acceptable rather than merely non-overlapping.
- Test with Roblox top bar visible and hidden if the game uses top bar toggles.

### Scrolling Frame Fade
- Use a ScrollingFrame for content.
- Add non-interactive overlay Frames at the top/bottom edge of the visible scroll window.
- Add UIGradient to overlays with transparency fading from opaque to transparent.
- Set overlays above content via ZIndex but do not block input; if needed, make them non-active.
- Adjust overlay height by scale/offset so the fade works on multiple screen sizes.

### Imported Progress Bar
- Split the visual into background shell, fill region, and optional foreground gloss/border.
- Use a Frame as the clipping container with ClipsDescendants = true.
- Put fill ImageLabel/Frame inside the clipping container.
- Drive progress by setting fill.Size = UDim2.fromScale(progress, 1) for horizontal bars, clamped to 0..1.
- Keep labels/text outside the clipped fill unless the text itself should be clipped.

### Nine Slice Panel
- Design an image with stable corners, stretchable edges, and a stretchable center.
- Import as ImageLabel/ImageButton.
- Set ScaleType = Slice.
- Set SliceCenter to protect corners/edges.
- Resize the object in Studio and verify corners do not distort.

### Round Or Circular Bar
- Use a square container with UIAspectRatioConstraint = 1:1.
- For simple circular fill, use a circular ImageLabel/Frame with UICorner and clip/mask strategy.
- For radial progress, split into left/right semicircle masks or use pre-rendered radial states if exact shader-like behavior is not required.
- Keep the center label native TextLabel and independent of the fill visuals.

### Whole Ui Import
- Break the design into major containers first, not individual pixels.
- Rebuild background panels, major frames, and layout skeleton.
- Insert images and native text in hierarchy order.
- Apply constraints/layouts after the visual tree is recognizable.
- Use plugin-assisted scaling only as a starting point; manually inspect every interactive element afterward.
- Finish with Device Emulator and interaction tests.

## 8. Codex directives

- When asked to implement a Roblox UI from this knowledge pack, generate a Studio hierarchy plan first, then Luau code only where interaction/dynamic behavior is needed.
- Never convert functional text to an image asset. Use TextLabel, TextButton, or TextBox.
- Prefer native rounded rectangles (Frame + UICorner + UIStroke) over imported raster buttons unless custom art requires an image.
- Use scale-based UDim2 for responsive major layout. Use offset intentionally for thin strokes, icon padding, and minimum pixel margins.
- Use AnchorPoint consistently: center objects with AnchorPoint=(0.5,0.5), right-aligned objects with X=1, bottom-aligned objects with Y=1.
- For dynamic lists/grids, never manually position every child. Use UIListLayout/UIGridLayout and clone item templates.
- For ScrollingFrame content, prefer AutomaticCanvasSize with a layout object unless there is a strong reason to calculate CanvasSize manually.
- Always expose asset IDs, important instance names, and key constants at the top of generated scripts/modules.
- Do not depend on Kekui unless the user confirms it is installed. Provide a native Roblox fallback.

## 9. Anti-patterns to flag during code review

- One huge full-screen PNG for the entire UI.
- Baked text inside PNG/JPG for buttons, labels, counters, or inputs.
- Every child manually positioned inside a dynamic list or shop grid.
- Using Offset for all sizes/positions, causing broken mobile/tablet layouts.
- Not testing with Device Emulator until the end.
- Small visual icon used directly as the only click hitbox.
- Overusing UIScale as a permanent fix instead of applying correct UDim2 scale and constraints.
- Uploading assets from a personal account when the experience/group needs ownership continuity.
- Ignoring safe areas and top bar insets.
- Treating plugin output as final without inspecting hierarchy, scaling, text, hitboxes, and scripts.

## 10. Suggested Roblox UI hierarchy pattern

```text
StarterGui
└── ShopGui : ScreenGui
    ├── SafeAreaRoot : Frame              # transparent root container if needed
    │   ├── MainPanel : Frame             # main resizable panel
    │   │   ├── UICorner
    │   │   ├── UIStroke
    │   │   ├── UIPadding
    │   │   ├── Header : Frame
    │   │   │   ├── Title : TextLabel
    │   │   │   └── CloseButton : ImageButton/TextButton
    │   │   ├── ContentScroll : ScrollingFrame
    │   │   │   ├── UIListLayout or UIGridLayout
    │   │   │   └── ItemTemplate : Frame
    │   │   └── Footer : Frame
    │   │       └── ConfirmButton : TextButton
    │   └── ModalBlocker : TextButton     # optional transparent full-screen blocker
    └── Scripts
        └── ShopController : LocalScript
```

Guideline: make instance names stable and semantic because scripts and Codex agents rely on names to find nodes.

## 11. Asset manifest pattern

Use a manifest whenever importing images:

```json
{
  "ui_shop_panel_bg.png": {
    "asset_id": "rbxassetid://0000000000",
    "intended_class": "ImageLabel",
    "scale_type": "Slice",
    "slice_center": [16, 16, 112, 112],
    "notes": "Resizable panel background; native text overlays this image."
  },
  "icon_coin.png": {
    "asset_id": "rbxassetid://0000000000",
    "intended_class": "ImageLabel",
    "constraints": ["UIAspectRatioConstraint 1:1"],
    "notes": "Decorative currency icon."
  }
}
```

## 12. Implementation checklists

### Pre-import checklist

- Source design file is saved and backed up.
- Layers are named semantically.
- Functional text is separated from image exports.
- Repeated list/grid items are designed as templates, not individually exported duplicates.
- Transparent PNG pieces have clean bounds and include required shadows/glows.
- Large assets are split into smaller logical parts when possible.

### Roblox rebuild checklist

- ScreenGui is under StarterGui or PlayerGui as intended.
- Major panels use scale-based Size/Position.
- AnchorPoint matches intended alignment.
- Text is native TextLabel/TextButton/TextBox.
- Icons and panels use ImageLabel/ImageButton only where image art is needed.
- UICorner/UIStroke/UIPadding replace simple raster effects where possible.
- Layout objects handle dynamic repeated children.
- 9-slice is used for stretchable image panels/buttons.
- ScrollingFrame content uses AutomaticCanvasSize or a deliberate CanvasSize calculation.
- Hitboxes are large enough for touch.
- Device Emulator passes small phone/tablet/desktop tests.

### Final review checklist

- No important text blurs at any tested resolution.
- No important control is hidden by top bar/notch/safe area.
- Button states are visible and scripted.
- Scrolling bars/fades do not block input.
- Progress bars clamp between 0 and 1.
- Dynamic data can update without replacing image assets.
- Asset IDs are centralized in a manifest/module.
- UI can be handed to a scripter without opening the original design file.


## Luau snippets for implementation agents

### Create a basic responsive ScreenGui tree
```lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.72, 0.74)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.85
stroke.Parent = panel
```

### Safe button binding
```lua
local button = script.Parent :: GuiButton

button.Activated:Connect(function()
    print("Button activated by mouse/touch/gamepad")
end)
```

### Horizontal progress bar using a clipped fill
```lua
local function setProgress(fill: GuiObject, progress: number)
    progress = math.clamp(progress, 0, 1)
    fill.Size = UDim2.fromScale(progress, 1)
end
```

### Dynamic ScrollingFrame with UIListLayout
```lua
local scrollingFrame = script.Parent:WaitForChild("ItemScroll") :: ScrollingFrame
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame
```

### 9-slice setup
```lua
local image = script.Parent :: ImageLabel
image.ScaleType = Enum.ScaleType.Slice
-- Example only. Replace with the correct Rect for the imported asset.
image.SliceCenter = Rect.new(16, 16, 112, 112)
```


## 13. Notes for future transcript-based refinement

If a full caption transcript becomes available, refine this file by adding:

- Exact plugin-specific Kekui operations and button names.
- Exact hotkey behavior for “Use Alt for Importing.”
- Any creator-specific warnings that are not visible in public snippets.
- Timestamped micro-steps inside the long “Importing a Whole Anime UI” demonstration.
- Any quoted advice only as short excerpts, not as a full transcript.
