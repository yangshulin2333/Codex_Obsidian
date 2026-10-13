from pathlib import Path
import os
import xml.etree.ElementTree as ET
path=Path('F:/HunyueRoblox/TravelBuddy/src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx')
tree=ET.parse(path)
def at(node,path):
    for name in path.split('.'):
        node=next(i for i in node.findall('Item') if i.find("Properties/string[@name='Name']").text==name)
    return node
bag=at(tree.getroot().find('Item'),'Root.Panel.Content.Bag')
for name,order in [('TravelActions',3),('Actions',4),('SecondaryActions',5)]:
    at(bag,name).find("Properties/int[@name='LayoutOrder']").text=str(order)
ET.indent(tree,space='  ');temp=path.with_suffix('.autonomy-tmp');tree.write(temp,encoding='utf-8',xml_declaration=False);os.replace(temp,path)
print('PAUSE_RESUME_AFTER_PLAN')
