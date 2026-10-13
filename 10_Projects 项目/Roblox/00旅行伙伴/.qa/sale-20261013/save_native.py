from pathlib import Path
from copy import deepcopy
import xml.etree.ElementTree as E
import base64,struct,uuid

repo=Path('F:/HunyueRoblox/TravelBuddy')
seq=0
def props(n): return {p.get('name'):p for p in n.find('Properties')}
def child(n,path):
    for name in path.split('.'):
        candidates=[x for x in n.findall('Item') if props(x)['Name'].text==name]
        assert len(candidates)==1,path
        n=candidates[0]
    return n
def setp(n,name,kind,value):
    p=props(n).get(name)
    if p is None:p=E.SubElement(n.find('Properties'),kind,name=name)
    p.text=str(value)
    return p
def vector(n,name,kind,values):
    p=props(n).get(name)
    if p is None:p=E.SubElement(n.find('Properties'),kind,name=name)
    for x in list(p):p.remove(x)
    for k,v in values.items():E.SubElement(p,k).text=str(v)
def size(n,xs,xo,ys,yo):vector(n,'Size','UDim2',dict(XS=xs,XO=xo,YS=ys,YO=yo))
def position(n,xs,xo,ys,yo):vector(n,'Position','UDim2',dict(XS=xs,XO=xo,YS=ys,YO=yo))
def clone(n):
    x=deepcopy(n); refs={p.get('referent'):'Sale'+uuid.uuid4().hex for p in x.iter('Item')}
    for p in x.iter('Item'):p.set('referent',refs[p.get('referent')])
    for p in x.iter('Ref'):
        if p.text in refs:p.text=refs[p.text]
    return x
def put(p,x,name):setp(x,'Name','string',name);p.append(x);return x
def strip(n,keep=()):
    for x in n.findall('Item'):
        if x.get('class') not in keep:n.remove(x)
def color(n,name,r,g,b):
    p=setp(n,name,'Color3uint8',(r<<16)|(g<<8)|b)
    p.tag='Color3uint8'
    for c in list(p):p.remove(c)
