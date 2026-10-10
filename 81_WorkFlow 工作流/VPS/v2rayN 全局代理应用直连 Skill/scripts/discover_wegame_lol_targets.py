#!/usr/bin/env python3
"""Discover WeGame / League of Legends process names for v2rayN direct routing."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

try:
    import winreg
except ImportError:  # pragma: no cover - Windows-only helper.
    winreg = None


PROCESS_ORDER = [
    "wegame.exe",
    "browser.exe",
    "client_launcher.exe",
    "client_reporter.exe",
    "tgp_daemon.exe",
    "wegameservice.exe",
    "wegame_env.exe",
    "tcls_core.exe",
    "TenioDL.exe",
    "TinyDL.exe",
    "TinyDL64.exe",
    "CrossProxy.exe",
    "rail.exe",
    "pallas.exe",
    "ACE-Helper.exe",
    "TASLogin.exe",
    "QtsUpdater.exe",
    "yxqxunyou.exe",
    "XY_YXQ_Nethelper.exe",
    "icreateLol.exe",
    "SGuard64.exe",
    "SGuardSvc64.exe",
    "SGuardUpdate64.exe",
    "SGuard.exe",
    "SGuardSvc.exe",
    "SGuardUpdate.exe",
    "FeedBack.exe",
    "League of Legends.exe",
    "LeagueCrashHandler64.exe",
    "LeagueClient.exe",
    "LeagueClientUx.exe",
    "LeagueClientUxRender.exe",
    "RiotClientServices.exe",
    "RiotClientCrashHandler.exe",
    "LolAICoach.exe",
    "launcher.exe",
    "Client.exe",
    "client.exe",
]

GENERIC_NAMES = {"browser.exe", "launcher.exe", "client.exe", "Client.exe", "FeedBack.exe"}

DOMAINS = [
    "wegame.com.cn",
    "wegame.qq.com",
    "tgp.qq.com",
    "game.qq.com",
    "lol.qq.com",
    "lolm.qq.com",
    "lpl.qq.com",
    "qq.com",
    "tencent.com",
    "gtimg.cn",
    "gtimg.com",
    "qpic.cn",
    "qlogo.cn",
    "myqcloud.com",
    "qcloud.com",
    "ied.qq.com",
    "ieg.tencent.com",
    "tenpay.com",
    "riotgames.com",
    "riotcdn.net",
    "leagueoflegends.com",
]

ROOT_KEYWORDS = [
    "wegame",
    "英雄联盟",
    "league",
    "league of legends",
    "riot client",
    "anticheatexpert",
    "networkassist",
    "xunyou",
    "yxq_nethelper",
]

PROCESS_PATTERN = re.compile(
    r"(wegame|tgp|league|lol|riot|crossproxy|pallas|sguard|anticheat|taslogin|tcls|icreatelol|ace-helper|feedback|browser|xunyou|yxq|nethelper|networkassist)",
    re.IGNORECASE,
)

RELEVANT_PATH_PATTERN = re.compile(
    r"(WeGame|鑻遍泟鑱旂洘|League|Riot|AntiCheatExpert|SGuard|NetworkAssist|xunyou|yxq_nethelper)",
    re.IGNORECASE,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Discover WeGame / LoL direct-routing targets.")
    parser.add_argument("--format", choices=["json", "powershell"], default="json")
    parser.add_argument("--root", action="append", default=[], help="Extra install root to scan.")
    parser.add_argument("--include-known", action="store_true", help="Include all known process names even if not found.")
    parser.add_argument("--max-depth", type=int, default=8, help="Maximum scan depth under discovered roots.")
    return parser.parse_args()


def maybe_path(value: str | None) -> Path | None:
    if not value:
        return None
    text = value.strip().strip('"')
    if not text:
        return None
    match = re.search(r"([A-Za-z]:\\[^\"|]+?\.exe)", text)
    if match:
        text = match.group(1)
    path = Path(text)
    return path if path.is_absolute() else None


def add_root_from_path(path: Path | None, roots: set[Path], evidence: dict[str, list[str]], source: str) -> None:
    if path is None:
        return
    candidate = path if path.suffix.lower() != ".exe" else path.parent
    try:
        candidate = candidate.resolve()
    except OSError:
        candidate = candidate.absolute()
    if candidate.exists():
        roots.add(candidate)
        evidence.setdefault(source, []).append(str(candidate))


def registry_roots() -> tuple[set[Path], dict[str, list[str]]]:
    roots: set[Path] = set()
    evidence: dict[str, list[str]] = {}
    if winreg is None:
        return roots, evidence
    hives = [winreg.HKEY_LOCAL_MACHINE, winreg.HKEY_CURRENT_USER]
    subkeys = [
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    ]
    for hive in hives:
        for subkey in subkeys:
            try:
                key = winreg.OpenKey(hive, subkey)
            except OSError:
                continue
            with key:
                for index in range(winreg.QueryInfoKey(key)[0]):
                    try:
                        child_name = winreg.EnumKey(key, index)
                        child = winreg.OpenKey(key, child_name)
                    except OSError:
                        continue
                    with child:
                        values: dict[str, str] = {}
                        for value_name in ["DisplayName", "InstallLocation", "DisplayIcon", "UninstallString"]:
                            try:
                                values[value_name] = str(winreg.QueryValueEx(child, value_name)[0])
                            except OSError:
                                pass
                        display = values.get("DisplayName", "")
                        blob = " ".join(values.values()).lower()
                        if not any(keyword.lower() in blob for keyword in ROOT_KEYWORDS) and not any(
                            keyword.lower() in display.lower() for keyword in ROOT_KEYWORDS
                        ):
                            continue
                        add_root_from_path(maybe_path(values.get("InstallLocation")), roots, evidence, "registry")
                        add_root_from_path(maybe_path(values.get("DisplayIcon")), roots, evidence, "registry")
                        add_root_from_path(maybe_path(values.get("UninstallString")), roots, evidence, "registry")
    return roots, evidence


def run_powershell_json(script: str) -> list[dict]:
    try:
        completed = subprocess.run(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script],
            text=True,
            encoding="utf-8",
            errors="replace",
            capture_output=True,
            check=False,
            timeout=20,
        )
    except (OSError, subprocess.TimeoutExpired):
        return []
    if completed.returncode != 0 or not completed.stdout.strip():
        return []
    try:
        data = json.loads(completed.stdout)
    except json.JSONDecodeError:
        return []
    if isinstance(data, dict):
        return [data]
    return data if isinstance(data, list) else []


def shortcut_roots() -> tuple[set[Path], dict[str, list[str]]]:
    roots: set[Path] = set()
    evidence: dict[str, list[str]] = {}
    locations = [
        os.environ.get("ProgramData", ""),
        os.environ.get("APPDATA", ""),
        str(Path.home() / "Desktop"),
        str(Path.home() / "OneDrive" / "Desktop"),
    ]
    ps_locations = "@(" + ",".join(json.dumps(item) for item in locations if item) + ")"
    script = rf"""
