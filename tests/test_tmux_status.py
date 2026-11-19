"""Exercise tmux rendering and status clicks without touching live sessions."""
import curses
import fcntl
import os
import pty
import re
import select
import shlex
import shutil
import struct
import subprocess
import tempfile
import termios
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMUX = shutil.which("tmux")


@unittest.skipUnless(TMUX, "tmux is required")
class StatusClickTests(unittest.TestCase):
    def run_tmux(self, *args):
        return subprocess.run(
            [TMUX, "-S", str(self.socket), *args],
            text=True, capture_output=True, check=True, timeout=5,
        ).stdout.strip()

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="tmux-click-", dir="/tmp")
        self.addCleanup(self.directory.cleanup)
        self.socket = Path(self.directory.name) / "socket"
        self.run_tmux("-f", "/dev/null", "new-session", "-d", "-s", "test",
                      "-n", "first", "-x", "80", "-y", "24", "sleep", "60")
        self.addCleanup(self.stop_server)
        self.run_tmux("new-window", "-d", "-t", "test", "-n", "second", "sleep", "60")
        for name, value in (
            ("mouse", "on"), ("status", "on"), ("status-position", "bottom"),
            ("status-left", ""), ("status-right", ""),
        ):
            self.run_tmux("set-option", "-g", name, value)
        self.run_tmux("set-option", "-g", "window-status-separator", "")
        self.pid, self.master = pty.fork()
        if self.pid == 0:
            os.environ["TERM"] = "xterm-256color"
            os.environ.pop("TMUX", None)
            fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
            os.execv(TMUX, [TMUX, "-S", str(self.socket), "attach-session", "-t", "test"])
        self.addCleanup(self.close_client)
        self.drain(0.4)
        self.assertEqual(self.run_tmux("list-clients", "-F", "#{client_width}x#{client_height}"), "80x24")

    def drain(self, seconds=0.1):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            ready, _, _ = select.select([self.master], [], [], max(0, deadline - time.monotonic()))
            if ready:
                try:
                    os.read(self.master, 65536)
                except OSError:
                    break

    def click(self, column):
        os.write(self.master, f"\x1b[<0;{column};24M".encode())
        self.drain()
        os.write(self.master, f"\x1b[<0;{column};24m".encode())
        self.drain(0.4)  # Keep intentional single clicks outside tmux's double-click window.

    def close_client(self):
        subprocess.run([TMUX, "-S", str(self.socket), "kill-server"], capture_output=True, check=False)
        os.close(self.master)
        os.waitpid(self.pid, 0)

    def stop_server(self):
        subprocess.run([TMUX, "-S", str(self.socket), "kill-server"], capture_output=True, check=False)

    def test_attached_client_changes_profile_on_theme_reports(self):
        self.run_tmux("split-window", "-t", "test:0", "sleep", "60")
        text = (ROOT / ".tmux.conf").read_text()
        for line in text.splitlines():
            if line.startswith(("set-hook -g client-light-theme ", "set-hook -g client-dark-theme ")):
                for mode in ("light", "dark"):
                    name = f".config/tmux/signal-{mode}.conf"
                    line = line.replace("~/" + name, str(ROOT / name))
                self.run_tmux(*shlex.split(line))
        for mode, report, accent in (("light", 2, "#646464"), ("dark", 1, "#88d8de"),
                                     ("light", 2, "#646464")):
            os.write(self.master, f"\x1b[?997;{report}n".encode())
            self.drain(0.25)
            client = self.run_tmux("list-clients", "-F", "#{client_theme}")
            self.assertEqual(client, mode)
            self.assertEqual(self.run_tmux("show-options", "-gv", "@accent"), accent)
            for pane in (0, 1):
                self.run_tmux("select-pane", "-t", f"test:0.{pane}")
                if mode == "light":
                    for option in ("window-status-current-format", "window-status-format"):
                        label = self.run_tmux("display-message", "-p", "-t", "test:0", f"|#{{E:{option}}}|")
                        self.assertEqual(re.sub(r"#\[[^\]]*\]", "", label), f"|   0.{pane} first |")
                        if option == "window-status-current-format":
                            canvas = self.run_tmux("show-options", "-gv", "@canvas")
                            muted = self.run_tmux("show-options", "-gv", "@muted")
                            self.assertEqual(label, f"|  #[fg={canvas},bg={muted}] 0.{pane} first #[default]|")
                else:
                    label = self.run_tmux("display-message", "-p", "-t", "test:0", "#{E:window-status-current-format}")
                    self.assertTrue(label.endswith("]0 first"), label)

    def test_ghostty_codex_input_inherits_the_canvas(self):
        config = (ROOT / ".tmux.conf").read_text().replace("\\\n", "")
        rule = next(line for line in config.splitlines() if "xterm-ghostty:setrgbb=" in line)
        args = shlex.split(rule)
        self.run_tmux(*args)
        capability = self.run_tmux("show-options", "-sv", args[2])
        terminal, program = capability.split(":setrgbb=")
        self.assertEqual(terminal, "xterm-ghostty")
        curses.setupterm("xterm-256color")
        program = program.replace(r"\E", "\x1b").encode()
        for rgb in [(226, 229, 234), (71, 76, 86)]:
            self.assertEqual(curses.tparm(program, *rgb), b"\x1b[49m")
            for channel in range(3):
                neighbour = list(rgb)
                neighbour[channel] += 1
                expected = b"\x1b[48;2;%d;%d;%dm" % tuple(neighbour)
                self.assertEqual(curses.tparm(program, *neighbour), expected)

    def test_both_profiles_preserve_styles_and_clickable_window_ranges(self):
        config = (ROOT / ".tmux.conf").read_text().splitlines()
        for line in config:
            if line.startswith(("set -g status-left ", "set -g status-left-length ", "set -g prefix ")):
                self.run_tmux(*shlex.split(line))
        for mode in ("light", "dark"):
            with self.subTest(mode=mode):
                self.run_tmux("source-file", str(ROOT / f".config/tmux/signal-{mode}.conf"))
                self.run_tmux("select-window", "-t", "test:0")
                canvas = self.run_tmux("show-options", "-gv", "@canvas")
                action = self.run_tmux("show-options", "-gv", "@accent")
                self.assertEqual(action, "#646464" if mode == "light" else "#88d8de")
                primary = self.run_tmux("show-options", "-gv", "@primary")
                muted = self.run_tmux("show-options", "-gv", "@muted")
                label = self.run_tmux("display-message", "-p", "-t", "test:0", "#{E:window-status-current-format}")
                if mode == "light":
                    self.assertEqual(label, f"#[fg={canvas},bg={muted}] 0 first #[default]")
                else:
                    self.assertEqual(label, f"#[fg={action}]▸ #[fg={primary}]0 first")
                selected = self.run_tmux("show-options", "-gv", "window-status-current-style").split(",")
                name_colour = muted if mode == "light" else primary
                self.assertCountEqual(selected, [f"bg={canvas}", f"fg={name_colour}", "noreverse"])
                inactive = self.run_tmux("show-options", "-gv", "window-status-style")
                self.assertEqual(re.search(r"(?:^|,)bg=([^,]+)", inactive)[1], canvas)
                for window in ("test:0", "test:1"):
                    for option in ("window-status-style", "window-status-current-style"):
                        raw = self.run_tmux("show-options", "-gv", option)
                        expanded = self.run_tmux("display-message", "-p", "-t", window, "#{E:" + option + "}")
                        self.assertEqual(expanded, raw)
                self.drain()
                for key, suffix in ((None, "   "), (b"\x01", " ^A")):
                    if key:
                        os.write(self.master, key)
                        self.drain()
                    left = self.run_tmux("display-message", "-p", "|#{E:status-left}|")
                    self.assertEqual(re.sub(r"#\[[^\]]*\]", "", left), f"|└ ⟪ test ⟫{suffix}|")
                self.run_tmux("switch-client", "-T", "root")
                # Both themes put the first number in column 17 with this session name.
                self.click(28)
                self.assertEqual(self.run_tmux("display-message", "-p", "-t", "test", "#{window_index}"), "1")
                self.click(17)
                self.assertEqual(self.run_tmux("display-message", "-p", "-t", "test", "#{window_index}"), "0")


if __name__ == "__main__":
    unittest.main()
