#!/usr/bin/env python3
"""Patch v2rayN v7 RoutingItem rules for app/process direct routing."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import shutil
import sqlite3
from pathlib import Path


GLOBAL_ROUTE_ID = "4707642314034655728"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Add direct routing rules for specific apps in v2rayN v7."
    )
    parser.add_argument("--v2rayn-root", required=True, help="v2rayN root folder.")
    parser.add_argument("--route-id", help="RoutingItem Id. Default: active route, then Global route.")
    parser.add_argument("--label", required=False, default="App", help="Human label for rule remarks.")
    parser.add_argument("--process", nargs="*", default=[], help="Process names, e.g. QQ.exe Weixin.exe.")
    parser.add_argument("--domain", nargs="*", default=[], help="Domains or v2rayN domain rules.")
    parser.add_argument("--ip", nargs="*", default=[], help="IPs or CIDRs to route direct.")
    parser.add_argument("--dry-run", action="store_true", help="Show changes without writing.")
    parser.add_argument("--show-routes", action="store_true", help="Print routing rows and exit.")
    parser.add_argument("--no-sync-generated", action="store_true", help="Do not update binConfigs/configPre.json.")
    return parser.parse_args()


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def normalize_domain(value: str) -> str:
    value = value.strip()
    if not value:
        return value
    known_prefixes = ("domain:", "geosite:", "regexp:", "keyword:", "full:")
    if value.startswith(known_prefixes):
        return value
    return f"domain:{value}"


def domain_to_suffix(value: str) -> str | None:
    value = normalize_domain(value)
    if value.startswith("domain:"):
        return value.removeprefix("domain:")
    return None


def merge_unique(existing: list[str] | None, additions: list[str]) -> list[str]:
    result: list[str] = []
    seen: set[str] = set()
    for item in (existing or []) + additions:
        if not item:
            continue
        key = item.lower()
        if key not in seen:
            seen.add(key)
            result.append(item)
    return result


def is_broad_barrier_rule(rule: dict) -> bool:
    outbound = rule.get("OutboundTag")
    remarks = (rule.get("Remarks") or "").lower()
    if outbound == "proxy" or remarks.startswith("final"):
        return True
    if outbound != "block":
        return False
    network_value = rule.get("Network") or []
    if isinstance(network_value, str):
        networks = [network_value.lower()]
    else:
        networks = [str(item).lower() for item in network_value]
    return "udp" in networks and str(rule.get("Port")) in {"443", "0-65535"}


def find_insert_at(rules: list[dict]) -> int:
    for index, rule in enumerate(rules):
        if is_broad_barrier_rule(rule):
            return index
    return len(rules)


def find_generated_insert_at(rules: list[dict]) -> int:
    insert_at = 0
    for index, rule in enumerate(rules):
        if rule.get("action") in {"sniff", "hijack-dns"}:
            insert_at = index + 1
            continue
        if rule.get("outbound") == "proxy" or rule.get("port_range"):
            return index
        if rule.get("action") == "reject":
            return index
    return insert_at


def backup(path: Path, backup_dir: Path) -> Path:
    backup_dir.mkdir(parents=True, exist_ok=True)
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    target = backup_dir / f"{path.stem}.before-app-direct.{stamp}{path.suffix}"
    shutil.copy2(path, target)
    return target


def connect_db(db_path: Path, readonly: bool = False) -> sqlite3.Connection:
    if readonly:
        return sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    return sqlite3.connect(str(db_path), timeout=10)


def get_route_rows(conn: sqlite3.Connection) -> list[dict]:
    cur = conn.cursor()
    cols = [row[1] for row in cur.execute("pragma table_info(RoutingItem)").fetchall()]
    rows = []
    for row in cur.execute("select * from RoutingItem order by Sort").fetchall():
        rows.append(dict(zip(cols, row)))
    return rows


def choose_route(rows: list[dict], route_id: str | None) -> dict:
    if route_id:
        for row in rows:
            if row["Id"] == route_id:
                return row
        raise SystemExit(f"Route id not found: {route_id}")
    for row in rows:
        if row.get("IsActive") == 1:
            return row
    for row in rows:
        remarks = row.get("Remarks") or ""
        if "Global" in remarks or "全局" in remarks:
            return row
    raise SystemExit("No active/global route found. Pass --route-id explicitly.")


def upsert_rule(rules: list[dict], remarks: str, key: str, values: list[str]) -> None:
    if not values:
        return
    for index, rule in enumerate(rules):
        if rule.get("Remarks") == remarks and rule.get("OutboundTag") == "direct":
            rule[key] = merge_unique(rule.get(key), values)
            rule["Enabled"] = True
            moved = rules.pop(index)
            insert_at = find_insert_at(rules)
            rules.insert(insert_at, moved)
            return
    insert_at = find_insert_at(rules)
    rules.insert(
        insert_at,
        {
            "Id": str(int(dt.datetime.now().timestamp() * 1_000_000) + insert_at),
            "OutboundTag": "direct",
            key: values,
            "Enabled": True,
            "Remarks": remarks,
        },
    )


def patch_route_rules(rules: list[dict], label: str, processes: list[str], domains: list[str], ips: list[str]) -> None:
    upsert_rule(rules, f"{label} process direct", "Process", processes)
    upsert_rule(rules, f"{label} domain direct", "Domain", [normalize_domain(d) for d in domains if d.strip()])
    upsert_rule(rules, f"{label} IP direct", "Ip", [ip.strip() for ip in ips if ip.strip()])


def sync_generated_config(path: Path, label: str, processes: list[str], domains: list[str], ips: list[str]) -> bool:
    if not path.exists():
        return False
    data = read_json(path)
    route = data.get("route")
    if not isinstance(route, dict) or not isinstance(route.get("rules"), list):
        return False
    rules = route["rules"]

    if processes:
        target_index = None
        process_set = {item.lower() for item in processes}
        for index, rule in enumerate(rules):
            current = rule.get("process_name", [])
            if rule.get("outbound") == "direct" and process_set.intersection({item.lower() for item in current}):
                target_index = index
                break
        if target_index is None:
            insert_at = find_generated_insert_at(rules)
            rules.insert(insert_at, {"outbound": "direct", "process_name": processes})
        else:
            target = rules[target_index]
            target["process_name"] = merge_unique(target.get("process_name"), processes)
            for index in range(len(rules) - 1, -1, -1):
                if index == target_index:
                    continue
                rule = rules[index]
                current = rule.get("process_name", [])
                if rule.get("outbound") == "direct" and process_set.intersection({item.lower() for item in current}):
                    target["process_name"] = merge_unique(target["process_name"], current)
                    del rules[index]
                    if index < target_index:
                        target_index -= 1

    suffixes = [suffix for d in domains if (suffix := domain_to_suffix(d))]
    if suffixes:
        matched = False
        for rule in rules:
            if rule.get("outbound") == "direct" and "domain_suffix" in rule:
                current = rule.get("domain_suffix", [])
                if any(s in current for s in suffixes):
                    rule["domain_suffix"] = merge_unique(current, suffixes)
                    matched = True
                    break
        if not matched:
            insert_at = find_generated_insert_at(rules)
            rules.insert(insert_at, {"outbound": "direct", "domain_suffix": suffixes})

    if ips:
        matched = False
        for rule in rules:
            if rule.get("outbound") == "direct" and "ip_cidr" in rule:
                current = rule.get("ip_cidr", [])
                if any(ip in current for ip in ips):
                    rule["ip_cidr"] = merge_unique(current, ips)
                    matched = True
                    break
        if not matched:
            insert_at = find_generated_insert_at(rules)
            rules.insert(insert_at, {"outbound": "direct", "ip_cidr": ips})

    write_json(path, data)
    return True


def main() -> None:
    args = parse_args()
    root = Path(args.v2rayn_root).expanduser().resolve()
    db_path = root / "guiConfigs" / "guiNDB.db"
    gui_config_path = root / "guiConfigs" / "guiNConfig.json"
    generated_path = root / "binConfigs" / "configPre.json"

    if not db_path.exists():
        raise SystemExit(f"Missing v2rayN database: {db_path}")

    with connect_db(db_path, readonly=True) as conn:
        rows = get_route_rows(conn)

    if args.show_routes:
        for row in rows:
            print(json.dumps({k: row.get(k) for k in ["Id", "Remarks", "RuleNum", "Sort", "IsActive"]}, ensure_ascii=False))
        return

    route = choose_route(rows, args.route_id)
    processes = [item.strip() for item in args.process if item.strip()]
    domains = [item.strip() for item in args.domain if item.strip()]
    ips = [item.strip() for item in args.ip if item.strip()]

    rules = json.loads(route.get("RuleSet") or "[]")
    patch_route_rules(rules, args.label, processes, domains, ips)

    summary = {
        "route_id": route["Id"],
        "route": route.get("Remarks"),
        "label": args.label,
        "processes": processes,
        "domains": domains,
        "ips": ips,
        "dry_run": args.dry_run,
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))

    if args.dry_run:
        return

    backup_dir = root / "guiConfigs" / "backups"
    print(f"backup_db={backup(db_path, backup_dir)}")
    if gui_config_path.exists():
        print(f"backup_gui_config={backup(gui_config_path, backup_dir)}")

    with connect_db(db_path) as conn:
        cur = conn.cursor()
        cur.execute("BEGIN IMMEDIATE")
        cur.execute(
            "update RoutingItem set RuleSet=?, RuleNum=?, Enabled=1, IsActive=1 where Id=?",
            (json.dumps(rules, ensure_ascii=False, indent=2), len(rules), route["Id"]),
        )
        cur.execute("update RoutingItem set IsActive=0 where Id<>?", (route["Id"],))
        conn.commit()

    if gui_config_path.exists():
        gui_config = read_json(gui_config_path)
        gui_config.setdefault("RoutingBasicItem", {})["RoutingIndexId"] = route["Id"]
        write_json(gui_config_path, gui_config)

    if not args.no_sync_generated:
        synced = sync_generated_config(generated_path, args.label, processes, domains, ips)
        print(f"sync_generated_configPre={synced}")

    print("done. Restart v2rayN service to load regenerated rules.")


if __name__ == "__main__":
    main()
