from pathlib import Path
import importlib.util
import json
import os
import sys
import xml.etree.ElementTree as ET

sys.dont_write_bytecode = True
qa = Path(__file__).resolve().parent
repo = Path('F:/HunyueRoblox/TravelBuddy')
result = json.loads((qa / 'studio_delta.json').read_text(encoding='utf-8'))
assert not result.get('isError'), result
delta = json.loads(next(c['text'] for c in result['content'] if c['type'] == 'text'))
spec = importlib.util.spec_from_file_location('native_helpers', repo / 'scripts/game/build_travel_world.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)

def node_at(root, path):
    node = root
    for name in path.split('.'):
        node = next(i for i in node.findall('Item') if i.find("Properties/string[@name='Name']").text == name)
    return node

def set_frame(node, values):
    prop = helper.property_of(node, 'CoordinateFrame', 'CFrame')
    prop.clear()
    prop.set('name', 'CFrame')
    for axis, value in zip(('X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'), values):
        ET.SubElement(prop, axis).text = str(value)

def color(node, name, values):
    prop = helper.property_of(node, 'Color3', name)
    for axis, value in zip(('R','G','B'), values):
        ET.SubElement(prop, axis).text = str(value)

def add_node(parent, data):
    node = helper.item(parent, data['class'], data['name'], data['attrs'])
    if data['class'] == 'Part':
        set_frame(node, data['pos'])
        helper.vector(node, 'Vector3', 'size', data['size'])
        color(node, 'Color', data['color'])
        for name, value in [('Anchored', True), ('CanCollide', data['collide']), ('CanTouch', data['touch']), ('CanQuery', data['query'])]:
            helper.property_of(node, 'bool', name, str(value).lower())
        for name, value in [('shape',1), ('Material',data['material']), ('TopSurface',0), ('BottomSurface',0)]:
            helper.property_of(node, 'token', name, value)
        helper.property_of(node, 'float', 'Transparency', data['transparency'])
    elif data['class'] == 'SurfaceGui':
        helper.property_of(node, 'token', 'Face', data['face'])
        helper.property_of(node, 'token', 'SizingMode', data['sizing'])
        helper.property_of(node, 'float', 'PixelsPerStud', data['pixels'])
        helper.property_of(node, 'bool', 'AlwaysOnTop', 'false')
    elif data['class'] == 'TextLabel':
        helper.property_of(node, 'string', 'Text', data['text'])
        helper.property_of(node, 'float', 'BackgroundTransparency', 1)
        helper.property_of(node, 'token', 'Font', data['font'])
        for name, value in [('TextScaled',True), ('TextWrapped',True), ('AutoLocalize',False)]:
            helper.property_of(node, 'bool', name, str(value).lower())
        color(node, 'TextColor3', data['textColor'])
        prop = helper.property_of(node, 'UDim2', 'Size')
        for axis, value in [('XS',1),('XO',0),('YS',1),('YO',0)]:
            ET.SubElement(prop, axis).text = str(value)
    else:
        assert data['class'] == 'Folder', data['class']
    for child in data['children']:
        add_node(node, child)
    return node

for key, relative in [('world','src/Workspace/TravelIsland.rbxmx'), ('home1','src/ServerStorage/Game/Resources/Models/TravelBuddy/HomeLv1.rbxmx'), ('home2','src/ServerStorage/Game/Resources/Models/TravelBuddy/HomeLv2.rbxmx')]:
    path = repo / relative
    baseline = qa / 'before' / path.name
    assert path.read_bytes() == baseline.read_bytes(), 'Source changed since snapshot: ' + str(path)
    tree = ET.parse(path)
    root = tree.getroot().find('Item')
    helper.NEXT_ID = max(int(i.attrib['referent'][3:]) for i in tree.iter('Item'))
    for name, frame in delta[key].items():
        set_frame(node_at(root, name), frame)
    if key == 'world':
        add_node(node_at(root, 'Plots.Plot1'), delta['new'])
    ET.indent(tree, space='  ')
    temporary = path.with_suffix('.whitebox-tmp')
    tree.write(temporary, encoding='utf-8', xml_declaration=False)
    os.replace(temporary, path)
    print('NATIVE_SAVED', path.name)
