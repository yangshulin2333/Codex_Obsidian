"""Validate native UI resources and client ownership without opening Studio.

Run: python scripts/game/checks/check_travel_ui.py
This is an offline structure check, not a substitute for device testing in Play.
"""
from pathlib import Path
import base64
import json
import re
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[3]
UI = ROOT / "src/ReplicatedStorage/Game/Resources/UI/TravelBuddy"
CLIENT = ROOT / "src/StarterPlayer/StarterPlayerScripts/Client/Game/Controllers/TravelController.lua"


def properties(node):
    return {prop.get("name"): prop for prop in node.find("Properties")}


def child(node, path):
    for name in path.split("."):
        matches = [item for item in node.findall("Item") if properties(item)["Name"].text == name]
        assert len(matches) == 1, f"Missing/duplicate GUI binding path: {path}"
        node = matches[0]
    return node


def template_flag(node):
    data = properties(node).get("AttributesSerialize")
    return data is not None and b"Template\x03\x01" in base64.b64decode(data.text or "")


def animation_flag(node):
    data = properties(node).get("AttributesSerialize")
    return data is not None and b"Animation\x03\x01" in base64.b64decode(data.text or "")


def axis(node, prop_name, scale, offset):
    value = properties(node)[prop_name]
    return float(value.find(scale).text), float(value.find(offset).text)


def native_bounds(node, parent_width, parent_height):
    props = properties(node)
    width_scale, width_offset = axis(node, "Size", "XS", "XO")
    height_scale, height_offset = axis(node, "Size", "YS", "YO")
    width, height = parent_width * width_scale + width_offset, parent_height * height_scale + height_offset
    for constraint in node.findall("Item"):
        if constraint.get("class") == "UISizeConstraint":
            limits = properties(constraint)
            width = min(max(width, float(limits["MinSize"].find("X").text)), float(limits["MaxSize"].find("X").text))
            height = min(max(height, float(limits["MinSize"].find("Y").text)), float(limits["MaxSize"].find("Y").text))
    x_scale, x_offset = axis(node, "Position", "XS", "XO")
    y_scale, y_offset = axis(node, "Position", "YS", "YO")
    anchor = props.get("AnchorPoint")
    anchor_x = float(anchor.find("X").text) if anchor is not None else 0
    anchor_y = float(anchor.find("Y").text) if anchor is not None else 0
    return (parent_width * x_scale + x_offset - width * anchor_x,
            parent_height * y_scale + y_offset - height * anchor_y, width, height)


