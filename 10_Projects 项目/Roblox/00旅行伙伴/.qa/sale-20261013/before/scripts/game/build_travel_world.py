"""生成 TravelBuddy 原生白模资源；只在开发期执行，不进入 Roblox 运行时。

Studio 可直接编辑生成的 rbxmx。重新执行会覆盖这些明确的生成文件，
不会读写手工 Place、Framework 或项目映射。
"""

from __future__ import annotations

import base64
import math
from pathlib import Path
import struct
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
RESOURCES = ROOT / "src/ServerStorage/Game/Resources/Models/TravelBuddy"
WORLD = ROOT / "src/Workspace/TravelIsland.rbxmx"
NEXT_ID = 0

GRASS = (141, 173, 113)
WOOD = (167, 123, 83)
PALE_WOOD = (208, 171, 116)
CREAM = (238, 228, 202)
BLUE = (138, 194, 205)
DARK = (70, 83, 79)
WHITE = (245, 241, 227)


def property_of(item, kind, name, value=None):
    properties = item.find("Properties")
    prop = next((child for child in properties if child.attrib.get("name") == name), None)
    if prop is None:
        prop = ET.SubElement(properties, kind, name=name)
    if value is not None:
        prop.text = str(value)
    return prop


def item(parent, class_name, name, attributes=None):
    global NEXT_ID
    NEXT_ID += 1
    node = ET.SubElement(parent, "Item", {"class": class_name, "referent": f"RBX{NEXT_ID}"})
    ET.SubElement(node, "Properties")
    property_of(node, "string", "Name", name)
    property_of(node, "bool", "Archivable", "true")
    if attributes:
        binary = struct.pack("<I", len(attributes))
        for key, value in attributes.items():
            encoded = key.encode("utf-8")
            binary += struct.pack("<I", len(encoded)) + encoded
            if isinstance(value, bool):
                binary += bytes((3, int(value)))
            elif isinstance(value, str):
                encoded_value = value.encode("utf-8")
                binary += bytes((2,)) + struct.pack("<I", len(encoded_value)) + encoded_value
            else:
                raise TypeError(value)
        property_of(node, "BinaryString", "AttributesSerialize", base64.b64encode(binary).decode("ascii"))
    return node


def vector(node, kind, name, values):
    prop = property_of(node, kind, name)
    for axis, value in zip(("X", "Y", "Z"), values):
        ET.SubElement(prop, axis).text = str(value)
    return prop


def cframe(node, name, position, yaw=0):
    prop = property_of(node, "CoordinateFrame", name)
    cosine, sine = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
    for key, value in zip(
        ("X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"),
        (*position, cosine, 0, sine, 0, 1, 0, -sine, 0, cosine),
    ):
        ET.SubElement(prop, key).text = str(round(value, 6))


def part(parent, name, position, size, color=WHITE, *, shape=1, material=256, transparent=0, collide=True, yaw=0):
    node = item(parent, "Part", name)
    property_of(node, "bool", "Anchored", "true")
    property_of(node, "bool", "CanCollide", str(collide).lower())
    property_of(node, "bool", "CanTouch", "false")
    property_of(node, "bool", "CanQuery", str(transparent < 1).lower())
    property_of(node, "token", "shape", shape)
    property_of(node, "token", "Material", material)
    property_of(node, "float", "Transparency", transparent)
    property_of(node, "token", "TopSurface", 0)
    property_of(node, "token", "BottomSurface", 0)
    property_of(node, "Color3uint8", "Color3uint8", color[0] * 65536 + color[1] * 256 + color[2])
    vector(node, "Vector3", "size", size)
    cframe(node, "CFrame", position, yaw)
    return node


def anchor(parent, name, position):
    return part(parent, name, position, (0.1, 0.1, 0.1), transparent=1, collide=False)


def prompt(parent, action, label, subject, *, enabled=True, keyboard=101, gamepad=None):
    node = item(parent, "ProximityPrompt", action + "Prompt", {"TravelAction": action})
    property_of(node, "string", "ActionText", label)
    property_of(node, "string", "ObjectText", subject)
    property_of(node, "bool", "Enabled", str(enabled).lower())
    property_of(node, "bool", "RequiresLineOfSight", "false")
    property_of(node, "float", "MaxActivationDistance", 12)
    property_of(node, "float", "HoldDuration", 0.1)
    property_of(node, "token", "KeyboardKeyCode", keyboard)
    if gamepad is not None:
        property_of(node, "token", "GamepadKeyCode", gamepad)
    return node


