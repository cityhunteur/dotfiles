"""Exercise the installed-file contract without changing macOS appearance."""
import runpy
import shutil
import subprocess
import sys
import tempfile
import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(sys.platform == "darwin" and shutil.which("swiftc"), "uses macOS appearance APIs")
class AppearanceTests(unittest.TestCase):
    def test_light_dark_light_preserves_prompt_and_switches_all_three_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            binary = root / "appearance"
            config = root / "config"
            config.mkdir()
            starship = config / "starship.toml"
            starship.write_text((ROOT / ".config/starship.toml").read_text() + "\n# Local setting\n")
            subprocess.run(["swiftc", "-swift-version", "6", ROOT / "scripts/terminal-appearance.swift",
                            "-o", binary], check=True)
            for mode in ("light", "dark", "light"):
                subprocess.run([binary, mode, ROOT / ".config", config, root / "k9s"], check=True)
                self.assertEqual(tomllib.loads(starship.read_text())["palette"], "signal_" + mode)
                self.assertTrue(starship.read_text().endswith("# Local setting\n"))
                for installed, source in [
                    (config / "helix/themes/signal.toml", f"helix/themes/signal-{mode}.toml"),
                    (root / "k9s/skins/signal.yaml", f"k9s/skins/signal-{mode}.yaml"),
                ]:
                    self.assertEqual(installed.read_bytes(), (ROOT / ".config" / source).read_bytes())

    def test_install_keeps_unrelated_k9s_settings_and_comments(self):
        enable = runpy.run_path(str(ROOT / "scripts/install-terminal-appearance"))["enable_skin"]
        settings = "k9s:\n  ui:\n    skin: nord-light # preferred\n  logger:\n    textWrap: true\n"
        result = enable(settings)
        self.assertIn("skin: signal # preferred", result)
        self.assertIn("reactive: true", result)
        self.assertIn("  logger:\n    textWrap: true\n", result)
        self.assertEqual(enable(result), result)
        self.assertIn("skin: signal", enable(""))
