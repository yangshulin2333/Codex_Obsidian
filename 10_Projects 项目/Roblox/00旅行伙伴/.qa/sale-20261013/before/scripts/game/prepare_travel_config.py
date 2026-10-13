"""Create the TravelBuddy Demo's initial workbook through the existing schema tool.

This is a one-time authoring helper. Existing records are kept; later balancing
is done in Excel and scripts/Import-GameConfig.ps1, not in generated Lua.
"""
from pathlib import Path
import json
import shutil
from datetime import datetime
from openpyxl import Workbook, load_workbook

ROOT = Path(__file__).resolve().parents[2]
SCHEMA = ROOT / 'design/config/config-schema.json'
WORKBOOKS = ROOT / 'design/config/workbooks'


def column(key, description, kind='string', **rules):
    rules.setdefault('required', True)
    return dict(key=key, descriptionZh=description, type=kind, **rules)


NOTE = column('Note', '备注（不导出）', required=False, export=False)


def sheet(name, columns, rows, scope='Shared'):
    return dict(name=name, workbook='TravelConfig.xlsx', descriptionZh=name,
                scope=scope, primaryKey='Id', columns=columns + [NOTE]), rows


def id_column():
    return column('Id', '稳定主键（必填）', unique=True)


def number(key, description, minimum=0):
    return column(key, description, 'number', min=minimum, integer=True)


SETTINGS = {
    'InitialCoins': 30, 'InitialWood': 4, 'InitialSupplies': 3, 'BagCapacity': 3,
    'SupplyPrice': 5, 'SupplyCost': 1, 'FirstJourneySeconds': 60,
    'RestSeconds': 180, 'ContainerWood': 2, 'ItemsPerContainer': 3,
    'ReceiptLimit': 100, 'HomeCapacity1': 3, 'HomeCapacity2': 6,
    'MaxPlayers': 4, 'TickSeconds': 1, 'RequestCooldown': 0.2,
    'StudioTimeScale': 0.05, 'ProductionTimeScale': 1,
    'DataReadyTimeout': 30, 'RequestTimeout': 10,
    'DepartureSeconds': 8, 'ReturnSeconds': 5,
    'PrepareMinSeconds': 60, 'PrepareMaxSeconds': 180, 'FirstPrepareSeconds': 30,
    'StudioPrepareMinSeconds': 15, 'StudioPrepareMaxSeconds': 30,
    # Demo balancing defaults. These weights remain adjustable in TravelSettings.
    'SeaChoiceWeight_shallow': 1, 'SeaChoiceWeight_near': 1,
    'ShortChoiceWeight': 1, 'LongChoiceWeight': 1,
}
ITEMS = [
    ('item_old_book', '旧书', 'Commodity', 'Common', 5),
    ('item_bottle', '玻璃瓶', 'Commodity', 'Common', 5),
    ('item_rope', '绳索', 'Commodity', 'Common', 6),
    ('item_clock', '旧钟表', 'Commodity', 'Common', 8),
    ('item_food_can', '食品罐头', 'Commodity', 'Life', 12),
    ('item_cloth', '布料', 'Commodity', 'Life', 14),
    ('item_tool', '工具', 'Commodity', 'Life', 16),
    ('item_lamp', '灯具', 'Commodity', 'Life', 18),
    ('item_spice', '香料', 'Commodity', 'Fine', 25),
    ('item_tea', '茶叶', 'Commodity', 'Fine', 30),
    ('item_porcelain', '瓷器', 'Commodity', 'Fine', 35),
    ('item_silk', '丝绸', 'Commodity', 'Fine', 40),
    ('special_shell', '贝壳', 'Special', 'Special', 4),
    ('special_conch', '海螺', 'Special', 'Special', 6),
    ('special_pearl', '珍珠', 'Special', 'Special', 10),
]
SEAS = [
    ('shallow', '浅滩', 1, '基础旅行，适合收集建设材料。', 1),
    ('near', '近海', 2, '二级船解锁，高价值商品与新的明信片。', 2),
]
DURATIONS = [
    ('shallow_short', 'shallow', '短途 10 分钟', 600, 1, 1),
    ('shallow_long', 'shallow', '长途 30 分钟', 1800, 3, 2),
    ('near_short', 'near', '标准 30 分钟', 1800, 1, 3),
    ('near_long', 'near', '长途 60 分钟', 3600, 2, 4),
]
UPGRADES = [
    ('Home2', 'Home', 2, 60, 8, 180, '木屋；集装箱容量从3增加到6。', 'Models.TravelBuddy.HomeLv2'),
    ('Ship2', 'Ship', 2, 40, 6, 120, '带帆木船；解锁近海。', 'Models.TravelBuddy.ShipLv2'),
]
CARD_TITLES = {
    'shallow': ['浅滩日落', '灯塔前的海蛙', '沙滩午后', '海鸥来信', '月光码头'],
    'near': ['近海晨光', '鲸鱼的问候', '远处的帆船', '雨后彩虹', '星空海面'],
}
CARDS = [
    (f'post_{sea}_{i:02}', sea, title, f'post_{sea}_{i:02}',
     f'海蛙从{"浅滩" if sea == "shallow" else "近海"}带回的旅行记录。', index * 5 + i)
    for index, (sea, titles) in enumerate(CARD_TITLES.items())
    for i, title in enumerate(titles, 1)
]


