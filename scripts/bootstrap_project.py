#!/usr/bin/env python3
"""Install the Software Factory operating system into a product repository."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


ROOT_FILES = (
    "AGENTS.md",
    "BUILD_PRODUCT.md",
    "GLOBAL_ENGINEERING_CONTRACT.md",
    "CHATGPT_CODEX_OPERATING_MODEL.md",
    "ROLE_MATRIX.md",
    "factory.yaml",
)
TREE_DIRS = ("roles", "protocols", "config", "docs")
GENERATED_MANIFEST = ".software-factory-install.json"


@dataclass(frozen=True)
class InstallRecord:
    source: str
    destination: str
    action: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", type=Path, help="Existing or new product repository")
    parser.add_argument("--name", required=True, help="Product display name")
    parser.add_argument(
        "--on-conflict",
        choices=("error", "skip", "overwrite"),
        default="error",
        help="How to handle existing destination files (default: error)",
    )
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def validate_target(target: Path) -> Path:
    resolved = target.expanduser().resolve()
    forbidden = {Path("/").resolve(), Path.home().resolve()}
    if resolved in forbidden:
        raise ValueError(f"Refusing unsafe target: {resolved}")
    if resolved.exists() and not resolved.is_dir():
        raise ValueError(f"Target is not a directory: {resolved}")
    return resolved


def source_files(factory_root: Path) -> list[Path]:
    files = [factory_root / name for name in ROOT_FILES]
    for directory in TREE_DIRS:
        files.extend(path for path in (factory_root / directory).rglob("*") if path.is_file())
    return sorted(files, key=lambda path: path.relative_to(factory_root).as_posix())


def rendered_bytes(source: Path, relative: Path, product_name: str) -> bytes:
    content = source.read_bytes()
    if relative.as_posix() == "docs/PROJECT_CONTEXT.md":
        text = content.decode("utf-8").replace("- Product name: `TODO`", f"- Product name: `{product_name}`")
        return text.encode("utf-8")
    return content


def install(
    factory_root: Path,
    target: Path,
    product_name: str,
    conflict_policy: str,
    dry_run: bool,
) -> list[InstallRecord]:
    candidates = source_files(factory_root)
    conflicts = [
        source.relative_to(factory_root)
        for source in candidates
        if (target / source.relative_to(factory_root)).exists()
    ]
    if conflicts and conflict_policy == "error":
        preview = "\n".join(f"  - {path.as_posix()}" for path in conflicts[:20])
        suffix = "\n  - ..." if len(conflicts) > 20 else ""
        raise FileExistsError(
            "Installation would overwrite existing files. "
            "Re-run with --on-conflict skip or overwrite after review:\n"
            f"{preview}{suffix}"
        )

    records: list[InstallRecord] = []
    for source in candidates:
        relative = source.relative_to(factory_root)
        destination = target / relative
        if destination.exists() and conflict_policy == "skip":
            records.append(InstallRecord(relative.as_posix(), str(destination), "skipped"))
            continue

        action = "overwritten" if destination.exists() else "created"
        records.append(InstallRecord(relative.as_posix(), str(destination), action))
        if dry_run:
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(rendered_bytes(source, relative, product_name))
        shutil.copymode(source, destination)

    if not dry_run:
        manifest = {
            "factory_version": 1,
            "product_name": product_name,
            "conflict_policy": conflict_policy,
            "files": [asdict(record) for record in records],
        }
        (target / GENERATED_MANIFEST).write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return records


def main() -> int:
    args = parse_args()
    try:
        target = validate_target(args.target)
        if not args.dry_run:
            target.mkdir(parents=True, exist_ok=True)
        factory_root = Path(__file__).resolve().parents[1]
        records = install(factory_root, target, args.name, args.on_conflict, args.dry_run)
    except (OSError, ValueError) as exc:
        print(f"bootstrap failed: {exc}", file=sys.stderr)
        return 1

    counts: dict[str, int] = {}
    for record in records:
        counts[record.action] = counts.get(record.action, 0) + 1
    mode = "Dry run" if args.dry_run else "Installed"
    print(f"{mode} Software Factory for {args.name} at {target}")
    print(json.dumps(counts, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
