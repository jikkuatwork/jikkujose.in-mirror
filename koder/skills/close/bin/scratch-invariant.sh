#!/usr/bin/env bash
# Portable close-time scratch invariant.
#
# Every durable artifact in koder/scratch/ (*.md, *.patch, *.txt) must either
# be promoted into tracked koder/ or be covered by an unexpired retention
# entry with an explicit reason in koder/SCRATCH_RETAIN.jsonl.
#
# Retention entry shape (one JSON object per line):
#   {"path": "q096/", "reason": "...", "ttl": "2026-09-15", "added": "2026-08-03"}
# path semantics: trailing '/' = directory prefix, otherwise fnmatch glob
# (exact paths match themselves). Paths are relative to the scratch dir.
# When several entries match a file, active (unexpired) beats expired, then
# most-specific pattern (exact > directory prefix > glob; longer wins within
# a class), then latest TTL. Ledger file order never decides coverage.
#
# Output: JSON report on stdout. Exit 0 when clean, 1 on violations or
# invalid retention entries.
#
# Env overrides: KODER_SCRATCH_DIR, KODER_SCRATCH_RETAIN_PATH, and
# KODER_SCRATCH_EXCLUDE (comma-separated basenames; empty by default).

set -euo pipefail

SCRATCH_DIR="${KODER_SCRATCH_DIR:-koder/scratch}"
RETAIN_PATH="${KODER_SCRATCH_RETAIN_PATH:-koder/SCRATCH_RETAIN.jsonl}"
SCRATCH_EXCLUDE="${KODER_SCRATCH_EXCLUDE:-}"

SCRATCH_DIR="$SCRATCH_DIR" RETAIN_PATH="$RETAIN_PATH" \
  SCRATCH_EXCLUDE="$SCRATCH_EXCLUDE" python3 - <<'PY'
import datetime as dt
import fnmatch
import json
import os
import sys

scratch_dir = os.environ["SCRATCH_DIR"]
retain_path = os.environ["RETAIN_PATH"]
excluded = {
    basename.strip()
    for basename in os.environ["SCRATCH_EXCLUDE"].split(",")
    if basename.strip()
}

DURABLE_EXTS = (".md", ".patch", ".txt")
today = dt.date.today()

entries = []
invalid = []
if os.path.isfile(retain_path):
    with open(retain_path, encoding="utf-8") as handle:
        for lineno, raw in enumerate(handle, 1):
            raw = raw.strip()
            if not raw:
                continue
            try:
                row = json.loads(raw)
            except json.JSONDecodeError:
                invalid.append({"line": lineno, "error": "not JSON"})
                continue
            problems = []
            for field in ("path", "reason", "ttl"):
                if not isinstance(row.get(field), str) or not row.get(field).strip():
                    problems.append(f"missing {field}")
            ttl_date = None
            if not problems:
                try:
                    ttl_date = dt.date.fromisoformat(row["ttl"])
                except ValueError:
                    problems.append("ttl not YYYY-MM-DD")
            if problems:
                invalid.append({"line": lineno, "error": ", ".join(problems)})
                continue
            entries.append({
                "path": row["path"],
                "reason": row["reason"],
                "ttl": row["ttl"],
                "expired": ttl_date < today,
            })


def specificity(pattern):
    # exact literal > directory prefix > glob; longer wins within a class
    if pattern.endswith("/"):
        return (1, len(pattern))
    if any(ch in pattern for ch in "*?["):
        return (0, len(pattern))
    return (2, len(pattern))


def covering(rel):
    matches = []
    for entry in entries:
        pattern = entry["path"]
        if pattern.endswith("/"):
            if rel.startswith(pattern):
                matches.append(entry)
        elif fnmatch.fnmatch(rel, pattern):
            matches.append(entry)
    if not matches:
        return None
    return max(
        matches,
        key=lambda entry: (
            not entry["expired"],
            specificity(entry["path"]),
            entry["ttl"],
        ),
    )


durable = []
if os.path.isdir(scratch_dir):
    for root, dirs, files in os.walk(scratch_dir):
        for name in sorted(files):
            if not name.endswith(DURABLE_EXTS):
                continue
            if name in excluded:
                continue
            rel = os.path.relpath(os.path.join(root, name), scratch_dir)
            durable.append(rel)

violations = []
covered = 0
for rel in sorted(durable):
    entry = covering(rel)
    if entry is None:
        violations.append({"path": rel, "covered_by_expired": None})
    elif entry["expired"]:
        violations.append({"path": rel, "covered_by_expired": entry["path"]})
    else:
        covered += 1

report = {
    "scratch_dir": scratch_dir,
    "retain_path": retain_path,
    "durable_total": len(durable),
    "covered": covered,
    "violations": violations,
    "entries": {
        "total": len(entries),
        "active": sum(1 for entry in entries if not entry["expired"]),
        "expired": [
            {"path": entry["path"], "ttl": entry["ttl"], "reason": entry["reason"]}
            for entry in entries if entry["expired"]
        ],
        "invalid": invalid,
    },
    "status": "clean" if not violations and not invalid else "violations",
}
print(json.dumps(report, indent=1))

if violations or invalid:
    print(
        "Scratch invariant violated: promote the paths above into koder/, "
        "delete them, or add a retention entry (path, reason, ttl) to "
        f"{retain_path}.",
        file=sys.stderr,
    )
    sys.exit(1)
PY
