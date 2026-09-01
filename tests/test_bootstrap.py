from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from scripts.bootstrap_project import GENERATED_MANIFEST, install, validate_target
from scripts.validate_factory import validate


class BootstrapTests(unittest.TestCase):
    def setUp(self) -> None:
        self.factory_root = Path(__file__).resolve().parents[1]

    def test_clean_install_is_valid_and_names_product(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / "product"
            target.mkdir()
            records = install(self.factory_root, target, "Example Product", "error", False)

            self.assertGreater(len(records), 25)
            self.assertEqual(validate(target), [])
            project_context = (target / "docs/PROJECT_CONTEXT.md").read_text(encoding="utf-8")
            self.assertIn("`Example Product`", project_context)
            manifest = json.loads((target / GENERATED_MANIFEST).read_text(encoding="utf-8"))
            self.assertEqual(manifest["product_name"], "Example Product")

    def test_default_conflict_policy_preserves_existing_file(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary)
            existing = target / "AGENTS.md"
            existing.write_text("user-owned\n", encoding="utf-8")

            with self.assertRaises(FileExistsError):
                install(self.factory_root, target, "Example", "error", False)

            self.assertEqual(existing.read_text(encoding="utf-8"), "user-owned\n")

    def test_skip_policy_keeps_existing_and_installs_other_files(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary)
            existing = target / "AGENTS.md"
            existing.write_text("user-owned\n", encoding="utf-8")

            records = install(self.factory_root, target, "Example", "skip", False)

            self.assertEqual(existing.read_text(encoding="utf-8"), "user-owned\n")
            self.assertTrue((target / "BUILD_PRODUCT.md").is_file())
            self.assertTrue(any(record.action == "skipped" for record in records))

    def test_home_and_root_are_refused(self) -> None:
        with self.assertRaises(ValueError):
            validate_target(Path("/"))
        with self.assertRaises(ValueError):
            validate_target(Path.home())


if __name__ == "__main__":
    unittest.main()