def check_observation(hud):
    observation = child(hud, "Root.TravelScene")
    for path in ("Root.TravelWatch", "Root.ReturnNotice", "Root.TravelScene"):
        assert properties(child(hud, path))["Visible"].text == "false", "Travel observation and return notice must start hidden"
    for path in ("Root.TravelWatch", "Root.ReturnNotice.Text", "Root.ReturnNotice.Dismiss", "Root.TravelScene.Close"):
        child(hud, path)
    assert properties(child(hud, "Root.TravelScene.Information"))["Visible"].text == "false"
    assert properties(child(hud, "Root.TravelScene.Artwork"))["Visible"].text == "false"
    stage = child(hud, "Root.TravelScene.Illustration")
    assert properties(stage)["ClipsDescendants"].text == "true", "Cloud/wave motion must stay within its illustration"
    def depth(node, path):
        return int(properties(child(node, path))["ZIndex"].text)
    for node in observation.iter("Item"):
        if node.get("class") in ("Frame", "TextLabel", "TextButton", "ImageLabel"):
            assert "ZIndex" in properties(node), "Observation layer order must be explicit, never depend on Rojo sibling order"
    assert max(depth(stage, "Shallow"), depth(stage, "Near")) < min(depth(stage, "BoatLv1"), depth(stage, "BoatLv2"))
    assert max(depth(stage, "BoatLv1"), depth(stage, "BoatLv2")) < depth(stage, "Foreground"), "Boats and frog must render above both backgrounds and below foreground foam"
    for sea in ("Shallow", "Near"):
        child(stage, sea + ".BackgroundArtwork")
        for layer in ("CloudLayer", "WaveLayer"):
            assert animation_flag(child(stage, sea + "." + layer)), "Only dedicated animation roots may move"
    for boat in ("BoatLv1", "BoatLv2"):
        node = child(stage, boat)
        assert animation_flag(node)
        assert any(n.get("class") == "UIAspectRatioConstraint" for n in node.findall("Item")), "Boats must retain shape across phone orientations"
        for part in ("Body", "EyesOpen", "EyesClosed", "Look", "Drink"):
            child(node, "Frog." + part)
        assert depth(node, "Frog.Body") < depth(node, "Frog.EyesOpen") < depth(node, "Frog.Drink")
        assert depth(node, "Frog.EyesOpen.LeftWhite") < depth(node, "Frog.EyesOpen.LeftPupil")
        assert depth(node, "Frog.Look.LeftWhite") < depth(node, "Frog.Look.LeftPupil")
        assert depth(node, "Frog") < depth(node, "Hull") < depth(node, "Rim")
        if boat == "BoatLv2":
            assert depth(node, "Mast") < depth(node, "Sail") < depth(node, "Frog")
        assert any(n.get("class") == "UIAspectRatioConstraint" for n in child(node, "Frog").findall("Item")), "Frog must retain its round native shape"
    # Deterministic native layout check; live simulator remains the visual check.
    for width, height in ((1920, 1022), (319, 508), (566, 261)):
        x, y, panel_width, panel_height = native_bounds(observation, width, height)
        assert x >= 0 and y >= 0 and x + panel_width <= width and y + panel_height <= height
        close = native_bounds(child(observation, "Close"), panel_width, panel_height)
        title = native_bounds(child(observation, "Title"), panel_width, panel_height)
        progress = native_bounds(child(observation, "Progress"), panel_width, panel_height)
        art = native_bounds(stage, panel_width, panel_height)
        assert close[2] >= 44 and close[3] >= 44
        assert title[0] + title[2] <= close[0] and progress[0] + progress[2] <= close[0], "Heading/countdown must not overlap Return to island"
        assert art[1] >= max(close[1] + close[3], progress[1] + progress[3]), "Illustration must leave the native header clear"
        assert art[2] > 0 and art[3] >= 80, "Shortest supported viewport must preserve an illustration"
        top = native_bounds(child(hud, "Root.Top"), width, height)
        resources = native_bounds(child(hud, "Root.Top.Resources"), top[2], top[3])
        state = native_bounds(child(hud, "Root.Top.State"), top[2], top[3])
        hint = native_bounds(child(hud, "Root.Hint"), width, height)
        notice = native_bounds(child(hud, "Root.Notice"), width, height)
        watch = native_bounds(child(hud, "Root.TravelWatch"), width, height)
        returned = native_bounds(child(hud, "Root.ReturnNotice"), width, height)
        assert top[3] == 60 and resources[3] == state[3] == 24, "Island HUD text must not shrink vertically in landscape"
        assert resources[1] + resources[3] <= state[1] and state[1] + state[3] <= top[3]
        assert top[1] + state[1] + state[3] <= hint[1] and hint[1] + hint[3] <= notice[1]
        assert notice[1] + notice[3] <= watch[1], "Travel entry must remain below island notices"
        assert watch[1] + watch[3] <= height and returned[1] + returned[3] <= height


