"""Offline authoring for Studio-editable native TravelBuddy GUI templates.

Run only when intentionally rebuilding the whitebox templates. Studio edits are
the source of truth after handoff; runtime Luau never builds this tree.
"""
from pathlib import Path
import argparse
import base64
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "src/ReplicatedStorage/Game/Resources/UI/TravelBuddy"
FRAMEWORK = ROOT / "src/ReplicatedStorage/Framework/Shared/UI"
SERIAL = 1000
INK = (0.10, 0.20, 0.23)
PAPER = (0.97, 0.96, 0.90)
SEA = (0.25, 0.64, 0.72)
GREEN = (0.17, 0.39, 0.35)
TEMPLATE = "AQAAAAgAAABUZW1wbGF0ZQMB"
# Verified in Studio: Enum.SortOrder.Name=0, Custom=1, LayoutOrder=2.
SORT_LAYOUT_ORDER = 2


def prop(node, kind, name, value):
    props = node.find("Properties")
    for old in list(props):
        if old.get("name") == name:
            props.remove(old)
    elem = ET.SubElement(props, kind, name=name)
    if isinstance(value, dict):
        for key, val in value.items():
            ET.SubElement(elem, key).text = str(val)
    else:
        elem.text = str(value).lower() if isinstance(value, bool) else str(value)
    return elem


def item(parent, cls, name):
    global SERIAL
    SERIAL += 1
    node = ET.SubElement(parent, "Item", {"class": cls, "referent": str(SERIAL)})
    ET.SubElement(node, "Properties")
    prop(node, "string", "Name", name)
    return node


def udim(node, name, x, y, ox=0, oy=0):
    prop(node, "UDim2", name, {"XS": x, "XO": ox, "YS": y, "YO": oy})


def color(node, name, value):
    prop(node, "Color3", name, dict(zip(("R", "G", "B"), value)))


def name_of(node):
    return node.find("Properties/string[@name='Name']").text


def find(root, name):
    return next(n for n in root.iter("Item") if name_of(n) == name)


def gui(parent, cls, name, x, y, w, h, bg=PAPER, visible=True, height_px=0):
    node = item(parent, cls, name)
    udim(node, "Position", x, y)
    udim(node, "Size", w, h, oy=height_px)
    color(node, "BackgroundColor3", bg)
    prop(node, "float", "BackgroundTransparency", 0)
    prop(node, "int", "BorderSizePixel", 0)
    prop(node, "bool", "Visible", visible)
    prop(node, "bool", "AutoLocalize", False)
    prop(node, "int", "ZIndex", 1)
    if cls in ("TextLabel", "TextButton"):
        color(node, "TextColor3", INK)
        prop(node, "bool", "TextScaled", True)
        prop(node, "bool", "TextWrapped", True)
        prop(node, "token", "Font", 4)
        prop(node, "token", "TextXAlignment", 0)
        constraint = item(node, "UITextSizeConstraint", "ReadableText")
        prop(constraint, "int", "MinTextSize", 11)
        prop(constraint, "int", "MaxTextSize", 24)
    if cls == "TextButton":
        color(node, "BackgroundColor3", GREEN)
        color(node, "TextColor3", PAPER)
        prop(node, "bool", "Active", True)
        prop(node, "bool", "Selectable", True)
        prop(node, "token", "TextXAlignment", 2)
        touch = item(node, "UISizeConstraint", "TouchTarget")
        prop(touch, "Vector2", "MinSize", {"X": 44, "Y": 44})
        prop(touch, "Vector2", "MaxSize", {"X": 10000, "Y": 10000})
    return node


def text(parent, name, words, x, y, w, h, bg=None, height_px=0):
    node = gui(parent, "TextLabel", name, x, y, w, h, bg or PAPER, height_px=height_px)
    prop(node, "string", "Text", words)
    if bg is None:
        prop(node, "float", "BackgroundTransparency", 1)
    return node


def button(parent, name, words, x, y, w, h):
    node = gui(parent, "TextButton", name, x, y, w, h)
    prop(node, "string", "Text", words)
    return node


def scroll(parent, name, x, y, w, h):
    node = gui(parent, "ScrollingFrame", name, x, y, w, h)
    prop(node, "float", "BackgroundTransparency", 1)
    prop(node, "bool", "Active", True)
    prop(node, "token", "AutomaticCanvasSize", 2)
    prop(node, "token", "ScrollingDirection", 2)
    prop(node, "int", "ScrollBarThickness", 6)
    udim(node, "CanvasSize", 0, 0)
    layout = item(node, "UIListLayout", "Rows")
    prop(layout, "token", "SortOrder", SORT_LAYOUT_ORDER)
    prop(layout, "UDim", "Padding", {"S": 0, "O": 8})
    return node


