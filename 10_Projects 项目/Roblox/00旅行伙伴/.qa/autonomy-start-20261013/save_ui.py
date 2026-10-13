from pathlib import Path
from copy import deepcopy
import base64
import json
import os
import struct
import xml.etree.ElementTree as ET

qa=Path(__file__).resolve().parent
repo=Path('F:/HunyueRoblox/TravelBuddy')
raw=json.loads((qa/'studio_ui.json').read_text(encoding='utf-8'))
assert not raw.get('isError'),raw
spec=json.loads(next(c['text'] for c in raw['content'] if c['type']=='text'))
def at(node,path):
    for name in path.split('.'):
        node=next(i for i in node.findall('Item') if i.find("Properties/string[@name='Name']").text==name)
    return node
def prop(node,kind,name,value):
    props=node.find('Properties');p=next((p for p in props if p.get('name')==name),None)
    if p is None:p=ET.SubElement(props,kind,name=name)
    p.text=str(value).lower() if isinstance(value,bool) else str(value)
def mark(node):
    key=b'AutonomyUiNative';binary=struct.pack('<I',1)+struct.pack('<I',len(key))+key+bytes([3,1])
    prop(node,'BinaryString','AttributesSerialize',base64.b64encode(binary).decode())
def save(tree,path):
    ET.indent(tree,space='  ');temp=path.with_suffix('.autonomy-tmp');tree.write(temp,encoding='utf-8',xml_declaration=False);os.replace(temp,path)
ui_path=repo/'src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx'
ui=ET.parse(ui_path);bag=at(ui.getroot().find('Item'),'Root.Panel.Content.Bag')
used={i.get('referent') for i in ui.iter('Item')};counter=1
def clone(original):
    global counter
    node=deepcopy(original);mapping={}
    for item in node.iter('Item'):
        while f'AutoUI{counter}' in used:counter+=1
        fresh=f'AutoUI{counter}';counter+=1;mapping[item.get('referent')]=fresh;item.set('referent',fresh);used.add(fresh)
    for ref in node.iter('Ref'):
        if ref.text in mapping:ref.text=mapping[ref.text]
    return node
assert not any(i.find("Properties/string[@name='Name']").text=='Plan' for i in bag.findall('Item'))
plan=clone(at(bag,'Hint'));prop(plan,'string','Name','Plan');prop(plan,'int','LayoutOrder',2);prop(plan,'string','Text',spec['planText']);plan.find("Properties/UDim2[@name='Size']/YO").text=str(spec['planHeight']);mark(plan);bag.append(plan)
travel=clone(at(bag,'Actions'));prop(travel,'string','Name','TravelActions');prop(travel,'int','LayoutOrder',5);mark(travel)
for old,new,text in [('PackOne','Pause','暂缓出发'),('PackFull','Resume','恢复准备')]:
    button=at(travel,old);prop(button,'string','Name',new);prop(button,'string','Text',text)
bag.append(travel)
for name,order in spec['orders'].items():prop(at(bag,name),'int','LayoutOrder',order)
info=at(bag,'Info');prop(info,'string','Text',spec['infoText']);info.find("Properties/UDim2[@name='Size']/YO").text=str(spec['infoHeight'])
save(ui,ui_path)
for level in (1,2):
    path=repo/f'src/ServerStorage/Game/Resources/Models/TravelBuddy/ShipLv{level}.rbxmx'
    tree=ET.parse(path);prompt=at(tree.getroot().find('Item'),'ShipControl.VoyagePrompt');prop(prompt,'bool','Enabled',False);prop(prompt,'string','ActionText','旧派遣入口（停用）');save(tree,path)
path=repo/'src/ServerStorage/Game/Resources/Models/TravelBuddy/PreparationStation.rbxmx'
tree=ET.parse(path);label=at(tree.getroot().find('Item'),'Appearance.PrepSign.SignGui.Label');prop(label,'string','Text',spec['stationText']);save(tree,path)
print('AUTONOMY_UI_SAVED: Plan, Pause/Resume native buttons, disabled old dispatch prompts')