$shell = New-Object -ComObject WScript.Shell
$roots = {ps_locations}
$items = foreach ($root in $roots) {{
  if (Test-Path -LiteralPath $root) {{
    Get-ChildItem -LiteralPath $root -Recurse -Filter '*.lnk' -ErrorAction SilentlyContinue |
      Where-Object {{ $_.FullName -match 'WeGame|英雄联盟|League|LOL|腾讯游戏' }} |
      ForEach-Object {{
        try {{
          $s = $shell.CreateShortcut($_.FullName)
          [pscustomobject]@{{ Link=$_.FullName; Target=$s.TargetPath; WorkingDirectory=$s.WorkingDirectory }}
        }} catch {{}}
      }}
  }}
}}
$items | ConvertTo-Json -Compress
"""
    for row in run_powershell_json(script):
        add_root_from_path(maybe_path(row.get("Target")), roots, evidence, "shortcut")
        add_root_from_path(maybe_path(row.get("WorkingDirectory")), roots, evidence, "shortcut")
    return roots, evidence


def running_process_roots() -> tuple[set[Path], dict[str, list[str]], set[str]]:
    roots: set[Path] = set()
    evidence: dict[str, list[str]] = {}
    found: set[str] = set()
    script = r"""
Get-CimInstance Win32_Process |
  Where-Object { $_.Name -match 'wegame|browser|tgp|league|lol|riot|crossproxy|pallas|sguard|anticheat|taslogin|tcls|icreatelol|ace-helper|feedback' -or $_.ExecutablePath -match 'WeGame|英雄联盟|League|Riot|AntiCheatExpert|SGuard' } |
  Select-Object ProcessId,Name,ExecutablePath,CommandLine |
  ConvertTo-Json -Compress
"""
    for row in run_powershell_json(script):
        name = row.get("Name")
        if isinstance(name, str) and name.lower().endswith(".exe"):
            found.add(name)
        add_root_from_path(maybe_path(row.get("ExecutablePath")), roots, evidence, "running_process")
        add_root_from_path(maybe_path(row.get("CommandLine")), roots, evidence, "running_process")
    return roots, evidence, found


def running_process_roots() -> tuple[set[Path], dict[str, list[str]], set[str]]:
    roots: set[Path] = set()
    evidence: dict[str, list[str]] = {}
    found: set[str] = set()
    script = r"""