def vertical_panel(node, heights):
    """Native scrolling preserves 44px targets in short landscape viewports."""
    node.set("class", "ScrollingFrame")
    prop(node, "float", "BackgroundTransparency", 1)
    prop(node, "bool", "Active", True)
    prop(node, "token", "AutomaticCanvasSize", 2)
    prop(node, "token", "ScrollingDirection", 2)
    prop(node, "int", "ScrollBarThickness", 6)
    udim(node, "CanvasSize", 0, 0)
    for index, (name, height) in enumerate(heights):
        child = find(node, name)
        udim(child, "Position", 0, 0)
        udim(child, "Size", 0.98, 0, oy=height)
        prop(child, "int", "LayoutOrder", index)
    layout = item(node, "UIListLayout", "Sections")
    prop(layout, "token", "SortOrder", SORT_LAYOUT_ORDER)
    prop(layout, "UDim", "Padding", {"S": 0, "O": 8})


def choice_row(parent, name, first, second):
    row = gui(parent, "Frame", name, 0, 0, 1, 0, height_px=60)
    prop(row, "float", "BackgroundTransparency", 1)
    for node, x in ((first, 0), (second, 0.52)):
        parent.remove(node)
        row.append(node)
        udim(node, "Position", x, 0)
        udim(node, "Size", 0.48, 1)
    return row


def image_slot(parent, name, x, y, w, h):
    node = gui(parent, "ImageLabel", name, x, y, w, h, visible=False)
    prop(node, "float", "BackgroundTransparency", 1)
    prop(node, "token", "ScaleType", 3)
    prop(node, "Content", "ImageContent", {"null": ""})
    return node


def illustration(parent, name, x, y, w, h, show_note=True):
    scene = gui(parent, "Frame", name, x, y, w, h, (0.64, 0.86, 0.88))
    gui(scene, "Frame", "Sea", 0, 0.53, 1, 0.47, SEA)
    sun = gui(scene, "Frame", "Sun", 0.76, 0.08, 0.14, 0.20, (1, 0.81, 0.35))
    corner = item(sun, "UICorner", "Round")
    prop(corner, "UDim", "CornerRadius", {"S": 1, "O": 0})
    gui(scene, "Frame", "Island", 0.10, 0.39, 0.32, 0.15, (0.48, 0.65, 0.39))
    gui(scene, "Frame", "Sand", 0.08, 0.53, 0.36, 0.05, (0.94, 0.83, 0.59))
    gui(scene, "Frame", "Hull", 0.54, 0.66, 0.25, 0.06, (0.53, 0.31, 0.17))
    gui(scene, "Frame", "Mast", 0.64, 0.28, 0.015, 0.39, (0.53, 0.31, 0.17))
    gui(scene, "Frame", "Sail", 0.66, 0.30, 0.12, 0.27, PAPER)
    note = text(scene, "PlaceholderNote", "插画占位 · 正式美术待制作", 0.04, 0.86, 0.92, 0.11)
    prop(note, "bool", "Visible", show_note)
    return scene


def transparent(parent, name, x, y, w, h, visible=True):
    node = gui(parent, "Frame", name, x, y, w, h, visible=visible)
    prop(node, "float", "BackgroundTransparency", 1)
    return node


def rounded(node, radius=1):
    corner = item(node, "UICorner", "Round")
    prop(corner, "UDim", "CornerRadius", {"S": radius, "O": 0})
    return node


def aspect(node, ratio):
    constraint = item(node, "UIAspectRatioConstraint", "PreserveShape")
    prop(constraint, "float", "AspectRatio", ratio)
    prop(constraint, "token", "AspectType", 0)  # FitWithinMaxSize
    return node


def anchor(node, x, y):
    prop(node, "Vector2", "AnchorPoint", {"X": x, "Y": y})
    return node


def animated(node):
    # Serialized native attribute: Animation=true. Only these roots may move.
    key = b"Animation"
    value = struct.pack("<II", 1, len(key)) + key + b"\x03\x01"
    prop(node, "BinaryString", "AttributesSerialize", base64.b64encode(value).decode("ascii"))
    prop(node, "float", "Rotation", 0)
    return node


