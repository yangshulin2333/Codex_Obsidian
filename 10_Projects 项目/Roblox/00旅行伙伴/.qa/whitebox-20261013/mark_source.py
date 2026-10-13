from pathlib import Path
import base64
import struct
import xml.etree.ElementTree as ET
import os

path = Path('F:/HunyueRoblox/TravelBuddy/src/Workspace/TravelIsland.rbxmx')
tree = ET.parse(path)
fixture = next(i for i in tree.iter('Item') if i.find("Properties/string[@name='Name']") is not None and i.find("Properties/string[@name='Name']").text == 'SampleFixtures')
attrs = {'SceneStage': 'PersonalPlotSample', 'SceneVersion': 'v1'}
binary = struct.pack('<I', len(attrs))
for key, value in attrs.items():
    a, b = key.encode(), value.encode()
    binary += struct.pack('<I', len(a)) + a + bytes([2]) + struct.pack('<I', len(b)) + b
fixture.find("Properties/BinaryString[@name='AttributesSerialize']").text = base64.b64encode(binary).decode()
ET.indent(tree, space='  ')
temporary = path.with_suffix('.whitebox-tmp')
tree.write(temporary, encoding='utf-8', xml_declaration=False)
os.replace(temporary, path)
print('SOURCE_FIXTURE_MARKED')