def sign(parent, name, position, text, width=12, height=3.5, color=DARK):
    board = part(parent, name, position, (width, height, 0.35), color, collide=False)
    gui = item(board, "SurfaceGui", "SignGui")
    property_of(gui, "token", "Face", 2)  # Back: 面向港口的 +Z 方向。
    property_of(gui, "bool", "AlwaysOnTop", "false")
    property_of(gui, "float", "PixelsPerStud", 40)
    property_of(gui, "token", "SizingMode", 1)
    label = item(gui, "TextLabel", "Label")
    property_of(label, "string", "Text", text)
    property_of(label, "bool", "TextScaled", "true")
    property_of(label, "bool", "TextWrapped", "true")
    property_of(label, "bool", "AutoLocalize", "false")
    property_of(label, "float", "BackgroundTransparency", 1)
    property_of(label, "token", "Font", 20)
    text_color = property_of(label, "Color3", "TextColor3")
    for axis, value in zip(("R", "G", "B"), (1, 1, 1)):
        ET.SubElement(text_color, axis).text = str(value)
    size = property_of(label, "UDim2", "Size")
    for key, value in (("XS", 1), ("XO", 0), ("YS", 1), ("YO", 0)):
        ET.SubElement(size, key).text = str(value)
    return board


def model(name, *, template=False):
    tree = ET.Element("roblox", version="4")
    node = item(tree, "Model", name, {"Template": True} if template else None)
    root = anchor(node, "Root", (0, 0, 0))
    property_of(node, "Ref", "PrimaryPart", root.attrib["referent"])
    return tree, node


def save(tree, destination):
    destination.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(tree, space="  ")
    ET.ElementTree(tree).write(destination, encoding="utf-8", xml_declaration=False)


def house(level):
    tree, root = model(f"HomeLv{level}", template=True)
    width, depth = (16, 13) if level == 1 else (20, 15)
    part(root, "Foundation", (0, 0.45, 0), (width + 1, 0.9, depth + 1), (179, 178, 160), material=816)
    part(root, "House", (0, 4, 0), (width, 7, depth), CREAM)
    part(root, "RoofBase", (0, 8, 0), (width + 2, 1, depth + 2), (197, 119, 95))
    part(root, "RoofTop", (0, 9, 0), (width - 2, 1, depth + 1), (208, 139, 111))
    part(root, "Door", (0, 2.8, depth / 2 + 0.1), (3.2, 4.8, 0.25), WOOD, collide=False)
    part(root, "WindowLeft", (-5.3, 4, depth / 2 + 0.16), (3.3, 2.8, 0.25), BLUE, collide=False)
    part(root, "WindowRight", (5.3, 4, depth / 2 + 0.16), (3.3, 2.8, 0.25), BLUE, collide=False)
    part(root, "Porch", (0, 0.55, depth / 2 + 2), (8, 1.1, 4), PALE_WOOD)
    part(root, "Step", (0, 0.25, depth / 2 + 4), (6, 0.5, 1), PALE_WOOD)
    if level == 2:
        for x in (-3.6, 3.6):
            part(root, f"PorchPost{x}", (x, 3, depth / 2 + 3), (0.45, 5, 0.45), WHITE)
        part(root, "PorchCanopy", (0, 5.75, depth / 2 + 2.5), (8.7, 0.6, 4.5), (197, 119, 95))
        part(root, "Chimney", (-5, 10, -2), (2, 3, 2), (158, 153, 145))
    sign(root, "HomeSign", (0, 6.9, depth / 2 + 0.35), f"旅行小屋 Lv.{level}\n箱位 {'3' if level == 1 else '6'}", 9, 1.7)
    control = anchor(root, "HomeControl", (0, 3, depth / 2 + 3))
    prompt(control, "HomeUpgrade", "查看房屋升级", "旅行小屋")
    part(root, "FrogSeat", (6.1, 0.65, depth / 2 + 3.5), (4, 1.3, 3), (184, 184, 164), material=816)
    anchor(root, "FrogAnchor", (6.1, 1.3, depth / 2 + 3.5))
    marker = sign(root, "ConstructionSign", (0, 3, depth / 2 + 4.8), "施工中", 6, 2, (191, 149, 73))
    property_of(marker, "float", "Transparency", 1)
    property_of(marker.find("Item[@class='SurfaceGui']"), "bool", "Enabled", "false")
    save(tree, RESOURCES / f"HomeLv{level}.rbxmx")


