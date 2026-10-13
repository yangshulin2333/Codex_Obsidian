from pathlib import Path
from copy import deepcopy
import importlib.util
import json
import os
import sys
import xml.etree.ElementTree as ET

sys.dont_write_bytecode=True
qa=Path(__file__).resolve().parent
repo=Path('F:/HunyueRoblox/TravelBuddy')
spec=importlib.util.spec_from_file_location('helpers',repo/'scripts/game/build_travel_world.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
raw=json.loads((qa/'studio_native.json').read_text(encoding='utf-8'))
assert not raw.get('isError'),raw
data=json.loads(next(c['text'] for c in raw['content'] if c['type']=='text'))

def at(root,path):
    node=root
    for name in path.split('.'):
        node=next(i for i in node.findall('Item') if i.find("Properties/string[@name='Name']").text==name)
    return node
def set_prop(node,kind,name,value):
    return h.property_of(node,kind,name,str(value).lower() if isinstance(value,bool) else value)
def frame(node,values):
    p=h.property_of(node,'CoordinateFrame','CFrame')
    for k,v in zip(('X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'),values):ET.SubElement(p,k).text=str(v)
def color(node,name,values):
    p=h.property_of(node,'Color3',name)
    for k,v in zip(('R','G','B'),values):ET.SubElement(p,k).text=str(v)
def native(parent,d):
    node=h.item(parent,d['class'],d['name'],d['attrs'])
    if d['class']=='Part':
        frame(node,d['frame']);h.vector(node,'Vector3','size',d['size']);color(node,'Color',d['color'])
        for k,v in [('Anchored',True),('CanCollide',d['collide']),('CanTouch',d['touch']),('CanQuery',d['query'])]:set_prop(node,'bool',k,v)
        for k,v in [('Material',d['material']),('shape',1),('TopSurface',0),('BottomSurface',0)]:set_prop(node,'token',k,v)
        set_prop(node,'float','Transparency',d['transparency'])
    elif d['class']=='ProximityPrompt':
        for k,v in [('ActionText',d['action']),('ObjectText',d['subject'])]:set_prop(node,'string',k,v)
        for k,v in [('KeyboardKeyCode',d['keyboard']),('GamepadKeyCode',d['gamepad'])]:set_prop(node,'token',k,v)
        for k,v in [('MaxActivationDistance',d['distance']),('HoldDuration',d['hold'])]:set_prop(node,'float',k,v)
        for k,v in [('Enabled',d['enabled']),('RequiresLineOfSight',d['lineOfSight'])]:set_prop(node,'bool',k,v)
    elif d['class']=='SurfaceGui':
        for k,v in [('Face',d['face']),('SizingMode',d['sizing'])]:set_prop(node,'token',k,v)
        set_prop(node,'float','PixelsPerStud',d['pixels']);set_prop(node,'bool','AlwaysOnTop',False)
    elif d['class']=='TextLabel':
        set_prop(node,'string','Text',d['text']);set_prop(node,'token','Font',d['font']);color(node,'TextColor3',d['textColor'])
        set_prop(node,'float','BackgroundTransparency',1)
        for k,v in [('TextScaled',True),('TextWrapped',True),('AutoLocalize',False)]:set_prop(node,'bool',k,v)
        p=h.property_of(node,'UDim2','Size')
        for k,v in [('XS',1),('XO',0),('YS',1),('YO',0)]:ET.SubElement(p,k).text=str(v)
    else:assert d['class'] in ('Folder','Model'),d['class']
    for c in d['children']:native(node,c)
    if d['class']=='Model':set_prop(node,'Ref','PrimaryPart',at(node,'Root').attrib['referent'])
    return node
def save(tree,path):
    ET.indent(tree,space='  ')
    tmp=path.with_suffix('.bag-tmp');ET.ElementTree(tree).write(tmp,encoding='utf-8',xml_declaration=False);os.replace(tmp,path)
def max_id(tree):
    return max([int(n.attrib['referent'][3:]) for n in tree.iter('Item') if n.attrib.get('referent','').startswith('RBX') and n.attrib['referent'][3:].isdigit()]+[0])

world_path=repo/'src/Workspace/TravelIsland.rbxmx'
world=ET.parse(world_path).getroot();h.NEXT_ID=max_id(world)
root=world.find('Item');sample=at(root,'Plots.Plot1.SampleFixtures')
if any(i.find("Properties/string[@name='Name']").text=='PrepTableTop' for i in sample.findall('Item')):
    for name in data['remove']+['PreparationAnchor']:
        node=next(i for i in sample.findall('Item') if i.find("Properties/string[@name='Name']").text==name)
        sample.remove(node)
    for path,d in data['anchors'].items():native(at(root,path.rsplit('.',1)[0]),d)
    save(world,world_path)
template=ET.Element('roblox',version='4');h.NEXT_ID=0;native(template,data['model'])
save(template,repo/'src/ServerStorage/Game/Resources/Models/TravelBuddy/PreparationStation.rbxmx')

ui_path=repo/'src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx'
ui=ET.parse(ui_path).getroot();h.NEXT_ID=max_id(ui)
content=at(ui.find('Item'),'Root.Panel.Content');bag=deepcopy(at(content,'Status'))
for i in bag.iter('Item'):
    h.NEXT_ID+=1;i.set('referent',f'RBX{h.NEXT_ID}')
set_prop(bag,'string','Name','Bag');set_prop(bag,'bool','Visible',False)
set_prop(at(bag,'Detail'),'string','Name','Hint');set_prop(at(bag,'PrimaryActions'),'string','Name','Actions')
for path,new_name,text in [('Actions.BuySupply','PackOne','装入 1 份'),('Actions.ClaimReturn','PackFull','装满行囊'),('SecondaryActions.ClaimRelief','UnpackOne','收回 1 份'),('SecondaryActions.Refresh','UnpackAll','全部收回')]:
    node=at(bag,path);set_prop(node,'string','Name',new_name);set_prop(node,'string','Text',text)
old_info=at(bag,'Retry');bag.remove(old_info);info=deepcopy(at(bag,'Hint'));h.NEXT_ID+=1;info.set('referent',f'RBX{h.NEXT_ID}');set_prop(info,'string','Name','Info');set_prop(info,'int','LayoutOrder',4);bag.append(info)
for name,text,height in [('Summary','仓库补给 0 份\n行囊 0 / 3 份',72),('Hint','伙伴在家时可整理，旅行及未靠岸时只读。',72),('Info','每趟出发消耗 1 份行囊补给。\n购买只增加仓库，装入后才能用于出航。',88)]:
    n=at(bag,name);set_prop(n,'string','Text',text);n.find("Properties/UDim2[@name='Size']/YO").text=str(height)
content.append(bag);save(ui,ui_path)
print('NATIVE_BAG_SAVED: island anchors, PreparationStation template, Bag native panel')