def definitions():
    quality = ['Common', 'Life', 'Fine']
    return [
        sheet('TravelSettings', [id_column(), column('Value', '配置数值（秒或数量）', 'number', min=0)],
              [(key, value) for key, value in SETTINGS.items()]),
        sheet('TravelItems', [id_column(), column('Name', '中文名称'),
                             column('Kind', '商品或特产', enum=['Commodity', 'Special']),
                             column('Quality', '物品池', enum=quality + ['Special']),
                             number('Price', '固定单件售价'), number('Order', '显示顺序')],
              [row + (i,) for i, row in enumerate(ITEMS, 1)]),
        sheet('TravelSeas', [id_column(), column('Name', '海域名称'), number('ShipLevel', '所需船等级', 1),
                            column('Description', '说明'), number('Order', '显示顺序')], SEAS),
        sheet('TravelDurations', [id_column(), column('SeaId', '目的地', ref='TravelSeas.Id'),
                                 column('Name', '航程名称'), number('Seconds', '正式航程秒数', 1),
                                 number('YieldMultiplier', '商品与特产数量倍率', 1), number('Order', '显示顺序')],
              DURATIONS),
        sheet('TravelUpgrades', [id_column(), column('Target', '升级设施', enum=['Home', 'Ship']),
                                number('Level', '目标等级', 2), number('Coins', '金币费用'),
                                number('Wood', '木板费用'), number('Seconds', '建设秒数', 1),
                                column('Description', '功能变化'), column('ModelPath', '服务器模型模板路径')],
              UPGRADES),
        sheet('TravelPostcards', [id_column(), column('SeaId', '海域', ref='TravelSeas.Id'),
                                 column('Title', '明信片标题'), column('ImageId', '图片记录', ref='Images.Id'),
                                 column('Description', '收藏说明'), number('Order', '显示顺序')], CARDS),
        sheet('TravelWeights', [id_column(), column('SeaId', '海域', ref='TravelSeas.Id'),
                               column('Quality', '箱子品质', enum=quality),
                               number('Weight', '权重百分数')],
              [(f'{sea}_{q}', sea, q, w) for sea, weights in [('shallow', [90, 10, 0]), ('near', [20, 20, 60])]
               for q, w in zip(quality, weights)], 'Server'),
    ]


def put_rows(book, definition, records):
    name = definition['name']
    ws = book[name] if name in book.sheetnames else book.create_sheet(name)
    columns = definition['columns']
    if ws.max_row == 1 and ws.cell(1, 1).value is None:
        for index, field in enumerate(columns, 1):
            ws.cell(1, index, field['descriptionZh'])
            ws.cell(2, index, field['key'])
            ws.cell(3, index, field['type'])
    keys = {ws.cell(row, 1).value for row in range(4, ws.max_row + 1)}
    for values in records:
        if values[0] not in keys:
            ws.append(list(values) + ['Demo 初值，需试玩平衡。'])
    ws.freeze_panes = 'A4'


def main():
    schema = json.loads(SCHEMA.read_text(encoding='utf-8-sig'))
    additions = definitions()
    backup = ROOT / '.game-checks' / ('before-config-' + datetime.now().strftime('%Y%m%d-%H%M%S'))
    backup.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SCHEMA, backup / SCHEMA.name)
    asset_file = WORKBOOKS / 'AssetConfig.xlsx'
    shutil.copy2(asset_file, backup / asset_file.name)
    by_name = {definition['name']: definition for definition in schema['sheets']}
    for definition, _ in additions:
        if definition['name'] not in by_name:
            schema['sheets'].append(definition)
    SCHEMA.write_text(json.dumps(schema, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    travel_file = WORKBOOKS / 'TravelConfig.xlsx'
    if travel_file.exists():
        book = load_workbook(travel_file)
    else:
        book = Workbook()
        book.remove(book.active)
    for definition, rows in additions:
        put_rows(book, definition, rows)
    book.save(travel_file)
    assets = load_workbook(asset_file)
    images = assets['Images']
    known = {images.cell(row, 1).value for row in range(4, images.max_row + 1)}
    for card_id, sea_id, title, _, _, _ in CARDS:
        if card_id in known:
            continue
        prompt = (f'用途：{title}明信片；状态：未制作、未上传；Prompt: A gentle hand-painted '
                  f'2D illustration of a small green sailor frog at a {sea_id} ocean scene, '
                  f'theme {title}, soft ocean blue and warm sand colors, storybook composition, '
                  'no lettering;尺寸：1024x768，4:3；透明背景：否；'
                  '负面约束：no text, no watermark, no logo, no photorealism.')
        images.append([card_id, None, prompt])
    assets.save(asset_file)
    print('TRAVEL_CONFIG_AUTHORED', travel_file)
    print('CONFIG_BACKUP', backup)


if __name__ == '__main__':
    main()