def load(name):
    tree = ET.parse(UI / name).getroot()
    items = list(tree.iter("Item"))
    refs = {item.get("referent") for item in items}
    assert len(refs) == len(items), f"Duplicate XML referents in {name}"
    for ref in tree.iter("Ref"):
        assert ref.text == "null" or ref.text in refs, f"External GUI reference in {name}"
    for item in items:
        names = [properties(n)["Name"].text for n in item.findall("Item")]
        assert len(names) == len(set(names)), f"Duplicate sibling names in {name}"
        assert item.get("class") not in ("Script", "LocalScript", "ModuleScript"), "GUI templates must not contain scripts"
        if item.get("class") in ("UIListLayout", "UIGridLayout"):
            # Studio Enum.SortOrder.LayoutOrder.Value is 2; 1 means deprecated Custom.
            assert properties(item)["SortOrder"].text == "2", "Native layouts must use SortOrder.LayoutOrder=2, never Custom=1"
        if item.get("class") == "TextButton":
            constraints = [n for n in item.findall("Item") if n.get("class") == "UISizeConstraint"]
            tags = properties(item).get("Tags")
            tagged = tags is not None and b"UITouchTarget" in base64.b64decode(tags.text or "")
            direct = any(float(properties(n)["MinSize"].find("X").text) >= 44 and
                         float(properties(n)["MinSize"].find("Y").text) >= 44 for n in constraints)
            assert direct or tagged, f"Button missing native 44px touch target: {names}"
    root = tree.find("Item")
    assert root.get("class") == "ScreenGui"
    assert template_flag(root), f"Missing Template=true on {name}"
    assert properties(root)["Enabled"].text == "false"
    assert properties(root)["ResetOnSpawn"].text == "false"
    return root


def check_bag(window):
    # Verify the native panel remains usable on the shortest phone viewports.
    # The framework window gets its size from native StyleRules, not Panel.Size.
    panel_sizes = []
    for rule in window.iter("Item"):
        if rule.get("class") != "StyleRule":
            continue
        props = properties(rule)
        if props["Selector"].text not in (".UIWindowPanel", "@Portrait >> .UIWindowPanel"):
            continue
        data = base64.b64decode(props["PropertiesSerialize"].text)
        count, name_length = struct.unpack_from("<II", data)
        assert count == 1 and data[8:8 + name_length] == b"Size", "Window size rule must retain its native Size"
        value_offset = 8 + name_length
        assert data[value_offset] == 10, "Window size rule must contain a native UDim2"
        panel_sizes.append(struct.unpack_from("<fifi", data, value_offset + 1))
    assert len(panel_sizes) == 2, "Both native landscape and portrait window sizes must be present"
    bag = child(window, "Root.Panel.Content.Bag")
    bag_props = properties(bag)
    assert bag_props["AutomaticCanvasSize"].text == "2", "Bag content needs a native vertical canvas"
    assert bag_props["ScrollingDirection"].text == "2", "Bag controls must be reachable by vertical scrolling"
    assert bag_props.get("ScrollingEnabled") is None or bag_props["ScrollingEnabled"].text == "true"
    sections = child(bag, "Sections")
    padding = properties(sections)["Padding"]
    assert float(padding.find("S").text) == 0, "Bag rows need stable native spacing on phones"
    gap = float(padding.find("O").text)
    ordered_sections = sorted(
        ((int(properties(node)["LayoutOrder"].text), node)
         for node in bag.findall("Item")
         if node.get("class") in ("Frame", "TextLabel")),
        key=lambda entry: entry[0],
    )
    orders = {properties(node)["Name"].text: order for order, node in ordered_sections}
    assert len(set(orders.values())) == len(orders), "Bag sections need distinct native layout orders"
    assert orders["Plan"] < orders["TravelActions"] < orders["Actions"] < orders["SecondaryActions"] < orders["Info"]
    assert properties(child(bag, "Plan"))["TextWrapped"].text == "true", "Plan text must wrap on narrow phones"
    for width, height in ((1920, 1022), (319, 508), (566, 261)):
        for x_scale, x_offset, y_scale, y_offset in panel_sizes:
            parent_width, parent_height = width * x_scale + x_offset, height * y_scale + y_offset
            for path in ("Root.Panel.Content", "Root.Panel.Content.Bag"):
                _, _, parent_width, parent_height = native_bounds(child(window, path), parent_width, parent_height)
            content_height = 0
            for _, section in ordered_sections:
                assert properties(section)["Visible"].text == "true", "Bag controls must be included in the scroll canvas"
                _, _, section_width, section_height = native_bounds(section, parent_width, parent_height)
                assert 0 < section_width <= parent_width + 0.001 and section_height > 0
                content_height += section_height + gap
            content_height -= gap
            assert content_height > 0
            if height <= 508:
                assert content_height > parent_height, "Small phone views must exercise scrolling to the last Bag controls"
            for row_name, names in (("Actions", ("PackOne", "PackFull")),
                                    ("SecondaryActions", ("UnpackOne", "UnpackAll")),
                                    ("TravelActions", ("Pause", "Resume"))):
                row = child(bag, row_name)
                _, _, row_width, row_height = native_bounds(row, parent_width, parent_height)
                boxes = []
                for name in names:
                    button = child(row, name)
                    assert button.get("class") == "TextButton", "Bag actions must be native buttons"
                    bounds = native_bounds(button, row_width, row_height)
                    x, y, button_width, button_height = bounds
                    assert button_width >= 44 and button_height >= 44, "Bag actions need 44px touch targets"
                    assert x >= 0 and y >= 0 and x + button_width <= row_width + 0.001
                    assert y + button_height <= row_height + 0.001, "Bag buttons must fit their native row"
                    boxes.append(bounds)
                assert boxes[0][0] + boxes[0][2] <= boxes[1][0], "Bag action buttons must not overlap"