def layer_paths(root, layers):
    """Native sibling layers cannot rely on XML/Rojo child order."""
    for path, index in layers.items():
        node = root
        for segment in path.split("."):
            node = next(child for child in node.findall("Item") if name_of(child) == segment)
        prop(node, "int", "ZIndex", index)


def clouds(layer, near=False):
    white = (0.93, 0.97, 0.95) if not near else (0.86, 0.93, 0.96)
    for number, (x, y, size) in enumerate(((0.03, 0.24, 0.18), (0.38, 0.10, 0.14), (0.78, 0.38, 0.21)), 1):
        cloud = transparent(layer, f"Cloud{number}", x, y, size, 0.30)
        for index, (px, py, pw, ph) in enumerate(((0, 0.38, 1, 0.45), (0.15, 0, 0.46, 0.80), (0.48, 0.22, 0.40, 0.68)), 1):
            rounded(gui(cloud, "Frame", f"Puff{index}", px, py, pw, ph, white))


def waves(layer, near=False):
    colors = ((0.60, 0.85, 0.84), (0.43, 0.76, 0.80)) if not near else ((0.49, 0.74, 0.84), (0.34, 0.62, 0.77))
    for number, (x, y, width) in enumerate(((0.03, 0.08, 0.15), (0.29, 0.28, 0.18), (0.66, 0.15, 0.21),
                                             (0.08, 0.62, 0.23), (0.50, 0.83, 0.17), (0.81, 0.55, 0.20)), 1):
        rounded(gui(layer, "Frame", f"Wave{number}", x, y, width, 0.018, colors[number % 2]))


def sea_background(parent, name, near=False):
    sky = (0.66, 0.85, 0.90) if not near else (0.62, 0.74, 0.88)
    water = (0.21, 0.65, 0.72) if not near else (0.15, 0.42, 0.62)
    root = gui(parent, "Frame", name, 0, 0, 1, 1, sky, visible=not near)
    # Empty editable image layers allow artists to replace geometry in place.
    image_slot(root, "BackgroundArtwork", 0, 0, 1, 1)
    sun = anchor(rounded(gui(root, "Frame", "Sun", 0.83, 0.18, 0.14, 0.25,
                            (1, 0.87, 0.54) if not near else (0.98, 0.91, 0.70))), 0.5, 0.5)
    aspect(sun, 1)
    gui(root, "Frame", "DistantSea", 0, 0.46, 1, 0.54, water)
    gui(root, "Frame", "Horizon", 0, 0.46, 1, 0.012, (0.74, 0.89, 0.88))
    if near:
        island = transparent(root, "LighthouseIsland", 0.08, 0.18, 0.32, 0.33)
        rounded(gui(island, "Frame", "FarCliff", 0.05, 0.64, 0.90, 0.32, (0.26, 0.46, 0.48)), 0.28)
        rounded(gui(island, "Frame", "Grass", 0, 0.57, 1, 0.15, (0.35, 0.56, 0.46)), 0.36)
        tower = gui(island, "Frame", "Tower", 0.47, 0.18, 0.14, 0.41, (0.98, 0.94, 0.84))
        gui(tower, "Frame", "Stripe", 0, 0.39, 1, 0.20, (0.75, 0.33, 0.27))
        gui(island, "Frame", "Lamp", 0.45, 0.07, 0.18, 0.12, (0.98, 0.77, 0.31))
        rounded(gui(island, "Frame", "Roof", 0.42, 0, 0.24, 0.10, (0.40, 0.36, 0.40)), 0.22)
        for index, (x, y, width) in enumerate(((0.72, 0.43, 0.16), (0.89, 0.48, 0.11)), 1):
            rounded(gui(root, "Frame", f"Reef{index}", x, y, width, 0.065, (0.29, 0.42, 0.50)), 0.30)
    else:
        island = transparent(root, "PalmIsland", 0.07, 0.27, 0.32, 0.27)
        rounded(gui(island, "Frame", "Hill", 0.10, 0.44, 0.78, 0.36, (0.44, 0.68, 0.43)), 0.40)
        rounded(gui(island, "Frame", "Sand", 0, 0.75, 1, 0.12, (0.98, 0.85, 0.58)), 0.46)
        trunk = gui(island, "Frame", "PalmTrunk", 0.41, 0.23, 0.035, 0.55, (0.55, 0.38, 0.24))
        prop(trunk, "float", "Rotation", 8)
        for index, (x, y, width, rotation) in enumerate(((0.23, 0.20, 0.24, -24), (0.42, 0.22, 0.29, 22),
                                                        (0.30, 0.12, 0.19, -46), (0.44, 0.13, 0.18, 42)), 1):
            leaf = rounded(gui(island, "Frame", f"PalmLeaf{index}", x, y, width, 0.095, (0.20, 0.48, 0.35)))
            prop(leaf, "float", "Rotation", rotation)
        rounded(gui(root, "Frame", "Sandbar", 0.69, 0.51, 0.23, 0.025, (0.82, 0.80, 0.59)))
    cloud_layer = animated(transparent(root, "CloudLayer", -0.06, 0.03, 1.12, 0.31))
    clouds(cloud_layer, near)
    wave_layer = animated(transparent(root, "WaveLayer", -0.06, 0.52, 1.12, 0.48))
    waves(wave_layer, near)
    return root


