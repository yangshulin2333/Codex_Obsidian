from pathlib import Path
import os
import xml.etree.ElementTree as ET

path = Path('F:/HunyueRoblox/TravelBuddy/src/Workspace/TravelIsland.rbxmx')
tree = ET.parse(path)
fixtures = next(i for i in tree.iter('Item') if i.find("Properties/string[@name='Name']") is not None and i.find("Properties/string[@name='Name']").text == 'SampleFixtures')
for child in list(fixtures.findall('Item')):
    name = child.find("Properties/string[@name='Name']").text
    if name == 'CompanionRestAnchor':
        fixtures.remove(child)
    elif name == 'CompanionPrepareAnchor':
        child.find("Properties/CoordinateFrame[@name='CFrame']/Z").text = '-5.2'
ET.indent(tree, space='  ')
temporary = path.with_suffix('.whitebox-tmp')
tree.write(temporary, encoding='utf-8', xml_declaration=False)
os.replace(temporary, path)
print('PREP_CLEARANCE_INCREASED; REST_USES_HOME_FROG_ANCHOR')
