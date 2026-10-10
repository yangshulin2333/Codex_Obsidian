import argparse
import json
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class SnapshotStore:
    def __init__(self, out_dir: Path, name: str):
        self.out_dir = out_dir
        self.name = name
        self.segments = {}
        self.done = None
        self.lock = threading.Lock()
        self.out_dir.mkdir(parents=True, exist_ok=True)

    def write_segment(self, payload):
        segment_name = payload.get("segmentName") or "Unknown"
        data = payload.get("data") or {}
        with self.lock:
            self.segments[segment_name] = data
            path = self.out_dir / f"{self.name}_{segment_name}.json"
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        return segment_name, len(json.dumps(data, ensure_ascii=False))

    def write_done(self, payload):
        with self.lock:
            self.done = payload
            combined = {
                "exportName": payload.get("exportName", ""),
                "exportedAt": payload.get("exportedAt", ""),
                "exportedJobs": payload.get("exportedJobs", []),
                "missingJobs": payload.get("missingJobs", []),
                "segments": self.segments,
            }
            combined_path = self.out_dir / f"{self.name}.combined.json"
            summary_path = self.out_dir / f"{self.name}.summary.md"
            combined_path.write_text(json.dumps(combined, ensure_ascii=False, indent=2), encoding="utf-8")

            lines = [
                "# Roblox GUI HTTP Snapshot",
                "",
                f"CombinedJson: `{combined_path}`",
                f"SegmentCount: {len(self.segments)}",
                "",
                "## Segments",
            ]
            for key in sorted(self.segments):
                data = self.segments[key]
                lines.append(
                    f"- {key}: nodes={data.get('nodeCount')}; trimmed={data.get('trimmed')}; target={data.get('targetPath')}"
                )
            lines.append("")
            lines.append("## Missing Jobs")
            missing = payload.get("missingJobs") or []
            if missing:
                for job in missing:
                    lines.append(f"- {job.get('name')}: {job.get('path')}")
            else:
                lines.append("- none")
            summary_path.write_text("\n".join(lines), encoding="utf-8")
        return combined_path, summary_path


def make_handler(store: SnapshotStore):
    class Handler(BaseHTTPRequestHandler):
        server_version = "RobloxGuiSnapshotReceiver/1.0"

        def log_message(self, fmt, *args):
            return

        def do_POST(self):
            if self.path != "/gui-snapshot":
                self.send_response(404)
                self.end_headers()
                return

            length = int(self.headers.get("Content-Length", "0"))
            raw = self.rfile.read(length)
            try:
                payload = json.loads(raw.decode("utf-8"))
            except Exception as exc:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(f"bad json: {exc}".encode("utf-8"))
                return

            kind = payload.get("kind")
            if kind == "segment":
                name, byte_count = store.write_segment(payload)
                print(f"[segment] {name} received, json_bytes={byte_count}", flush=True)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"ok")
                return

            if kind == "done":
                combined_path, summary_path = store.write_done(payload)
                print(f"[done] wrote {combined_path}", flush=True)
                print(f"[done] wrote {summary_path}", flush=True)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"done")
                threading.Thread(target=self.server.shutdown, daemon=True).start()
                return

            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"unknown kind")

    return Handler


def main():
    parser = argparse.ArgumentParser(description="Receive Roblox Studio GUI snapshots over local HTTP.")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=18765)
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--name", default="Gui_Current_Http")
    args = parser.parse_args()

    store = SnapshotStore(Path(args.out_dir), args.name)
    server = ThreadingHTTPServer((args.host, args.port), make_handler(store))
    print(f"Listening on http://{args.host}:{args.port}/gui-snapshot", flush=True)
    print(f"Writing to {Path(args.out_dir).resolve()}", flush=True)
    server.serve_forever()
    print("Receiver stopped.", flush=True)


if __name__ == "__main__":
    main()