def frog(parent):
    root = anchor(transparent(parent, "Frog", 0.51, 0.56, 0.31, 0.49), 0.5, 1)
    aspect(root, 1)
    body = transparent(root, "Body", 0, 0, 1, 1)
    green = (0.34, 0.65, 0.38)
    rounded(gui(body, "Frame", "Torso", 0.19, 0.39, 0.65, 0.59, green), 0.46)
    rounded(gui(body, "Frame", "Belly", 0.31, 0.57, 0.40, 0.34, (0.82, 0.85, 0.56)), 0.46)
    rounded(gui(body, "Frame", "Head", 0.07, 0.10, 0.88, 0.59, green), 0.40)
    for name, x in (("LeftEye", 0.12), ("RightEye", 0.62)):
        rounded(gui(body, "Frame", name, x, 0, 0.27, 0.33, green))
    for name, x in (("LeftHand", 0.01), ("RightHand", 0.78)):
        rounded(gui(body, "Frame", name, x, 0.62, 0.22, 0.18, green))
    for name, x in (("LeftFoot", 0.11), ("RightFoot", 0.61)):
        rounded(gui(body, "Frame", name, x, 0.88, 0.29, 0.12, green))
    rounded(gui(body, "Frame", "Smile", 0.41, 0.49, 0.21, 0.026, INK))
    open_eyes = transparent(root, "EyesOpen", 0, 0, 1, 1)
    closed_eyes = transparent(root, "EyesClosed", 0, 0, 1, 1, visible=False)
    look = transparent(root, "Look", 0, 0, 1, 1, visible=False)
    for name, x in (("Left", 0.17), ("Right", 0.67)):
        rounded(gui(open_eyes, "Frame", name + "White", x, 0.08, 0.17, 0.17, PAPER))
        rounded(gui(open_eyes, "Frame", name + "Pupil", x + 0.056, 0.13, 0.070, 0.10, INK))
        rounded(gui(closed_eyes, "Frame", name + "Lid", x, 0.19, 0.17, 0.028, INK))
        rounded(gui(look, "Frame", name + "White", x, 0.08, 0.17, 0.17, PAPER))
        rounded(gui(look, "Frame", name + "Pupil", x + 0.080, 0.13, 0.070, 0.10, INK))
    drink = transparent(root, "Drink", 0, 0, 1, 1, visible=False)
    rounded(gui(drink, "Frame", "Cup", 0.62, 0.49, 0.25, 0.22, PAPER), 0.20)
    gui(drink, "Frame", "Straw", 0.70, 0.35, 0.035, 0.20, (0.82, 0.41, 0.31))
    rounded(gui(drink, "Frame", "Hand", 0.55, 0.58, 0.23, 0.11, green))
    return root


