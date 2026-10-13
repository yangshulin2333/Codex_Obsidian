from pathlib import Path
import base64
import os
import struct
import xml.etree.ElementTree as ET
path=Path('F:/HunyueRoblox/TravelBuddy/src/ServerStorage/Game/Resources/Models/TravelBuddy/PreparationStation.rbxmx')
tree=ET.parse(path);root=tree.getroot().find('Item')
assert not any(i.find("Properties/string[@name='Name']").text=='CompanionAnchor' for i in root.findall('Item'))
node=ET.SubElement(root,'Item',{'class':'Part','referent':'AutoCompanionAnchor'})
props=ET.SubElement(node,'Properties')
for kind,name,value in [('string','Name','CompanionAnchor'),('bool','Archivable','true'),('bool','Anchored','true'),('bool','CanCollide','false'),('bool','CanTouch','false'),('bool','CanQuery','false'),('float','Transparency','1')]:ET.SubElement(props,kind,name=name).text=value
key=b'AutonomyAnchorNative';body=struct.pack('<I',1)+struct.pack('<I',len(key))+key+bytes([3,1]);ET.SubElement(props,'BinaryString',name='AttributesSerialize').text=base64.b64encode(body).decode()
size=ET.SubElement(props,'Vector3',name='size')
for key in ('X','Y','Z'):ET.SubElement(size,key).text='0.1'
cf=ET.SubElement(props,'CoordinateFrame',name='CFrame')
for key,value in zip(('X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'),(0,0,-3.2,1,0,0,0,1,0,0,0,1)):ET.SubElement(cf,key).text=str(value)
ET.indent(tree,space='  ');temp=path.with_suffix('.autonomy-tmp');tree.write(temp,encoding='utf-8',xml_declaration=False);os.replace(temp,path)
print('COMPANION_PREPARING_DISPLAY_ANCHOR_SAVED')