def ship(level):
    tree, root = model(f"ShipLv{level}", template=True)
    part(root, "Hull", (0, 0.25, 0), (10, 1.6, 15), WOOD)
    part(root, "Deck", (0, 1.15, 0), (8.8, 0.3, 13.5), PALE_WOOD)
    for side in (-1, 1):
        part(root, f"Side{side}", (side * 4.7, 1.4, 0), (0.6, 1.8, 14.5), WOOD)
    part(root, "Bow", (0, 1.2, 7.15), (9, 1.2, 0.6), WOOD)
    part(root, "Stern", (0, 1.2, -7.15), (9, 1.2, 0.6), WOOD)
    part(root, "Bench", (0, 1.8, -2), (8.5, 0.5, 1.8), (184, 144, 98))
    part(root, "Baggage", (2, 2, -4.5), (2.1, 1.7, 2.1), (163, 169, 135), collide=False)
    if level == 2:
        part(root, "Mast", (0, 6, 2), (0.4, 10, 0.4), WOOD, collide=False)
        part(root, "Sail", (0, 7.2, 2.3), (6.5, 5.7, 0.15), WHITE, collide=False)
        part(root, "SailStripe", (0, 7.2, 2.4), (6.5, 0.6, 0.12), BLUE, collide=False)
        part(root, "MastCap", (0, 11.3, 2), (0.8, 0.4, 0.8), (220, 176, 95), collide=False)
    anchor(root, "FrogAnchor", (0, 2.1, -1.8))
    control = anchor(root, "ShipControl", (0, 3, -5))
    prompt(control, "Voyage", "选择旅行海域", "旅行船", gamepad=1000)  # E / ButtonX
    prompt(control, "ShipUpgrade", "查看船只升级", "旅行船", keyboard=102, gamepad=1001)  # F / ButtonY
    prompt(control, "ClaimReturn", "领取归航收获", "蛙伙伴已归来", enabled=False, gamepad=1000)
    sign(root, "ShipSign", (0, 3, -6.8), f"旅行船 Lv.{level}", 7, 1.4)
    marker = sign(root, "ConstructionSign", (0, 4, -7.4), "船只施工中", 7, 2, (191, 149, 73))
    property_of(marker, "float", "Transparency", 1)
    property_of(marker.find("Item[@class='SurfaceGui']"), "bool", "Enabled", "false")
    save(tree, RESOURCES / f"ShipLv{level}.rbxmx")


def frog():
    tree, root = model("Frog", template=True)
    green, light = (122, 178, 103), (194, 208, 144)
    part(root, "Body", (0, 1.35, 0), (2.8, 2.5, 2.1), green, shape=0, collide=False)
    part(root, "Belly", (0, 1.25, 0.8), (1.9, 1.8, 0.45), light, shape=0, collide=False)
    for side in (-1, 1):
        part(root, f"EyeGreen{side}", (side * 0.8, 2.65, 0.45), (1.0, 1.0, 1.0), green, shape=0, collide=False)
        part(root, f"EyeWhite{side}", (side * 0.8, 2.7, 0.84), (0.72, 0.72, 0.22), WHITE, shape=0, collide=False)
        part(root, f"Pupil{side}", (side * 0.8, 2.72, 0.98), (0.31, 0.36, 0.12), DARK, shape=0, collide=False)
        part(root, f"Foot{side}", (side * 0.95, 0.25, 0.6), (1.3, 0.45, 1.5), green, shape=0, collide=False)
        part(root, f"Arm{side}", (side * 1.3, 1.2, 0.25), (0.55, 1.3, 0.6), green, shape=0, collide=False)
    part(root, "Mouth", (0, 2.1, 1.01), (0.9, 0.11, 0.1), DARK, collide=False)
    part(root, "Scarf", (0, 1.9, 0.9), (2.3, 0.35, 0.4), (225, 149, 100), collide=False)
    part(root, "Backpack", (0, 1.4, -1), (1.8, 1.7, 0.8), PALE_WOOD, collide=False)
    save(tree, RESOURCES / "Frog.rbxmx")


def container():
    tree, root = model("Container", template=True)
    chest = part(root, "Chest", (0, 1.3, 0), (4.2, 2.6, 3.3), WOOD)
    part(root, "Lid", (0, 2.75, 0), (4.5, 0.35, 3.6), PALE_WOOD)
    for x in (-1.4, 1.4):
        part(root, f"Strap{x}", (x, 1.4, 1.7), (0.3, 2.8, 0.18), DARK, collide=False)
    part(root, "Lock", (0, 1.9, 1.85), (0.75, 0.7, 0.35), (212, 181, 95), collide=False)
    sign(root, "ContainerSign", (0, 3.5, 0), "旅行箱", 4.6, 1.1)
    prompt(chest, "OpenContainer", "打开旅行箱", "未开封旅行箱")
    save(tree, RESOURCES / "Container.rbxmx")


def runtime():
    tree = ET.Element("roblox", version="4")
    item(tree, "Folder", "PlotRuntime", {"Template": True})
    save(tree, RESOURCES / "PlotRuntime.rbxmx")


