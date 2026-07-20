"""Tests for scripts/inject-aliases.py."""

import os
import subprocess
import tempfile
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parent.parent / "scripts" / "inject-aliases.py"

EXPECTED_COMMANDS = frozenset({
    "gwd",
    "ica",
    "gm",
    "tp",
    "tc",
    "cw",
    "implement",
})


def _run_script(root_dir: str | None = None) -> subprocess.CompletedProcess:
    """Run inject-aliases.py and return the completed process."""
    args = ["python3", str(SCRIPT)]
    if root_dir is not None:
        args.append(root_dir)
    return subprocess.run(args, capture_output=True, text=True)


def _assert_command_files(commands_dir: str) -> None:
    """Assert that exactly the expected .md command files exist."""
    entries = set()
    for child in Path(commands_dir).iterdir():
        assert child.suffix == ".md", f"Unexpected non-md file: {child.name}"
        assert child.stem in EXPECTED_COMMANDS, f"Unexpected command: {child.stem}"
        entries.add(child.stem)

    assert entries == EXPECTED_COMMANDS, (
        f"Expected {sorted(EXPECTED_COMMANDS)}, got {sorted(entries)}"
    )


class TestInjectAliases:
    """Test suite for inject-aliases.py."""

    def test_inject_creates_command_files(self):
        """In a temporary directory, verify 7 .md files are generated."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = _run_script(tmpdir)
            assert result.returncode == 0, f"Script failed: {result.stderr}"

            cmds_dir = os.path.join(tmpdir, ".opencode", "commands")
            assert os.path.isdir(cmds_dir), f"Expected {cmds_dir} to exist"
            _assert_command_files(cmds_dir)

    def test_inject_uses_custom_root(self):
        """Pass a custom root directory and verify files are created there."""
        with tempfile.TemporaryDirectory() as tmpdir:
            custom_root = os.path.join(tmpdir, "custom", "nested", "root")
            result = _run_script(custom_root)
            assert result.returncode == 0, f"Script failed: {result.stderr}"

            cmds_dir = os.path.join(custom_root, ".opencode", "commands")
            assert os.path.isdir(cmds_dir), f"Expected {cmds_dir} to exist"
            _assert_command_files(cmds_dir)

    def test_inject_defaults_to_dot(self):
        """With no arguments, files are created under the current directory."""
        with tempfile.TemporaryDirectory() as tmpdir:
            saved_cwd = os.getcwd()
            try:
                os.chdir(tmpdir)
                result = _run_script()
                assert result.returncode == 0, f"Script failed: {result.stderr}"

                cmds_dir = os.path.join(tmpdir, ".opencode", "commands")
                assert os.path.isdir(cmds_dir), f"Expected {cmds_dir} to exist"
                _assert_command_files(cmds_dir)
            finally:
                os.chdir(saved_cwd)
