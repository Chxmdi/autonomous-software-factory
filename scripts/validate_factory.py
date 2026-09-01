#!/usr/bin/env python3
"""Validate Software Factory structure and scan tracked-like files for secrets."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


REQUIRED_FILES = (
    "AGENTS.md",
    "BUILD_PRODUCT.md",
    "GLOBAL_ENGINEERING_CONTRACT.md",
    "CHATGPT_CODEX_OPERATING_MODEL.md",
    "ROLE_MATRIX.md",
    "factory.yaml",
    "protocols/ROLE_EXECUTION.md",
    "protocols/HANDOFF.md",
    "protocols/RELEASE_GATES.md",
    "protocols/AUTHORIZATION.md",
    "docs/PROJECT_CONTEXT.md",
    "docs/STATUS.md",
    "docs/exec-plans/ACTIVE.md",
    "docs/qa/QA_REPORT.md",
    "docs/audits/PRODUCTION_AUDIT.md",
)

ROLE_FILES = tuple(f"roles/{index:02d}-{name}.md" for index, name in enumerate((
    "product-designer",
    "project-designer",
    "backend-engineer",
    "frontend-engineer",
    "devops-engineer",
    "database-specialist",
    "senior-qa",
    "applied-ai-engineer",
    "context-prompt-engineer",
    "software-auditor",
    "digital-twin",
), start=1))

SECRET_PATTERNS = {
    "OpenAI-style key": re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}"),
    "GitHub token": re.compile(r"\bgh[pousr]_[A-Za-z0-9]{30,}"),
    "AWS access key": re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    "private key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
}

SKIP_PARTS = {".git", "__pycache__", ".venv", "venv", "dist", "build"}
TEXT_SUFFIXES = {".md", ".txt", ".yaml", ".yml", ".json", ".py", ".toml", ".sh", ""}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", type=Path, default=Path.cwd())
    return parser.parse_args()


def text_files(root: Path) -> list[Path]:
    results: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file() or any(part in SKIP_PARTS for part in path.parts):
            continue
        if path.suffix.lower() in TEXT_SUFFIXES and path.stat().st_size <= 2_000_000:
            results.append(path)
    return results


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    for relative in REQUIRED_FILES + ROLE_FILES:
        path = root / relative
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty: {relative}")

    factory_yaml = root / "factory.yaml"
    if factory_yaml.is_file():
        content = factory_yaml.read_text(encoding="utf-8")
        for marker in ("version:", "roles:", "workflow:", "gates:", "independence:"):
            if marker not in content:
                errors.append(f"factory.yaml missing section: {marker}")

    for path in text_files(root):
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for label, pattern in SECRET_PATTERNS.items():
            if pattern.search(content):
                errors.append(f"possible {label}: {path.relative_to(root)}")
    return errors


def main() -> int:
    root = parse_args().root.resolve()
    errors = validate(root)
    if errors:
        print("Software Factory validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"Software Factory validation passed: {root}")
    print(f"Verified {len(REQUIRED_FILES)} core artifacts and {len(ROLE_FILES)} role contracts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