def travel_boat(parent, name, sail=False):
    boat = anchor(animated(transparent(parent, name, 0.57, 0.82, 0.62, 0.65, visible=not sail)), 0.5, 1)
    aspect(boat, 1.55)
    # Native layering places the frog ahead of the sail and behind the hull.
    rounded(gui(boat, "Frame", "Wake", 0.01, 0.90, 0.98, 0.035, (0.82, 0.92, 0.88)))
    if sail:
        gui(boat, "Frame", "Mast", 0.78, 0.04, 0.025, 0.73, (0.48, 0.30, 0.18))
        sail_node = rounded(gui(boat, "Frame", "Sail", 0.57, 0.08, 0.20, 0.46, PAPER), 0.10)
        prop(sail_node, "float", "Rotation", -4)
        prop(gui(boat, "Frame", "Flag", 0.80, 0.05, 0.14, 0.09, (0.87, 0.40, 0.27)), "float", "Rotation", -5)
    else:
        oar = gui(boat, "Frame", "Oar", 0.08, 0.64, 0.40, 0.035, (0.62, 0.40, 0.23))
        prop(oar, "float", "Rotation", -22)
        paddle = rounded(gui(boat, "Frame", "Paddle", 0.03, 0.70, 0.13, 0.055, (0.62, 0.40, 0.23)), 0.20)
        prop(paddle, "float", "Rotation", -22)
    frog(boat)
    rounded(gui(boat, "Frame", "Hull", 0.06, 0.63, 0.87, 0.23, (0.57, 0.34, 0.20)), 0.32)
    rounded(gui(boat, "Frame", "Rim", 0.03, 0.61, 0.93, 0.08, (0.76, 0.51, 0.29)), 0.30)
    gui(boat, "Frame", "HullStripe", 0.15, 0.73, 0.67, 0.027, (0.76, 0.51, 0.29))
    image_slot(boat, "BoatArtwork", 0, 0, 1, 1)
    return boat


def travel_illustration(parent):
    stage = gui(parent, "Frame", "Illustration", 0.03, 0, 0.94, 1, (0.66, 0.85, 0.90))
    udim(stage, "Position", 0.03, 0, oy=78)
    udim(stage, "Size", 0.94, 1, oy=-94)
    prop(stage, "bool", "ClipsDescendants", True)
    rounded(stage, 0.035)
    sea_background(stage, "Shallow")
    sea_background(stage, "Near", near=True)
    travel_boat(stage, "BoatLv1")
    travel_boat(stage, "BoatLv2", sail=True)
    foreground = transparent(stage, "Foreground", 0, 0.90, 1, 0.10)
    rounded(gui(foreground, "Frame", "FoamLeft", -0.05, 0.28, 0.35, 0.08, (0.62, 0.86, 0.85)))
    rounded(gui(foreground, "Frame", "FoamRight", 0.71, 0.70, 0.40, 0.10, (0.62, 0.86, 0.85)))
    note = text(stage, "PlaceholderNote", "", 0, 0, 0, 0)
    prop(note, "bool", "Visible", False)
    layer_paths(stage, {"Shallow": 1, "Near": 1, "BoatLv1": 3, "BoatLv2": 3, "Foreground": 4})
    for sea in ("Shallow", "Near"):
        layer_paths(find(stage, sea), {"DistantSea": 1, "Sun": 2, "Horizon": 2,
                                      "BackgroundArtwork": 3, "CloudLayer": 4, "WaveLayer": 4})
    layer_paths(find(stage, "Shallow"), {"PalmIsland": 2, "Sandbar": 2,
                                        "PalmIsland.Hill": 1, "PalmIsland.Sand": 2,
                                        "PalmIsland.PalmTrunk": 3,
                                        **{f"PalmIsland.PalmLeaf{i}": 4 for i in range(1, 5)}})
    layer_paths(find(stage, "Near"), {"LighthouseIsland": 2, "Reef1": 2, "Reef2": 2,
                                     "LighthouseIsland.FarCliff": 1, "LighthouseIsland.Grass": 2,
                                     "LighthouseIsland.Tower": 3, "LighthouseIsland.Lamp": 4,
                                     "LighthouseIsland.Roof": 5})
    for boat_name in ("BoatLv1", "BoatLv2"):
        boat = find(stage, boat_name)
        layer_paths(boat, {"Wake": 1, "Frog": 4, "Hull": 5, "HullStripe": 6, "Rim": 7, "BoatArtwork": 8,
                          "Frog.Body": 1, "Frog.EyesOpen": 2, "Frog.EyesClosed": 2,
                          "Frog.Look": 2, "Frog.Drink": 3,
                          "Frog.Body.Torso": 1, "Frog.Body.Belly": 2, "Frog.Body.Head": 3,
                          "Frog.Body.LeftEye": 4, "Frog.Body.RightEye": 4,
                          "Frog.Body.LeftFoot": 1, "Frog.Body.RightFoot": 1,
                          "Frog.Body.LeftHand": 5, "Frog.Body.RightHand": 5, "Frog.Body.Smile": 5,
                          "Frog.EyesOpen.LeftWhite": 1, "Frog.EyesOpen.RightWhite": 1,
                          "Frog.EyesOpen.LeftPupil": 2, "Frog.EyesOpen.RightPupil": 2,
                          "Frog.Look.LeftWhite": 1, "Frog.Look.RightWhite": 1,
                          "Frog.Look.LeftPupil": 2, "Frog.Look.RightPupil": 2,
                          "Frog.Drink.Cup": 1, "Frog.Drink.Straw": 2, "Frog.Drink.Hand": 3})
        layer_paths(boat, {"Mast": 2, "Sail": 3, "Flag": 3} if boat_name == "BoatLv2" else {"Oar": 2, "Paddle": 2})
    return stage