Get-CimInstance Win32_Process |
  Where-Object { $_.Name -match 'wegame|browser|tgp|league|lol|riot|crossproxy|pallas|sguard|anticheat|taslogin|tcls|icreatelol|ace-helper|feedback|xunyou|yxq|nethelper' -or $_.ExecutablePath -match 'WeGame|League|Riot|AntiCheatExpert|SGuard|NetworkAssist|xunyou|yxq_nethelper' } |
  Select-Object ProcessId,Name,ExecutablePath,CommandLine |
  ConvertTo-Json -Compress
"""
    for row in run_powershell_json(script):
        name = row.get("Name")
        executable_path = row.get("ExecutablePath")
        command_line = row.get("CommandLine")
        relevant_path = any(
            isinstance(value, str) and RELEVANT_PATH_PATTERN.search(value)
            for value in [executable_path, command_line]
        )
        generic_name = isinstance(name, str) and name in GENERIC_NAMES
        if isinstance(name, str) and name.lower().endswith(".exe") and (not generic_name or relevant_path):
            found.add(name)
        if relevant_path:
            add_root_from_path(maybe_path(executable_path), roots, evidence, "running_process")
            add_root_from_path(maybe_path(command_line), roots, evidence, "running_process")
    return roots, evidence, found


def is_under_root(path: Path, root: Path) -> bool:
    try:
        path.resolve().relative_to(root.resolve())
        return True
    except (OSError, ValueError):
        return False


def scan_roots(roots: set[Path], max_depth: int) -> tuple[set[str], list[str]]:
    known_lower = {name.lower(): name for name in PROCESS_ORDER}
    found: set[str] = set()
    files: list[str] = []
    for root in sorted(roots, key=lambda item: str(item).lower()):
        if not root.exists() or not root.is_dir():
            continue
        base_depth = len(root.parts)
        try:
            iterator = root.rglob("*.exe")
            for path in iterator:
                if len(path.parts) - base_depth > max_depth:
                    continue
                canonical = known_lower.get(path.name.lower())
                if canonical:
                    found.add(canonical)
                    files.append(str(path))
        except OSError:
            continue
    return found, files


def ordered(values: set[str]) -> list[str]:
    lower = {value.lower(): value for value in values}
    result = [name for name in PROCESS_ORDER if name.lower() in lower]
    extras = sorted(value for value in values if value.lower() not in {item.lower() for item in PROCESS_ORDER})
    return result + extras


def main() -> None:
    args = parse_args()
    roots: set[Path] = set()
    evidence: dict[str, list[str]] = {}

    for root in args.root:
        add_root_from_path(Path(root), roots, evidence, "manual")

    for discovered_roots, discovered_evidence in [registry_roots(), shortcut_roots()]:
        roots.update(discovered_roots)
        for key, values in discovered_evidence.items():
            evidence.setdefault(key, []).extend(values)

    process_roots, process_evidence, running_names = running_process_roots()
    roots.update(process_roots)
    for key, values in process_evidence.items():
        evidence.setdefault(key, []).extend(values)

    scanned_names, scanned_files = scan_roots(roots, args.max_depth)
    found_names = scanned_names | running_names

    if args.include_known:
        processes = set(PROCESS_ORDER)
    else:
        distinctive = {name for name in PROCESS_ORDER if name not in GENERIC_NAMES}
        processes = distinctive | {name for name in found_names if name in GENERIC_NAMES}

    result = {
        "processes": ordered(processes),
        "domains": DOMAINS,
        "discovered_roots": sorted({str(root) for root in roots}),
        "found_process_names": ordered(found_names),
        "found_files": sorted(scanned_files),
        "evidence": {key: sorted(set(values)) for key, values in evidence.items()},
        "warnings": [],
    }
    for generic in sorted(GENERIC_NAMES):
        if generic in processes and generic not in found_names:
            result["warnings"].append(f"{generic} was included without local file/process evidence.")
    if not roots:
        result["warnings"].append("No install roots were discovered. Re-run after installing or launching WeGame/LoL.")

    if args.format == "powershell":
        print("$processes = @(" + ",".join(json.dumps(item, ensure_ascii=False) for item in result["processes"]) + ")")
        print("$domains = @(" + ",".join(json.dumps(item, ensure_ascii=False) for item in result["domains"]) + ")")
        if result["warnings"]:
            print("# warnings: " + " | ".join(result["warnings"]))
        return

    json.dump(result, sys.stdout, ensure_ascii=False, indent=2)
    print()


if __name__ == "__main__":
    main()
