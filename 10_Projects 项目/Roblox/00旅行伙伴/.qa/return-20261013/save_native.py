from pathlib import Path
import xml.etree.ElementTree as ET

repo = Path('F:/HunyueRoblox/TravelBuddy')
models = repo / 'src/ServerStorage/Game/Resources/Models/TravelBuddy'
ui = repo / 'src/ReplicatedStorage/Game/Resources/UI/TravelBuddy'

def prop(parent, kind, name, value=None):
    node = ET.SubElement(parent, kind, name=name)
    if value is not None:
        node.text = str(value)
    return node

def udim2(parent, name, xs, xo, ys, yo):
    node = prop(parent, 'UDim2', name)
    for key, value in (('XS', xs), ('XO', xo), ('YS', ys), ('YO', yo)):
        ET.SubElement(node, key).text = str(value)

def child(parent, path):
    for name in path.split('.'):
        matches = [n for n in parent.findall('Item') if n.find('Properties/string[@name="Name"]').text == name]
        assert len(matches) == 1, path
        parent = matches[0]
    return parent

path = models / 'Frog.rbxmx'
tree = ET.parse(path)
root = child(tree.getroot().find('Item'), 'Root')
assert not any(n.find('Properties/string[@name="Name"]').text == 'CompanionTag' for n in root.findall('Item'))
# Exact native properties authored and checked in Studio Edit this stage.
tag = ET.SubElement(root, 'Item', {'class': 'BillboardGui', 'referent': 'ReturnCompanionTag'})
p = ET.SubElement(tag, 'Properties')
prop(p, 'string', 'Name', 'CompanionTag')
prop(p, 'bool', 'Archivable', 'true')
prop(p, 'bool', 'AlwaysOnTop', 'true')
prop(p, 'bool', 'Enabled', 'true')
prop(p, 'float', 'LightInfluence', 0)
prop(p, 'float', 'MaxDistance', 80)
udim2(p, 'Size', 0, 200, 0, 36)
offset = prop(p, 'Vector3', 'StudsOffsetWorldSpace')
for key, value in (('X', 0), ('Y', 4), ('Z', 0)):
    ET.SubElement(offset, key).text = str(value)
label = ET.SubElement(tag, 'Item', {'class': 'TextLabel', 'referent': 'ReturnCompanionLabel'})
p = ET.SubElement(label, 'Properties')
prop(p, 'string', 'Name', 'Label')
prop(p, 'bool', 'Archivable', 'true')
udim2(p, 'Size', 1, 0, 1, 0)
prop(p, 'Color3uint8', 'BackgroundColor3', (30 << 16) | (73 << 8) | 63)
prop(p, 'float', 'BackgroundTransparency', 0.15)
prop(p, 'int', 'BorderSizePixel', 0)
prop(p, 'Color3uint8', 'TextColor3', (250 << 16) | (247 << 8) | 230)
prop(p, 'string', 'Text', '伙伴')
prop(p, 'token', 'Font', 19)
prop(p, 'float', 'TextSize', 16)
prop(p, 'bool', 'TextWrapped', 'true')
corner = ET.SubElement(label, 'Item', {'class': 'UICorner', 'referent': 'ReturnCompanionCorner'})
p = ET.SubElement(corner, 'Properties')
prop(p, 'string', 'Name', 'UICorner')
prop(p, 'bool', 'Archivable', 'true')
radius = prop(p, 'UDim', 'CornerRadius')
ET.SubElement(radius, 'S').text = '0'
ET.SubElement(radius, 'O').text = '8'
ET.indent(tree, space='  ')
tree.write(path, encoding='utf-8', xml_declaration=False)

for filename, changes in {
    'TravelHUD.rbxmx': {'Root.TravelWatch': '查看伙伴', 'Root.ReturnNotice.Dismiss': '查看'},
    'TravelWindow.rbxmx': {'Root.Panel.Content.Status.PrimaryActions.ClaimReturn': '查看最近收获'},
}.items():
    path = ui / filename
    tree = ET.parse(path)
    for nodepath, text in changes.items():
        node = child(tree.getroot().find('Item'), nodepath)
        node.find('Properties/string[@name="Text"]').text = text
    ET.indent(tree, space='  ')
    tree.write(path, encoding='utf-8', xml_declaration=False)
print('NATIVE_SAVED: companion tag and read-only harvest labels')
