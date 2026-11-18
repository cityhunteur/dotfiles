"""Exercise the installed-file contract without changing macOS appearance."""
import os
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
    @unittest.skipUnless(shutil.which("codex") or (Path.home() / ".bun/bin/codex").is_file(), "uses Codex CLI")
    def test_codex_updates_only_its_native_tui_theme(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "config.toml"
            config.write_text("# Local preference\n[tui]\nanimations = false\n")
            for mode, theme in (("dark", "nord"), ("light", "github"), ("dark", "nord")):
                subprocess.run([sys.executable, ROOT / "scripts/set-codex-appearance", mode],
                               env={**os.environ, "CODEX_HOME": directory}, check=True)
                self.assertEqual(tomllib.loads(config.read_text()), {"tui": {"animations": False, "theme": theme}})
                self.assertIn("# Local preference", config.read_text())

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

    def test_light_terminal_text_contrast(self):
        config = ROOT / ".config"
        ghostty = dict(line.split(" = ", 1) for line in
                       (config / "ghostty/themes/signal-light").read_text().splitlines()
                       if line and not line.startswith("#"))
        helix = tomllib.loads((config / "helix/themes/signal-light.toml").read_text())
        prompt = tomllib.loads((config / "starship.toml").read_text())["palettes"]["signal_light"]
        yaml_data = runpy.run_path(str(ROOT / "scripts/install-terminal-appearance"))["yaml_data"]
        skin = yaml_data((config / "k9s/skins/signal-light.yaml").read_text())["k9s"]
        canvas = ghostty["background"].lower()
        self.assertEqual(helix["ui.background"]["bg"].lower(), canvas)
        self.assertEqual(skin["views"]["table"]["bgColor"].lower(), canvas)

        def luminance(hex_colour):
            srgb = bytes.fromhex(hex_colour.lstrip("#"))
            channels = [value / 255 for value in srgb]
            linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels]
            return sum(a * b for a, b in zip(linear, (0.2126, 0.7152, 0.0722), strict=True))

        for colour in (ghostty["foreground"], prompt["primary"], prompt["muted"], prompt["accent"],
                       *helix["palette"].values(), *skin["frame"]["status"].values()):
            with self.subTest(colour=colour):
                self.assertGreaterEqual((luminance(canvas) + 0.05) / (luminance(colour) + 0.05), 4.5)

    def test_install_keeps_unrelated_k9s_settings_and_comments(self):
        enable = runpy.run_path(str(ROOT / "scripts/install-terminal-appearance"))["enable_skin"]
        settings = "k9s:\n  ui:\n    skin: nord-light # preferred\n  logger:\n    textWrap: true\n"
        result = enable(settings)
        self.assertIn("skin: signal # preferred", result)
        self.assertIn("reactive: true", result)
        self.assertIn("  logger:\n    textWrap: true\n", result)
        self.assertEqual(enable(result), result)
        self.assertIn("skin: signal", enable(""))