def island():
    tree, root = model("TravelIsland")
    ground = item(root, "Folder", "Ground")
    part(ground, "IslandBase", (0, -3, 1), (166, 8, 87), (187, 173, 129), material=1296)
    part(ground, "GrassTop", (0, 1.2, -3), (160, 1.6, 75), GRASS, material=1280)
    part(ground, "HarborSand", (0, 1.4, 34), (160, 1.2, 14), (223, 205, 157), material=1296)
    part(ground, "Water", (0, -0.1, 140), (600, 1.4, 200), (109, 174, 197), material=272, transparent=0.22, collide=False)
    part(ground, "AccessPath", (0, 2.02, 16), (155, 0.12, 5), (219, 208, 178), material=816)
    part(ground, "HarborPlaza", (0, 2.04, 29), (63, 0.15, 20), (213, 200, 171), material=816)
    part(ground, "Boardwalk", (0, 2.25, 42), (160, 0.5, 7), PALE_WOOD, material=512)
    plots = item(root, "Folder", "Plots")
    decor = item(root, "Folder", "Decor")
    for index, x in enumerate((-54, -18, 18, 54), 1):
        plot = item(plots, "Folder", f"Plot{index}")
        anchor(plot, "HomeAnchor", (x, 2.04, -7))
        anchor(plot, "ShipAnchor", (x, 2.1, 67.5))
        anchor(plot, "SpawnAnchor", (x, 5.1, 16))
        anchor(plot, "DepartureEnd", (x, 2.1, 164))
        slots = item(plot, "Folder", "ContainerSlots")
        for slot, (offset_x, offset_z) in enumerate(((-10, 6), (-10, 11), (-10, 16), (10, 6), (10, 11), (10, 16)), 1):
            anchor(slots, f"Slot{slot}", (x + offset_x, 2.04, offset_z))
        part(ground, f"Dock{index}", (x, 2.35, 50), (14, 0.7, 18), PALE_WOOD, material=512)
        for offset in (-6.5, 6.5):
            part(decor, f"DockPost{index}_{offset}", (x + offset, 2, 57), (0.8, 5, 0.8), WOOD)
        part(decor, f"DockEndRail{index}", (x, 3.7, 59), (14, 1.8, 0.5), WOOD)
        sign(decor, f"PlotSign{index}", (x, 3.9, 20), f"{index} 号旅行家\n空闲地块", 12, 2.8)
        for offset in (-14, 14):
            part(decor, f"TreeTrunk{index}_{offset}", (x + offset, 4, -23), (1.4, 5, 1.4), WOOD)
            part(decor, f"TreeCrown{index}_{offset}", (x + offset, 8, -23), (7, 7, 7), (99, 142, 91), shape=0, collide=False)
        part(decor, f"BackFence{index}", (x, 3.1, -28), (30, 1.8, 0.45), PALE_WOOD)
        for offset in (-13, 13):
            part(decor, f"FlowerBed{index}_{offset}", (x + offset, 2.3, -13), (3, 0.5, 5), (145, 124, 93))
            for flower in (-1, 1):
                part(decor, f"Flower{index}_{offset}_{flower}", (x + offset, 2.9, -13 + flower), (0.8, 0.7, 0.8), (228, 188, 148), shape=0, collide=False)
    hub = item(root, "Folder", "Hub")
    for name, x, action, text in (
        ("Shop", -23, "Shop", "港口商店"),
        ("Inventory", 23, "Inventory", "旅行背包"),
        ("Collection", 0, "Collection", "旅行图鉴"),
    ):
        stand = part(hub, name + "Anchor", (x, 3.2, 29), (7, 2.4, 4), WHITE)
        prompt(stand, action, "查看" + text, text)
        sign(hub, name + "Sign", (x, 6, 27.2), text, 9, 2.3)
    auction = item(hub, "Model", "AuctionCounter")
    part(auction, "Counter", (0, 3.2, 36), (12, 2.4, 3), WHITE)
    sign(auction, "AuctionSign", (0, 5.8, 37), "拍卖 / 收购台\n白模预留", 12, 2.3, (150, 159, 160))
    sign(hub, "HarborTitle", (0, 9, 23.5), "旅行蛙 · 四人共享港口", 25, 2.5)
    sign(hub, "Guide", (-39, 5.6, 35), "自己的小屋与船位\n旅行 → 归航 → 领取 → 开箱", 19, 3.5)
    save(tree, WORLD)


def main():
    RESOURCES.mkdir(parents=True, exist_ok=True)
    meta = '{\n  "className": "Folder",\n  "ignoreUnknownInstances": true\n}\n'
    (RESOURCES.parent / "init.meta.json").write_text(meta, encoding="utf-8")
    (RESOURCES / "init.meta.json").write_text(meta, encoding="utf-8")
    for level in (1, 2):
        house(level)
        ship(level)
    frog()
    container()
    runtime()
    island()
    print("TRAVEL_WORLD_RESOURCES_OK: 7 templates + editable TravelIsland")


if __name__ == "__main__":
    main()
