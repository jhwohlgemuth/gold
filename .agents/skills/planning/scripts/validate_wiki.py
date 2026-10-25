#!/usr/bin/env python3
"""Validate planning metadata, five-hour phases, and wiki links."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path


ALLOWED_DIFFICULTIES = {"high", "low", "medium", "mixed", "not-assessed"}
ALLOWED_EXECUTION = {"coordination", "phased"}
ALLOWED_IMPACTS = {"critical", "high", "low", "medium", "mixed", "not-assessed"}
ALLOWED_PHASE_STATUSES = {"blocked", "in-progress", "planned", "ready"}
ALLOWED_PLAN_STATUSES = {"in-progress", "planned", "waiting-on-validation"}
FIELD_PATTERN = re.compile(r"^- ([A-Za-z ]+):\s*(.*)$", re.MULTILINE)
LINK_PATTERN = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
PHASE_HEADING_PATTERN = re.compile(r"^## ([A-Z][A-Z0-9]*-\d{2}) [—-] (.+)$", re.MULTILINE)
PHASE_ID_PATTERN = re.compile(r"\b[A-Z][A-Z0-9]*-\d{2}\b")
REQUIRED_PHASE_FIELDS = {
    "Budget",
    "Exact write set",
    "Focused validation",
    "Handoff",
    "Outcome",
    "Prerequisites",
    "Primary integration lock",
    "Status",
}
REQUIRED_PLAN_FIELDS = {
    "description",
    "difficulty",
    "execution",
    "impact",
    "package",
    "status",
    "tags",
    "title",
    "type",
}


@dataclass(frozen=True)
class Phase:
    fields: dict[str, str]
    identifier: str
    title: str


@dataclass(frozen=True)
class Plan:
    fields: dict[str, object]
    path: Path
    phases: tuple[Phase, ...]
    text: str


def _clean_scalar(value: str) -> str:
    cleaned = value.strip()
    if len(cleaned) >= 2 and cleaned[0] == cleaned[-1] and cleaned[0] in {'"', "'"}:
        return cleaned[1:-1]
    return cleaned


def _frontmatter(text: str) -> dict[str, object]:
    if not text.startswith("---\n"):
        return {}
    boundary = text.find("\n---\n", 4)
    if boundary < 0:
        return {}
    fields: dict[str, object] = {}
    current: str | None = None
    for line in text[4:boundary].splitlines():
        field = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if field:
            current = field.group(1)
            raw = (field.group(2) or "").strip()
            if raw.startswith("[") and raw.endswith("]"):
                fields[current] = [_clean_scalar(item) for item in raw[1:-1].split(",") if item.strip()]
            else:
                fields[current] = _clean_scalar(raw) if raw else []
            continue
        item = re.match(r"^\s+-\s+(.+)$", line)
        if item and current:
            existing = fields.get(current)
            values = existing if isinstance(existing, list) else []
            fields[current] = [*values, _clean_scalar(item.group(1))]
    return fields


def _internal_link_errors(plan: Plan, root: Path) -> list[str]:
    errors = []
    for raw_target in LINK_PATTERN.findall(plan.text):
        target = raw_target.strip().strip("<>").split("#", 1)[0].split("?", 1)[0]
        if not target or target.startswith(("#", "http://", "https://", "mailto:")):
            continue
        destination = (plan.path.parent / target).resolve()
        if not destination.exists():
            errors.append(f"{plan.path.relative_to(root)}: broken link `{raw_target}`")
    return errors


def _parse_phases(text: str) -> tuple[Phase, ...]:
    section = text.partition("# Execution phases")[2]
    matches = list(PHASE_HEADING_PATTERN.finditer(section))
    return tuple(
        Phase(
            fields={key: value.strip() for key, value in FIELD_PATTERN.findall(section[match.end() : matches[index + 1].start() if index + 1 < len(matches) else None])},
            identifier=match.group(1),
            title=match.group(2).strip(),
        )
        for index, match in enumerate(matches)
    )


def _plan_files(wiki: Path) -> tuple[Path, ...]:
    return tuple(
        sorted(
            path
            for path in wiki.rglob("*.md")
            if _frontmatter(path.read_text(encoding="utf-8")).get("type") == "Plan"
        )
    )


def _read_plan(path: Path) -> Plan:
    text = path.read_text(encoding="utf-8")
    return Plan(fields=_frontmatter(text), path=path, phases=_parse_phases(text), text=text)


def _membership_errors(plan: Plan, root: Path, wiki: Path) -> list[str]:
    errors = []
    relative = plan.path.relative_to(wiki).as_posix()
    nearest_index = plan.path.parent / "index.md"
    candidates = (
        (nearest_index, plan.path.name, "nearest index"),
        (wiki / "index.md", relative, "portfolio index"),
        (wiki / "parallel-execution.md", plan.path.name, "parallel guide"),
        (wiki / "plan-network.md", plan.path.name, "dependency network"),
    )
    for path, needle, label in candidates:
        if path.exists() and needle not in path.read_text(encoding="utf-8"):
            errors.append(f"{plan.path.relative_to(root)}: missing from {label}")
    return errors


def _validate_phase(plan: Plan, phase: Phase, root: Path) -> list[str]:
    label = f"{plan.path.relative_to(root)}:{phase.identifier}"
    errors = [f"{label}: missing `{field}`" for field in sorted(REQUIRED_PHASE_FIELDS - phase.fields.keys())]
    status = phase.fields.get("Status", "")
    if status not in ALLOWED_PHASE_STATUSES:
        errors.append(f"{label}: invalid phase status `{status}`")
    budget = phase.fields.get("Budget", "")
    match = re.search(r"(\d+(?:\.\d+)?)", budget)
    if not match or not 0 < float(match.group(1)) <= 5:
        errors.append(f"{label}: budget must be positive and at most five active hours")
    write_set = phase.fields.get("Exact write set", "")
    if not write_set or re.search(r"\b(?:TBD|unknown|later)\b", write_set, re.IGNORECASE):
        errors.append(f"{label}: exact write set is unresolved")
    if "*" in write_set or "?" in write_set:
        errors.append(f"{label}: exact write set contains a glob")
    return errors


def _validate_plan(plan: Plan, root: Path, wiki: Path) -> list[str]:
    label = str(plan.path.relative_to(root))
    errors = [f"{label}: missing frontmatter `{field}`" for field in sorted(REQUIRED_PLAN_FIELDS - plan.fields.keys())]
    difficulty = str(plan.fields.get("difficulty", ""))
    execution = str(plan.fields.get("execution", ""))
    impact = str(plan.fields.get("impact", ""))
    package = plan.fields.get("package", [])
    status = str(plan.fields.get("status", ""))
    if difficulty not in ALLOWED_DIFFICULTIES:
        errors.append(f"{label}: invalid difficulty `{difficulty}`")
    if execution not in ALLOWED_EXECUTION:
        errors.append(f"{label}: invalid execution mode `{execution}`")
    if impact not in ALLOWED_IMPACTS:
        errors.append(f"{label}: invalid impact `{impact}`")
    if not isinstance(package, list) or not package:
        errors.append(f"{label}: package must be a non-empty list")
    if status not in ALLOWED_PLAN_STATUSES:
        errors.append(f"{label}: invalid plan status `{status}`")
    if re.search(r"^\s*-\s*\[[xX]\]", plan.text, re.MULTILINE):
        errors.append(f"{label}: completed checklist item remains in active plan")
    if re.search(r"^#{1,6}\s+(?:Completed|Done)\b", plan.text, re.IGNORECASE | re.MULTILINE):
        errors.append(f"{label}: completed section remains in active plan")
    if execution == "coordination":
        if plan.phases or "# Execution phases" in plan.text:
            errors.append(f"{label}: coordination records cannot contain execution phases")
        if "phase_budget_hours" in plan.fields:
            errors.append(f"{label}: coordination records cannot set phase_budget_hours")
    if execution == "phased":
        if plan.fields.get("phase_budget_hours") != "5":
            errors.append(f"{label}: phased plans require phase_budget_hours: 5")
        if not plan.phases:
            errors.append(f"{label}: phased plan has no execution phases")
        errors.extend(error for phase in plan.phases for error in _validate_phase(plan, phase, root))
    errors.extend(_internal_link_errors(plan, root))
    errors.extend(_membership_errors(plan, root, wiki))
    return errors


def validate_repository(root: Path) -> list[str]:
    resolved_root = root.resolve()
    wiki = resolved_root / ".wiki"
    if not wiki.is_dir():
        return [f"{resolved_root}: .wiki directory not found"]
    plans = tuple(_read_plan(path) for path in _plan_files(wiki))
    errors = [error for plan in plans for error in _validate_plan(plan, resolved_root, wiki)]
    phase_ids = [phase.identifier for plan in plans for phase in plan.phases]
    duplicates = sorted({identifier for identifier in phase_ids if phase_ids.count(identifier) > 1})
    errors.extend(f"duplicate phase ID `{identifier}`" for identifier in duplicates)
    known = set(phase_ids)
    for plan in plans:
        for phase in plan.phases:
            prerequisites = PHASE_ID_PATTERN.findall(phase.fields.get("Prerequisites", ""))
            errors.extend(
                f"{plan.path.relative_to(resolved_root)}:{phase.identifier}: unknown prerequisite `{identifier}`"
                for identifier in prerequisites
                if identifier not in known
            )
    executable = sum(plan.fields.get("execution") == "phased" for plan in plans)
    index_path = wiki / "index.md"
    if index_path.exists():
        index = index_path.read_text(encoding="utf-8")
        count = re.search(r"contains (\d+) executable plans?", index)
        if count and int(count.group(1)) != executable:
            errors.append(f".wiki/index.md: portfolio count does not match {executable} executable plans")
    return sorted(errors)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", type=Path)
    arguments = parser.parse_args()
    errors = validate_repository(arguments.root)
    if errors:
        print("\n".join(errors))
        return 1
    print("Planning wiki validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