def save(root, name):
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(OUT / name, encoding="utf-8", xml_declaration=False)


def make_window():
    root = ET.parse(FRAMEWORK / "WindowTemplate.rbxmx").getroot()
    screen = root.find("Item")
    prop(screen, "string", "Name", "TravelWindow")
    prop(screen, "int", "DisplayOrder", 20)
    panel = find(root, "Panel")
    color(panel, "BackgroundColor3", PAPER)
    header = find(root, "Header")
    udim(header, "Size", 0.9, 0.12)
    title = find(root, "Title")
    color(title, "TextColor3", INK)
    prop(title, "string", "Text", "旅行伙伴")
    close = find(root, "Close")
    color(close, "BackgroundColor3", GREEN)
    prop(close, "string", "Text", "关闭")
    content = find(root, "Content")
    udim(content, "Position", 0.05, 0.26)
    udim(content, "Size", 0.9, 0.69)
    text(panel, "Message", "走到港口、房屋或船只旁，开始你的海岛生活。", 0.05, 0.17, 0.9, 0.075)
    for panel_name in ("Voyage", "Inventory", "Collection", "Upgrade", "Result", "Status"):
        gui(content, "Frame", panel_name, 0, 0, 1, 1, visible=False)

    voyage = find(root, "Voyage")
    text(voyage, "Intro", "港口 · 选择海域与航程", 0, 0, 1, 0.08)
    button(voyage, "Shallow", "浅海", 0, 0.10, 0.48, 0.12)
    button(voyage, "Near", "近海", 0.52, 0.10, 0.48, 0.12)
    text(voyage, "SeaDescription", "平静的海面，适合第一趟旅行。", 0, 0.25, 1, 0.10)
    button(voyage, "Short", "短途", 0, 0.38, 0.48, 0.12)
    button(voyage, "Long", "长途", 0.52, 0.38, 0.48, 0.12)
    text(voyage, "Selected", "正在同步可用航程…", 0, 0.53, 1, 0.23)
    button(voyage, "Start", "消耗补给并出发", 0, 0.82, 1, 0.14)

    inventory = find(root, "Inventory")
    text(inventory, "Summary", "储物箱与背包", 0, 0, 0.60, 0.10)
    button(inventory, "SellAll", "卖出全部商品", 0.63, 0, 0.37, 0.11)
    scroll(inventory, "Rows", 0, 0.15, 1, 0.83)
    templates = item(screen, "Folder", "Templates")
    row = gui(templates, "Frame", "ItemTemplate", 0, 0, 0.98, 0, visible=False, height_px=86)
    prop(row, "BinaryString", "AttributesSerialize", TEMPLATE)
    text(row, "Name", "物品名称", 0.03, 0.07, 0.57, 0.36)
    text(row, "Detail", "数量与固定售价", 0.03, 0.47, 0.57, 0.40)
    button(row, "Action", "出售 1 个", 0.65, 0.15, 0.32, 0.69)

    collection = find(root, "Collection")
    text(collection, "Summary", "航海图鉴 · 物品与旅行明信片", 0, 0, 1, 0.10)
    scroll(collection, "Rows", 0, 0.13, 1, 0.85)
    card = gui(templates, "Frame", "PostcardTemplate", 0, 0, 0.98, 0, visible=False, height_px=110)
    prop(card, "BinaryString", "AttributesSerialize", TEMPLATE)
    card_scene = illustration(card, "Illustration", 0.02, 0.06, 0.30, 0.88)
    card_note = find(card_scene, "PlaceholderNote")
    prop(card_note, "string", "Text", "插画待制作")
    udim(card_note, "Position", 0.04, 0.75)
    udim(card_note, "Size", 0.92, 0.22)
    image_slot(card, "Artwork", 0.02, 0.06, 0.30, 0.88)
    text(card, "Name", "明信片或物品", 0.36, 0.07, 0.61, 0.34)
    text(card, "Detail", "尚未发现", 0.36, 0.47, 0.61, 0.44)

    upgrade = find(root, "Upgrade")
    text(upgrade, "Home", "房屋 Lv.1 · 箱位 3", 0, 0, 1, 0.18)
    text(upgrade, "HomeCost", "施工材料与时间由服务端确认。", 0, 0.18, 1, 0.11)
    button(upgrade, "HomeStart", "升级房屋", 0, 0.32, 1, 0.14)
    text(upgrade, "Ship", "船只 Lv.1", 0, 0.50, 1, 0.15)
    text(upgrade, "ShipCost", "升级船只可解锁近海。", 0, 0.65, 1, 0.11)
    button(upgrade, "ShipStart", "升级船只", 0, 0.81, 1, 0.14)

    result = find(root, "Result")
    illustration(result, "Illustration", 0, 0, 1, 0.38)
    image_slot(result, "Artwork", 0, 0, 1, 0.38)
    text(result, "Summary", "新的旅行收获", 0, 0.42, 1, 0.12)
    text(result, "Detail", "领取归航奖励后，到住宅打开船箱。", 0, 0.56, 1, 0.22)
    button(result, "Inventory", "查看背包与船箱", 0, 0.82, 1, 0.14)

    status = find(root, "Status")
    text(status, "Summary", "正在同步岛屿状态…", 0, 0, 1, 0.20)
    text(status, "Detail", "补给商店 · 固定价格购买航海补给。", 0, 0.22, 1, 0.18)
    button(status, "BuySupply", "购买补给", 0, 0.44, 0.48, 0.13)
    button(status, "ClaimReturn", "领取归航奖励", 0.52, 0.44, 0.48, 0.13)
    button(status, "ClaimRelief", "领取应急补给", 0, 0.62, 0.48, 0.13)
    button(status, "Refresh", "同步状态", 0.52, 0.62, 0.48, 0.13)
    button(status, "Retry", "确认并重试原操作", 0, 0.81, 1, 0.13)
    prop(find(root, "Retry"), "bool", "Visible", False)

    choice_row(voyage, "SeaChoices", find(voyage, "Shallow"), find(voyage, "Near"))
    choice_row(voyage, "DurationChoices", find(voyage, "Short"), find(voyage, "Long"))
    vertical_panel(voyage, [("Intro", 40), ("SeaChoices", 60), ("SeaDescription", 65),
                            ("DurationChoices", 60), ("Selected", 110), ("Start", 60)])
    vertical_panel(upgrade, [("Home", 60), ("HomeCost", 60), ("HomeStart", 60),
                             ("Ship", 60), ("ShipCost", 60), ("ShipStart", 60)])
    choice_row(status, "PrimaryActions", find(status, "BuySupply"), find(status, "ClaimReturn"))
    choice_row(status, "SecondaryActions", find(status, "ClaimRelief"), find(status, "Refresh"))
    vertical_panel(status, [("Summary", 100), ("Detail", 100), ("PrimaryActions", 60),
                            ("SecondaryActions", 60), ("Retry", 60)])
    vertical_panel(result, [("Illustration", 180), ("Artwork", 180), ("Summary", 60),
                            ("Detail", 150), ("Inventory", 60)])
    for panel_name in ("Inventory", "Collection"):
        target = find(root, panel_name)
        udim(find(target, "Summary"), "Size", 0.60 if panel_name == "Inventory" else 1, 0, oy=54)
        udim(find(target, "Rows"), "Position", 0, 0, oy=64)
        udim(find(target, "Rows"), "Size", 1, 1, oy=-64)
    udim(find(inventory, "SellAll"), "Size", 0.37, 0, oy=54)
    save(root, "TravelWindow.rbxmx")


