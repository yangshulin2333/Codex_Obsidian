from pathlib import Path
import hashlib
import json
from PIL import Image

qa=Path(__file__).resolve().parent
repo=Path('F:/HunyueRoblox/TravelBuddy')
def tool_json(name):
    tool=json.loads((qa/name).read_text(encoding='utf-8'))
    assert not tool.get('isError'),name
    return json.loads(next(c['text'] for c in tool['content'] if c['type']=='text'))
before=tool_json('before_reload.json');after=tool_json('after_reload.json')
assert before==after
assert after['version']==2 and after['backend']=='ProfileStore'
assert (after['warehouse'],after['packed'])==(3,2)
request=tool_json('studio_requests.json')
assert request['results'][0]['ok'] and request['results'][1]['ok']
assert request['results'][0]['revision']==request['results'][1]['revision']
assert request['results'][2]['code']=='OPERATION_CONFLICT'
assert request['results'][6]['code']=='BAG_FULL'
lock=tool_json('voyage_lock.json')
assert lock['state']=='Voyaging' and lock['canManage'] is False
assert lock['requestCode']=='BAG_READ_ONLY' and lock['requestOk'] is False
assert lock['before']==lock['after']=={'warehouse':3,'packed':1}
assert not any(lock['buttonsActive'])
returned=tool_json('return_window.json')
assert returned['canManage'] is True and all(returned['buttons'])
snapshot=json.loads((qa.parent/'20261013/before.json').read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
framework={p:h for p,h in snapshot['code'].items() if '\\Framework\\' in p or p.endswith('StorageConfig.lua')}
assert all(sha(p)==h for p,h in framework.items())
assert all(sha(p)==h for p,h in snapshot['sources'].items())
log=(qa/'validate-travel-demo.log').read_text(encoding='utf-8-sig')
assert 'TRAVEL_DEMO_CHECK_OK' in log and '29 passed, 0 failed' in log
image=qa.parents[1]/'assets/行囊装取_Studio验证.png'
with Image.open(image) as pic:pic.verify()
report={'phase':'Supply packing and unpacking','fields':['WarehouseSupplies','PackedSupplies'],'capacity':3,'version':2,'scope':'No autonomous decisions or automatic return settlement implemented in this phase','framework_files_unchanged':len(framework),'reload_unchanged':after,'live_request_checks':request,'voyage_read_only':lock,'after_docking':returned,'checks':['29 Domain tests','64 ConfigTool tests','Service/World/Native/UI','StyLua and Selene','ModuleBase and RojoWorkflow','64 scripts compiled'],'studio_final':'Play; own preparation table; Bag UI open; no temporary QA script retained','test_purchase':'Purchased 5 supplies through the existing shop; 25 test coins spent. One supply used for a short voyage; remaining 3 warehouse + 1 packed. Existing pending voyage collected through normal UI. No profile reset or test currency injection.','image':str(image),'assets':{str(p):sha(p) for p in [repo/'src/Workspace/TravelIsland.rbxmx',repo/'src/ServerStorage/Game/Resources/Models/TravelBuddy/PreparationStation.rbxmx',repo/'src/ReplicatedStorage/Game/Resources/UI/TravelBuddy/TravelWindow.rbxmx',repo/'build/TravelBuddy-Demo.rbxlx']}}
(qa/'verification-final.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('BAG_FINAL_OK: repeat-safe transfer, legacy migration, real UI, in-flight lock, after-dock unlock, ProfileStore restart equality, unchanged framework, native screenshot')
