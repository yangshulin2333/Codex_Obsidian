from __future__ import annotations

import tempfile
import unittest
from pathlib import Path
from unittest import mock

from test_import_config import import_config


OLD_OUTPUTS = {
    "Shared": {"OldShared.lua": "return { Old = true }\n"},
    "Server": {"OldServer.lua": "return { Old = true }\n"},
}
NEW_OUTPUTS = {
    "Shared": {"NewShared.lua": "return { New = true }\n"},
    "Server": {"NewServer.lua": "return { New = true }\n"},
}


def field_schema(primary_key="Id"):
    columns = [
        dict(key=primary_key, descriptionZh="记录身份", type="string", required=True, unique=True),
        dict(key="function", descriptionZh="文本字段", type="string", required=True),
        dict(key="Count", descriptionZh="整数", type="number", required=True, integer=True),
        dict(key="Enabled", descriptionZh="开关", type="boolean", required=True),
        dict(key="Note", descriptionZh="备注", type="string", required=False, export=False),
    ]
    return {
        "version": 1,
        "layout": dict(descriptionRow=1, keyRow=2, typeRow=3, dataStartRow=4),
        "sheets": [
            dict(name=f"{scope}Records", workbook="Safety.xlsx", descriptionZh="生成回归",
                 scope=scope, primaryKey=primary_key, columns=columns)
            for scope in ("Shared", "Server")
        ],
    }


class FieldGenerationTest(unittest.TestCase):
    def test_reserved_fields_and_primary_keys_export_without_changing_data(self):
        for primary_key in ("Id", "end"):
            with self.subTest(primary_key=primary_key):
                schema = field_schema(primary_key)
                import_config.validate_schema(schema)
                model = {"sheetNames": [], "sheets": {}}
                for sheet in schema["sheets"]:
                    model["sheetNames"].append(sheet["name"])
                    model["sheets"][sheet["name"]] = dict(
                        descriptions=[column["descriptionZh"] for column in sheet["columns"]],
                        keys=[column["key"] for column in sheet["columns"]],
                        types=[column["type"] for column in sheet["columns"]],
                        rows=[dict(row=4, values=["StableId", "keep text", 0, False, "editor only"])],
                        formulas=set(), workbook=sheet["workbook"],
                    )
                rows, issues = import_config.validate_workbook_model(model, schema)
                self.assertEqual([], issues)
                outputs = import_config.build_outputs(schema, rows)
                for scope in ("Shared", "Server"):
                    self.assertEqual({f"{scope}Records.lua"}, set(outputs[scope]))
                    content = outputs[scope][f"{scope}Records.lua"]
                    self.assertIn('["StableId"] = {', content)
                    self.assertIn(f'["{primary_key}"] = "StableId"', content)
                    self.assertIn('["function"] = "keep text"', content)
                    self.assertIn('["Count"] = 0', content)
                    self.assertIn('["Enabled"] = false', content)
                    self.assertNotIn('["Note"] =', content)
                    self.assertNotIn("editor only", content)


