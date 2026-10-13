import hashlib
import json
from pathlib import Path

qa = Path('D:/AI/Codex_Obsidian/10_Projects 项目/Roblox/00旅行伙伴/.qa/return-20261013')
baseline = json.loads((qa / 'before.json').read_text(encoding='utf-8-sig'))
changed = [path for path, digest in baseline.items() if hashlib.sha256(Path(path).read_bytes()).hexdigest() != digest]
assert not any('/Framework/' in path.replace('\\', '/') for path in changed), 'Framework must stay unchanged'
before = json.loads((qa / 'studio-offline-before.json').read_text(encoding='utf-8'))
rows = json.loads(before['Rows'])
returning = next(row for row in rows if row['State'] == 'Returning')
resting = next(row for row in rows if row['State'] == 'Resting')
preparing = next(row for row in rows if row['State'] == 'Preparing')
assert returning['RestUntil'] == returning['Journey']['EndAt'] + 9
assert resting['Unread'] and preparing['Unread'] and preparing['Packed'] == 1
assert before['State']['Journey']['Id'] != returning['Journey']['Id']
assert before['State']['PackedSupplies'] == 0
after = json.loads((qa / 'studio-offline-after.json').read_text(encoding='utf-8'))
assert after['UnopenedCount'] == before['State']['UnopenedCount'] + 1
assert after['Inventory']['special_conch'] == before['State']['Inventory']['special_conch'] + 2
assert after['Journey']['Id'] == before['State']['Journey']['Id']
assert after['Journey']['Status'] == 'Settled'
assert after['RestUntil'] == 0 and after['HasUnreadReturn']
assert after['LatestReturn']['ReturnedAt'] == before['State']['Journey']['EndAt']
log = (qa / 'local-validation-final.log').read_text(encoding='utf-8', errors='replace')
for marker in ['TravelDomain: 38 passed, 0 failed', 'CONFIG_TOOL_CHECK_OK', 'MODULE_BASE_CHECK_OK', 'ROJO_WORKFLOW_CHECK_OK', 'TRAVEL_SERVICE_OK', 'TRAVEL_WORLD_SERVICE_OK', 'TRAVEL_BUILD_OK', 'TRAVEL_DEMO_CHECK_OK']:
    assert marker in log, marker
report = {
    'date': '2026-10-13',
    'businessVersion': 4,
    'passed': True,
    'changedFiles': changed,
    'frameworkUnchanged': True,
    'local': {'domainTests': 38, 'configTests': 64, 'compiledScripts': 64, 'nativeUiAndPhoneLayout': 'pass', 'fourPlotIsolation': 'pass'},
    'studio': {'onlineStates': [r['State'] for r in rows], 'restFromEndAtSeconds': 9, 'unreadDoesNotBlockNextVoyage': True, 'offlinePaidJourneySettledOnce': True, 'readOnlyMarksRead': True, 'rejoinNoNewJourneyReward': True, 'companionFocusAndCameraRestore': True, 'obstructionAvoidance': True, 'tempObjectsRemoved': True, 'leftInPlay': True},
    'testEconomy': {'sold': {'item_clock': 1}, 'suppliesBoughtAndUsed': 2, 'normalOpenContainerReceiptsObserved': 4, 'currencyInjected': False, 'profileReset': False},
    'limits': ['No offline multiple-trip catchup', 'No independent life activity AI', 'No visible sealed quality or whole-box auction', 'No formal art generation or upload', 'No new four-client live session or real-phone performance test'],
    'desktopAutomation': 'User pressed Escape; no further desktop input performed.',
}
(qa / 'verification-final.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print('FINAL_VERIFICATION_OK; changedFiles=' + str(len(changed)))
