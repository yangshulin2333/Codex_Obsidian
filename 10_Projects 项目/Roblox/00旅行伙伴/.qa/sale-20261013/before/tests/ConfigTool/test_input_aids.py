import copy
import json
import tempfile
import unittest
from pathlib import Path
from test_import_config import import_config, ROOT


class InputAidsTests(unittest.TestCase):
    def setUp(self):
        self.schema = json.loads((ROOT / 'tests/ConfigTool/fixtures/schema.json').read_text(encoding='utf-8'))

    def test_created_rules_match_schema_and_preserve_refresh_data(self):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            import_config.sync_workbooks_from_schema(folder, self.schema)
            for file in folder.glob('*.xlsx'):
                book = import_config.load_workbook(file)
                for sheet in [s for s in self.schema['sheets'] if s['workbook'] == file.name]:
                    ws = book[sheet['name']]
                    rules = ws.data_validations.dataValidation
                    self.assertEqual(len(sheet['columns']), len(rules))
                    for col, rule in zip(sheet['columns'], rules):
                        self.assertTrue(rule.showInputMessage)
                        if col['type'] == 'boolean' or col.get('enum'):
                            self.assertEqual('list', rule.type)
                            self.assertFalse(rule.showDropDown)
                            self.assertEqual('stop', rule.errorStyle)
                            self.assertTrue(rule.showErrorMessage)
                        elif col['type'] == 'number':
                            self.assertEqual('decimal', rule.type)
                    ws['A4'] = 'KeepMe'
                book.save(file)
                book.close()
            import_config.sync_workbooks_from_schema(folder, self.schema, refresh_inputs=True)
            import_config.sync_workbooks_from_schema(folder, self.schema, refresh_inputs=True)
            for file in folder.glob('*.xlsx'):
                book = import_config.load_workbook(file)
                for ws in book:
                    expected = next(s for s in self.schema['sheets'] if s['name'] == ws.title)
                    self.assertEqual('KeepMe', ws['A4'].value)
                    self.assertEqual(len(expected['columns']), len(ws.data_validations.dataValidation))
                book.close()

    def test_refresh_preserves_conflicting_draft_and_foreign_rules(self):
        schema = copy.deepcopy(self.schema)
        schema['sheets'] = [schema['sheets'][0]]
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            import_config.sync_workbooks_from_schema(folder, schema)
            file = folder / schema['sheets'][0]['workbook']
            book = import_config.load_workbook(file)
            ws = book.active
            rule = import_config.DataValidation(type='textLength', operator='lessThan', formula1='20')
            rule.add('Z4:Z10'); ws.add_data_validation(rule)
            book.save(file); book.close()
            import_config.sync_workbooks_from_schema(folder, schema, refresh_inputs=True)
            book = import_config.load_workbook(file)
            self.assertTrue(any(str(r.sqref) == 'Z4:Z10' for r in book.active.data_validations.dataValidation))
            book.active['A2'] = 'UnconfirmedDraft'
            book.save(file); book.close()
            before = file.read_bytes()
            self.assertEqual([], import_config.sync_workbooks_from_schema(folder, schema, refresh_inputs=True))
            self.assertEqual(before, file.read_bytes())

    def test_unsafe_inline_enum_does_not_generate_broken_dropdown(self):
        sheet = copy.deepcopy(self.schema['sheets'][0])
        sheet['columns'][0]['enum'] = ['a,b', 'x' * 260]
        book = import_config.Workbook()
        import_config.write_sheet_headers(book.active, sheet, self.schema['layout'])
        rule = book.active.data_validations.dataValidation[0]
        self.assertIsNone(rule.type)
        self.assertTrue(rule.showInputMessage)