def cf(n,x,y,z,rotation=None):
    matrix=rotation or [1,0,0,0,1,0,0,0,1]
    vector(n,'CFrame','CoordinateFrame',dict(zip(['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],[x,y,z]+matrix)))
def attr(n,values):
    data=struct.pack('<I',len(values))
    for name,val in values.items():
        key=name.encode();data+=struct.pack('<I',len(key))+key
        if isinstance(val,bool):data+=b'\x03'+bytes([val])
        else:
            val=val.encode();data+=b'\x02'+struct.pack('<I',len(val))+val
    setp(n,'AttributesSerialize','BinaryString',base64.b64encode(data).decode())
def new(kind,name):
    n=E.Element('Item',{'class':kind,'referent':'Sale'+uuid.uuid4().hex});E.SubElement(n,'Properties')
    setp(n,'Name','string',name);setp(n,'Archivable','bool','true');return n
def save(t,path):E.indent(t,space='  ');t.write(path,encoding='utf-8',xml_declaration=False)

path=repo/'src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx';tree=E.parse(path);ui=tree.getroot().find('Item');content=child(ui,'Root.Panel.Content');bag=child(content,'Bag')
assert not any(props(x)['Name'].text in ('Sell','SellDetail') for x in content.findall('Item'))
def panel(name):
    n=clone(bag);strip(n,('UIListLayout',));setp(n,'Visible','bool','false');vector(n,'CanvasPosition','Vector2',dict(X=0,Y=0));vector(n,'CanvasSize','UDim2',dict(XS=0,XO=0,YS=0,YO=0));setp(n,'AutomaticCanvasSize','token',2);setp(n,'ScrollingDirection','token',2);return put(content,n,name)
def label(p,name,text,height,order):
    n=clone(child(bag,'Summary'));setp(n,'Text','string',text);size(n,.98,0,0,height);setp(n,'LayoutOrder','int',order);setp(n,'Visible','bool','true');return put(p,n,name)
def frame(p,name,height,order):
    n=clone(child(bag,'Actions'));strip(n);size(n,.98,0,0,height);setp(n,'LayoutOrder','int',order);setp(n,'Visible','bool','true');return put(p,n,name)
def button(p,name,text,dims,loc=(0,0,0,0),order=0):
    n=clone(child(bag,'Actions.PackOne'));setp(n,'Text','string',text);size(n,*dims);position(n,*loc);vector(n,'AnchorPoint','Vector2',dict(X=0,Y=0));setp(n,'LayoutOrder','int',order);setp(n,'Visible','bool','true');return put(p,n,name)
sell=panel('Sell');label(sell,'Summary','金币 0 · 商品收购台',56,1);cats=frame(sell,'Categories',52,2)
button(cats,'Commodity','普通商品',(.48,0,1,0));button(cats,'Special','特产',(.48,0,1,0),(.52,0,0,0))
label(sell,'Hint','选择物品后，可调整出售数量。',48,3);label(sell,'BulkPreview','批量出售只包含普通商品，特产保留。',56,4)
button(sell,'SellAll','出售全部普通商品',(.98,0,0,52),order=5)
rows=frame(sell,'Rows',0,6);setp(rows,'AutomaticSize','token',2)
oldrows=child(content,'Inventory.Rows');rows.append(clone(next(x for x in oldrows.findall('Item') if x.get('class')=='UIListLayout')))
detail=panel('SellDetail');label(detail,'Item','选择出售物品',64,1);label(detail,'Price','固定售价',40,2);qty=frame(detail,'Quantity',52,3)
button(qty,'Minus','−',(0,44,0,52));amount=label(qty,'Amount','1',52,0);size(amount,1,-172,1,0);position(amount,0,48,0,0);setp(amount,'TextXAlignment','token',2)
button(qty,'Plus','＋',(0,44,0,52),(1,-124,0,0));button(qty,'All','全部',(0,76,0,52),(1,-76,0,0))
label(detail,'Total','预计获得 0 金币',64,4);button(detail,'Sell','出售',(.98,0,0,52),order=5);button(detail,'Back','返回物品列表',(.98,0,0,52),order=6);label(detail,'Hint','选择数量后出售。木材、封箱与明信片不在此处出售。',80,7)
templates=child(ui,'Templates');template=put(templates,clone(child(templates,'ItemTemplate')),'SellItemTemplate');setp(child(template,'Action'),'Text','string','选择数量');setp(child(content,'Inventory.SellAll'),'Text','string','前往商品收购台');save(tree,path)

path=repo/'src/Workspace/TravelIsland.rbxmx';tree=E.parse(path);world=tree.getroot().find('Item');hub=child(world,'Hub');assert not any(props(x)['Name'].text=='SellAnchor' for x in hub.findall('Item'))
anchor=clone(child(hub,'ShopAnchor'));strip(anchor);sizeprop=props(anchor).get('size');vector(anchor,'size','Vector3',dict(X=.1,Y=.1,Z=.1));cf(anchor,-10,3.2,23)
for k in ('CanCollide','CanTouch','CanQuery'):setp(anchor,k,'bool','false')
setp(anchor,'Transparency','float',1);attr(anchor,{'TravelFacility':'Sell'});put(hub,anchor,'SellAnchor')
prompt=clone(child(hub,'ShopAnchor.ShopPrompt'));setp(prompt,'ActionText','string','出售物品');setp(prompt,'ObjectText','string','商品收购台');setp(prompt,'KeyboardKeyCode','token',102);setp(prompt,'GamepadKeyCode','token',1001);attr(prompt,{'TravelAction':'Sell'});put(anchor,prompt,'SellPrompt')
guide=new('BillboardGui','GuideGui');size(guide,0,210,0,44);vector(guide,'StudsOffsetWorldSpace','Vector3',dict(X=0,Y=6,Z=0));setp(guide,'MaxDistance','float',160);setp(guide,'AlwaysOnTop','bool','true');setp(guide,'LightInfluence','float',0);setp(guide,'Enabled','bool','false');anchor.append(guide)
lbl=clone(child(hub,'ShopSign.SignGui.Label'));size(lbl,1,0,1,0);setp(lbl,'Text','string','商品收购台 ↓');color(lbl,'BackgroundColor3',248,220,125);setp(lbl,'BackgroundTransparency','float',.1);color(lbl,'TextColor3',29,66,56);put(guide,lbl,'Label')
counter=new('Model','SaleCounter');attr(counter,{'Role':'SellCounter'});hub.append(counter)
root=clone(anchor);strip(root);attr(root,{});put(counter,root,'Root');setp(counter,'PrimaryPart','Ref',root.get('referent'))
appearance=new('Folder','Appearance');counter.append(appearance)
desk=clone(child(hub,'ShopAnchor'));strip(desk);cf(desk,-10,3.2,23);color(desk,'Color3uint8',62,111,95);put(appearance,desk,'Counter')
sign=clone(child(hub,'ShopSign'));cf(sign,-10,6,21.2);setp(child(sign,'SignGui.Label'),'Text','string','商品收购台\n出售物品 · 换取金币');put(appearance,sign,'Sign');reverse=clone(child(sign,'SignGui'));setp(reverse,'Face','token',5);put(sign,reverse,'ReverseGui')
for i in range(1,4):
    coin=clone(anchor);strip(coin);attr(coin,{});vector(coin,'size','Vector3',dict(X=.25,Y=1.2,Z=1.2));setp(coin,'shape','token',2);setp(coin,'Transparency','float',0);setp(coin,'CanQuery','bool','true');cf(coin,-12+i,4.55,23,[0,-1,0,1,0,0,0,0,1]);color(coin,'Color3uint8',242,206,98);put(appearance,coin,'Coin'+str(i))
setp(child(hub,'ShopSign.SignGui.Label'),'Text','string','补给商店\n购买补给');setp(child(hub,'ShopAnchor.ShopPrompt'),'ActionText','string','购买补给');setp(child(hub,'ShopAnchor.ShopPrompt'),'ObjectText','string','补给商店')
for p in child(hub,'AuctionCounter').iter('string'):
    if p.get('name')=='Text':p.text='拍卖区\n白模预留'
save(tree,path)
print('SELL_NATIVE_SAVED')
