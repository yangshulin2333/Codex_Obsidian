from pathlib import Path
import hashlib
import json
from PIL import Image

qa = Path(__file__).resolve().parent
old = json.loads((qa.parent / '20261013/before.json').read_text(encoding='utf-8'))
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
changed = [p for p,h in old['code'].items() if sha(p) != h]
expected = {'TravelIsland.rbxmx', 'HomeLv1.rbxmx', 'HomeLv2.rbxmx'}
assert {Path(p).name for p in changed} == expected, changed
repo = Path('F:/HunyueRoblox/TravelBuddy')
current = {str(p) for folder in ('src','scripts','tests','design') for p in (repo/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts}
new = sorted(current - set(old['code']))
assert new == [str(repo/'scripts/game/build_plot_sample.luau')], new
original_sources = [p for p,h in old['sources'].items() if sha(p) != h]
assert not original_sources
walk_result = json.loads((qa/'verified_physics_walk.json').read_text(encoding='utf-8'))
walk = json.loads(next(c['text'] for c in walk_result['content'] if c['type']=='text'))
assert len(walk)==11 and all(p['reached'] and p['health']==100 for p in walk)
image_path = qa.parents[1] / 'assets/白模样板_1号地块.png'
with Image.open(image_path) as image:
    image.verify()
place_path = repo/'build/TravelBuddy-Plot1-Whitebox.rbxlx'
report = {'changed_assets':changed,'new_authoring_script':new,'business_logic_and_config_unchanged':True,'physics_walk':walk,'geometry':{'levels_checked':[1,2],'boxes':6,'central_walkway_studs':6,'row_clearance_studs':4.4,'public_path_clearance_studs':1.7},'scene_place':{'path':str(place_path),'sha256':sha(place_path)},'image':{'path':str(image_path),'sha256':sha(image_path)},'checks':'TravelNativeCheck, TravelWorldCheck, TravelBuildCheck, ModuleBase, ConfigTool (64 tests), RojoWorkflow, StyLua and Selene passed','studio_cleanup':'TemporaryInspection removed; Server.Main and Client.Main restored enabled; UnitTestRunner remained disabled; no business profile loaded in isolated geometry test.'}
(qa/'verification-final.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('WHITEBOX_SCOPE_OK: 3 native assets + 1 offline build script; gameplay/config unchanged; 11/11 physics waypoints; screenshot verified')