def main():
    meta = json.loads((UI / "init.meta.json").read_text(encoding="utf-8"))
    assert meta["className"] == "Folder" and meta["ignoreUnknownInstances"] is True
    window, hud = load("TravelWindow.rbxmx"), load("TravelHUD.rbxmx")
    for path in ("Root.Panel.Message", "Root.Panel.Header.Title", "Root.Panel.Header.Close"):
        child(window, path)
    paths = [
        "Voyage.Intro", "Voyage.SeaChoices.Shallow", "Voyage.SeaChoices.Near",
        "Voyage.DurationChoices.Short", "Voyage.DurationChoices.Long",
        "Voyage.SeaDescription", "Voyage.Selected", "Voyage.Start",
        "Inventory.Rows", "Inventory.Summary", "Inventory.SellAll",
        "Collection.Rows", "Collection.Summary", "Result.Artwork", "Result.Illustration",
        "Result.Summary", "Result.Detail", "Result.Inventory", "Upgrade.Home", "Upgrade.HomeCost",
        "Upgrade.HomeStart", "Upgrade.Ship", "Upgrade.ShipCost", "Upgrade.ShipStart",
        "Status.Summary", "Status.Detail", "Status.PrimaryActions.BuySupply",
        "Status.PrimaryActions.ClaimReturn", "Status.SecondaryActions.ClaimRelief",
        "Status.SecondaryActions.Refresh", "Status.Retry",
        "Bag.Summary", "Bag.Hint", "Bag.Info", "Bag.Actions.PackOne", "Bag.Actions.PackFull",
        "Bag.SecondaryActions.UnpackOne", "Bag.SecondaryActions.UnpackAll",
        "Bag.Plan", "Bag.TravelActions.Pause", "Bag.TravelActions.Resume",
    ]
    for path in paths:
        child(window, "Root.Panel.Content." + path)
    for name in ("Voyage", "Upgrade", "Status", "Result", "Bag"):
        panel = child(window, "Root.Panel.Content." + name)
        assert panel.get("class") == "ScrollingFrame", "Short viewports need native scroll panels"
        assert properties(panel)["AutomaticCanvasSize"].text == "2"
        assert any(n.get("class") == "UIListLayout" for n in panel.findall("Item"))
    check_bag(window)
    for name, paths in (("ItemTemplate", ("Name", "Detail", "Action")),
                        ("PostcardTemplate", ("Name", "Detail", "Illustration", "Artwork"))):
        row = child(window, "Templates." + name)
        assert template_flag(row) and properties(row)["Visible"].text == "false"
        for path in paths:
            child(row, path)
    for path in ("Root.Notice", "Root.Hint", "Root.Top.Resources", "Root.Top.State",
                 "Root.TravelScene.Artwork", "Root.TravelScene.Illustration",
                 "Root.TravelScene.Title", "Root.TravelScene.Progress"):
        child(hud, path)
    check_observation(hud)
    note = child(hud, "Root.TravelScene.Illustration.PlaceholderNote")
    assert properties(note)["Visible"].text == "false", "Travel HUD must not overlap its information with the illustration note"
    for path in ("Root.Panel.Content.Result.Illustration.PlaceholderNote", "Templates.PostcardTemplate.Illustration.PlaceholderNote"):
        assert properties(child(window, path))["Visible"].text == "true", "Result/cards should keep their art placeholder note"
    card_note = child(window, "Templates.PostcardTemplate.Illustration.PlaceholderNote")
    assert properties(card_note)["Text"].text == "插画待制作", "Compact postcard notes need the short caption"
    assert float(properties(card_note)["Size"].find("YS").text) >= 0.22, "Compact postcard note height must fit its native minimum text size"
    for root in (hud, window):
        for image in root.iter("Item"):
            if image.get("class") == "ImageLabel":
                value = properties(image).get("ImageContent")
                assert value is not None and value.find("null") is not None, "Placeholder images must have empty native content"
    code = CLIENT.read_text(encoding="utf-8")
    assert "StartJourney" not in code, "Client must not send direct companion dispatch requests"
    assert 'self:_open("Voyage")' not in code, "Legacy Voyage selection panel must remain unused"
    assert properties(child(window, "Root.Panel.Content.Voyage"))["Visible"].text == "false"
    for contract in ("PauseTravel", "ResumeTravel", "state.Plan.ReadyAt", "state.ManualPaused", "_can_control_travel"):
        assert contract in code, f"Missing autonomous travel view contract: {contract}"
    for reason in ("NO_PACKED_SUPPLIES", "MANUAL_PAUSED", "SHIP_UPGRADING", "RESTING", "NOT_DOCKED",
                   "CONTAINER_FULL", "JOURNEY_ACTIVE"):
        assert reason in code, f"Missing server waiting reason: {reason}"
    for contract in ("MarkReturnRead", "state.LatestReturn", "state.HasUnreadReturn", "_focus_companion", "CameraSubject"):
        assert contract in code, f"Missing automatic return / companion view: {contract}"
    assert 'self:_request("ClaimReturn"' not in code, "Client cannot send a retired reward claim"
    assert "Instance.new" not in code, "Runtime must not generate GUI structure"
    forbidden = r"\.(?:Position|Size|AnchorPoint|LayoutOrder|BackgroundColor3|ZIndex)\s*="
    assert not re.search(forbidden, code), "Runtime must not overwrite Studio layout"
    for api in ("ResourceClient:Clone", "ButtonBinding.Bind", "ListBinding.Bind", "WindowNavigation.new"):
        assert api in code, f"Missing framework UI API: {api}"
    for safety in ("ExpectedRevision", "GenerateGUID", "REQUEST_TIMEOUT", "DATA_UPDATE_FAILED",
                   "state.Revision < self._state.Revision", "table.clone(pending.Payload)", "_viewToken"):
        assert safety in code, f"Missing request/ownership guard: {safety}"
    print("Travel UI passed: native roots, paths, style references, touch targets, scroll layouts, autonomous plan controls, placeholders and client ownership.")


if __name__ == "__main__":
    main()