def make_hud():
    root = ET.Element("roblox", version="4")
    screen = item(root, "ScreenGui", "TravelHUD")
    prop(screen, "BinaryString", "AttributesSerialize", TEMPLATE)
    prop(screen, "bool", "Enabled", False)
    prop(screen, "bool", "ResetOnSpawn", False)
    prop(screen, "int", "DisplayOrder", 10)
    prop(screen, "token", "ScreenInsets", 2)
    prop(screen, "bool", "ClipToDeviceSafeArea", True)
    prop(screen, "token", "ZIndexBehavior", 1)
    canvas = gui(screen, "Frame", "Root", 0, 0, 1, 1)
    prop(canvas, "float", "BackgroundTransparency", 1)
    travelling = anchor(gui(canvas, "Frame", "TravelScene", 0.5, 0.52, 0.94, 0.78, visible=False), 0.5, 0.5)
    prop(travelling, "int", "ZIndex", 10)
    prop(travelling, "bool", "Active", True)
    rounded(travelling, 0.03)
    constraint = item(travelling, "UISizeConstraint", "WindowBounds")
    prop(constraint, "Vector2", "MinSize", {"X": 0, "Y": 176})
    prop(constraint, "Vector2", "MaxSize", {"X": 1000, "Y": 680})
    stroke = item(travelling, "UIStroke", "Border")
    color(stroke, "Color", (0.33, 0.53, 0.52))
    prop(stroke, "float", "Thickness", 2)
    title = text(travelling, "Title", "浅海 · 海蛙旅途", 0.03, 0, 0.94, 0)
    udim(title, "Position", 0.03, 0, oy=12)
    udim(title, "Size", 0.94, 0, ox=-132, oy=27)
    progress = text(travelling, "Progress", "距离归航…", 0.03, 0, 0.94, 0)
    udim(progress, "Position", 0.03, 0, oy=42)
    udim(progress, "Size", 0.94, 0, ox=-132, oy=24)
    close = anchor(button(travelling, "Close", "返回岛屿", 0.97, 0, 0, 0), 1, 0)
    udim(close, "Position", 0.97, 0, oy=12)
    udim(close, "Size", 0, 0, ox=124, oy=48)
    rounded(close, 0.14)
    travel_illustration(travelling)
    # Hidden bindings retained while artists replace the previous whitebox.
    image_slot(travelling, "Artwork", 0, 0, 0, 0)
    info = text(travelling, "Information", "", 0, 0, 0, 0)
    prop(info, "bool", "Visible", False)
    layer_paths(travelling, {"Title": 3, "Progress": 3, "Close": 3, "Illustration": 1})
    top = gui(canvas, "Frame", "Top", 0.03, 0.02, 0.94, 0, height_px=60)
    resources = text(top, "Resources", "金币 30 · 补给 3 · 木材 4", 0.03, 0, 0.94, 0, height_px=24)
    udim(resources, "Position", 0.03, 0, oy=6)
    state = text(top, "State", "在岛上 · 房屋 Lv.1 · 船 Lv.1", 0.03, 0, 0.94, 0, height_px=24)
    udim(state, "Position", 0.03, 0, oy=32)
    hint = text(canvas, "Hint", "靠近港口、住宅、船只与商店，使用交互入口。", 0.10, 0, 0.80, 0, PAPER, height_px=40)
    udim(hint, "Position", 0.10, 0, oy=80)
    notice = text(canvas, "Notice", "正在同步岛屿…", 0.10, 0, 0.80, 0, PAPER, height_px=40)
    udim(notice, "Position", 0.10, 0, oy=126)
    watch = anchor(button(canvas, "TravelWatch", "查看海蛙旅途", 0.97, 0, 0.62, 0), 1, 0)
    udim(watch, "Position", 0.97, 0, oy=172)
    udim(watch, "Size", 0.62, 0, oy=48)
    prop(watch, "bool", "Visible", False)
    prop(find(watch, "TouchTarget"), "Vector2", "MaxSize", {"X": 240, "Y": 48})
    rounded(watch, 0.14)
    returned = gui(canvas, "Frame", "ReturnNotice", 0.03, 0, 0.94, 0, visible=False, height_px=80)
    udim(returned, "Position", 0.03, 0, oy=126)
    rounded(returned, 0.10)
    returned_text = text(returned, "Text", "海蛙已归航，回到自己的码头领取收获。", 0.03, 0, 0.94, 0)
    udim(returned_text, "Position", 0.03, 0, oy=12)
    udim(returned_text, "Size", 0.94, 0, ox=-74, oy=56)
    dismiss = anchor(button(returned, "Dismiss", "收起", 0.97, 0.5, 0, 0), 1, 0.5)
    udim(dismiss, "Size", 0, 0, ox=60, oy=48)
    rounded(dismiss, 0.14)
    save(root, "TravelHUD.rbxmx")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--hud-only", action="store_true", help="Preserve TravelWindow and postcard templates exactly.")
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "init.meta.json").write_text('{"className":"Folder","ignoreUnknownInstances":true}\n', encoding="utf-8")
    make_hud()
    if not args.hud_only:
        make_window()
    print("Created native TravelHUD template." if args.hud_only else "Created native TravelHUD and TravelWindow templates.")
