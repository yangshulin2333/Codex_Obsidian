from pathlib import Path
import xml.etree.ElementTree as ET
import os
path=Path('F:/HunyueRoblox/TravelBuddy/src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx')
tree=ET.parse(path)
def at(node,path):
    for name in path.split('.'):
        node=next(i for i in node.findall('Item') if i.find("Properties/string[@name='Name']").text==name)
    return node
info=at(tree.getroot().find('Item'),'Root.Panel.Content.Bag.Info')
used={n.attrib['referent'] for n in tree.iter('Item')}
next_id=1000
for node in info.iter('Item'):
    while f'RBX{next_id}' in used:next_id+=1
    node.set('referent',f'RBX{next_id}');used.add(f'RBX{next_id}');next_id+=1
refs=[n.attrib['referent'] for n in tree.iter('Item')]
assert len(refs)==len(set(refs))
ET.indent(tree,space='  ');tmp=path.with_suffix('.bag-tmp');tree.write(tmp,encoding='utf-8',xml_declaration=False);os.replace(tmp,path)
print('INFO_REFERENTS_UNIQUE')