class OutputRecoveryTest(unittest.TestCase):
    def assert_outputs(self, root, expected):
        self.assertEqual([], import_config.check_outputs(root, expected))

    def recovery_root(self, root, error):
        self.assertIsInstance(error, import_config.ConfigFailure)
        self.assertIn("CONFIG_OUTPUT_RECOVERY_FAILED", {issue.code for issue in error.issues})
        directories = list(root.glob(".config-build-*"))
        self.assertEqual(1, len(directories))
        self.assertIn(str(directories[0]), "\n".join(issue.format() for issue in error.issues))
        return directories[0]

    def test_staging_write_failure_leaves_all_previous_outputs_untouched(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            real_write_text = Path.write_text

            def fail_write(path, *args, **kwargs):
                if path.name == "NewServer.lua":
                    raise OSError("simulated staging write failure")
                return real_write_text(path, *args, **kwargs)

            with mock.patch.object(Path, "write_text", autospec=True, side_effect=fail_write):
                with self.assertRaisesRegex(OSError, "staging write failure"):
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            self.assert_outputs(root, OLD_OUTPUTS)
            self.assertEqual([], list(root.glob(".config-build-*")))

    def test_temporary_cleanup_failure_does_not_replace_original_install_error(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace
            real_rmtree = import_config.shutil.rmtree

            def fail_install(source, destination):
                if Path(source).name == "Server" and Path(destination) == targets["Server"]:
                    raise OSError("original installation failure")
                return real_replace(source, destination)

            def fail_temporary_cleanup(path, *args, **kwargs):
                if Path(path).name.startswith(".config-build-"):
                    raise OSError("later temporary cleanup failure")
                return real_rmtree(path, *args, **kwargs)

            with mock.patch.object(import_config.os, "replace", side_effect=fail_install), \
                    mock.patch.object(import_config.shutil, "rmtree", side_effect=fail_temporary_cleanup):
                with self.assertRaisesRegex(OSError, "^original installation failure$"):
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            self.assert_outputs(root, OLD_OUTPUTS)
            self.assertEqual(1, len(list(root.glob(".config-build-*"))))

    def test_keyboard_interrupt_during_install_restores_previous_outputs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace

            def interrupt_install(source, destination):
                if Path(source).name == "Server" and Path(destination) == targets["Server"]:
                    raise KeyboardInterrupt("simulated install interruption")
                return real_replace(source, destination)

            with mock.patch.object(import_config.os, "replace", side_effect=interrupt_install):
                with self.assertRaisesRegex(KeyboardInterrupt, "install interruption"):
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            self.assert_outputs(root, OLD_OUTPUTS)
            self.assertEqual([], list(root.glob(".config-build-*")))

    def test_install_failure_restores_both_scopes_and_removes_temporary_files(self):
        for had_previous in (True, False):
            with self.subTest(had_previous=had_previous), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                if had_previous:
                    import_config.write_outputs_atomic(root, OLD_OUTPUTS)
                targets = import_config.output_targets(root)
                real_replace = import_config.os.replace

                def fail_install(source, destination):
                    if Path(source).name == "Server" and Path(destination) == targets["Server"]:
                        raise OSError("simulated Server installation failure")
                    return real_replace(source, destination)

                with mock.patch.object(import_config.os, "replace", side_effect=fail_install):
                    with self.assertRaisesRegex(OSError, "Server installation failure"):
                        import_config.write_outputs_atomic(root, NEW_OUTPUTS)
                if had_previous:
                    self.assert_outputs(root, OLD_OUTPUTS)
                else:
                    self.assertTrue(all(not target.exists() for target in targets.values()))
                self.assertEqual([], list(root.glob(".config-build-*")))

    def test_server_restore_failure_keeps_backup_and_still_restores_shared(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace

            def fail_server_install_and_restore(source, destination):
                if Path(source).name in ("Server", "Server.previous") and Path(destination) == targets["Server"]:
                    raise OSError(f"simulated {Path(source).name} failure")
                return real_replace(source, destination)

            with mock.patch.object(import_config.os, "replace", side_effect=fail_server_install_and_restore):
                with self.assertRaises(Exception) as context:
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            preserved = self.recovery_root(root, context.exception)
            self.assertEqual(OLD_OUTPUTS["Server"]["OldServer.lua"],
                             (preserved / "Server.previous/OldServer.lua").read_text(encoding="utf-8"))
            self.assertEqual(NEW_OUTPUTS["Server"]["NewServer.lua"],
                             (preserved / "Server/NewServer.lua").read_text(encoding="utf-8"))
            self.assertEqual(OLD_OUTPUTS["Shared"]["OldShared.lua"],
                             (targets["Shared"] / "OldShared.lua").read_text(encoding="utf-8"))
            self.assertFalse(targets["Server"].exists())

    def test_failure_before_server_backup_preserves_untouched_server(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace

            def fail_server_backup(source, destination):
                if Path(source) == targets["Server"]:
                    raise OSError("simulated Server backup failure")
                return real_replace(source, destination)

            with mock.patch.object(import_config.os, "replace", side_effect=fail_server_backup):
                with self.assertRaisesRegex(OSError, "Server backup failure"):
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            self.assert_outputs(root, OLD_OUTPUTS)
            self.assertEqual([], list(root.glob(".config-build-*")))

    def test_multiple_recovery_failures_preserve_both_old_outputs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace
            real_rmtree = import_config.shutil.rmtree

            def fail_server_install_and_restore(source, destination):
                if Path(source).name in ("Server", "Server.previous") and Path(destination) == targets["Server"]:
                    raise OSError(f"simulated {Path(source).name} failure")
                return real_replace(source, destination)

            def fail_shared_removal(path, *args, **kwargs):
                if Path(path) == targets["Shared"]:
                    raise OSError("simulated Shared removal failure")
                return real_rmtree(path, *args, **kwargs)

            with mock.patch.object(import_config.os, "replace", side_effect=fail_server_install_and_restore), \
                    mock.patch.object(import_config.shutil, "rmtree", side_effect=fail_shared_removal):
                with self.assertRaises(Exception) as context:
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            preserved = self.recovery_root(root, context.exception)
            for scope in ("Shared", "Server"):
                for file_name, content in OLD_OUTPUTS[scope].items():
                    self.assertEqual(content, (preserved / f"{scope}.previous" / file_name).read_text(encoding="utf-8"))
            self.assertFalse(targets["Server"].exists())
            self.assertTrue((targets["Shared"] / "NewShared.lua").exists())

    def test_removal_failure_preserves_old_backup_and_restores_other_scope(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            import_config.write_outputs_atomic(root, OLD_OUTPUTS)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace
            real_rmtree = import_config.shutil.rmtree

            def fail_install(source, destination):
                if Path(source).name == "Server" and Path(destination) == targets["Server"]:
                    raise OSError("simulated installation failure")
                return real_replace(source, destination)

            def fail_shared_removal(path, *args, **kwargs):
                if Path(path) == targets["Shared"]:
                    raise OSError("simulated Shared removal failure")
                return real_rmtree(path, *args, **kwargs)

            with mock.patch.object(import_config.os, "replace", side_effect=fail_install), \
                    mock.patch.object(import_config.shutil, "rmtree", side_effect=fail_shared_removal):
                with self.assertRaises(Exception) as context:
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            preserved = self.recovery_root(root, context.exception)
            self.assertEqual(OLD_OUTPUTS["Shared"]["OldShared.lua"],
                             (preserved / "Shared.previous/OldShared.lua").read_text(encoding="utf-8"))
            self.assertEqual(NEW_OUTPUTS["Shared"]["NewShared.lua"],
                             (targets["Shared"] / "NewShared.lua").read_text(encoding="utf-8"))
            self.assertEqual(OLD_OUTPUTS["Server"]["OldServer.lua"],
                             (targets["Server"] / "OldServer.lua").read_text(encoding="utf-8"))

    def test_failed_removal_without_previous_output_also_preserves_recovery_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            targets = import_config.output_targets(root)
            real_replace = import_config.os.replace
            real_rmtree = import_config.shutil.rmtree

            def fail_install(source, destination):
                if Path(source).name == "Server" and Path(destination) == targets["Server"]:
                    raise OSError("simulated installation failure")
                return real_replace(source, destination)

            def fail_removal(path, *args, **kwargs):
                if Path(path) == targets["Shared"]:
                    raise OSError("simulated removal failure")
                return real_rmtree(path, *args, **kwargs)

            with mock.patch.object(import_config.os, "replace", side_effect=fail_install), \
                    mock.patch.object(import_config.shutil, "rmtree", side_effect=fail_removal):
                with self.assertRaises(Exception) as context:
                    import_config.write_outputs_atomic(root, NEW_OUTPUTS)
            preserved = self.recovery_root(root, context.exception)
            self.assertTrue((preserved / "Server/NewServer.lua").exists())
            self.assertTrue((targets["Shared"] / "NewShared.lua").exists())
            self.assertFalse(targets["Server"].exists())


if __name__ == "__main__":
    unittest.main()
