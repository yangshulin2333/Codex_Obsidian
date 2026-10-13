from pathlib import Path
import base64
import struct
import os
import xml.etree.ElementTree as ET
repo=Path('F:/HunyueRoblox/TravelBuddy')
def mark(node,fields):
    props=node.find('Properties');p=props.find("BinaryString[@name='AttributesSerialize']")
    count=0;body=b''
    if p is not None:
        old=base64.b64decode(p.text);count=struct.unpack('<I',old[:4])[0];body=old[4:]
    else:p=ET.SubElement(props,'BinaryString',name='AttributesSerialize')
    for k,v in fields.items():
        kb=k.encode();body+=struct.pack('<I',len(kb))+kb
        if isinstance(v,bool):body+=bytes([3,int(v)])
        else:vb=v.encode();body+=bytes([2])+struct.pack('<I',len(vb))+vb
    p.text=base64.b64encode(struct.pack('<I',count+len(fields))+body).decode()
for relative,name,fields in [
 ('src/Workspace/TravelIsland.rbxmx','PreparationAnchor',{'NativeFile':True}),
 ('src/ServerStorage/Game/Resources/Models/TravelBuddy/PreparationStation.rbxmx','PreparationStation',{'NativeFile':True}),
 ('src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx','Bag',{'NativeFile':True,'BagPanelVersion':'v1'}),
]:
    path=repo/relative;tree=ET.parse(path)
    for node in tree.iter('Item'):
        n=node.find("Properties/string[@name='Name']")
        if n is not None and n.text==name:mark(node,fields)
    ET.indent(tree,space='  ');tmp=path.with_suffix('.bag-tmp');tree.write(tmp,encoding='utf-8',xml_declaration=False);os.replace(tmp,path)
print('SOURCE_NATIVE_MARKED')
