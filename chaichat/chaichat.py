#!/usr/bin/env python3
"""ChaiChat - a tiny message board for the office chai corner.

Settings (environment variables):
  PORT      port to listen on, on 127.0.0.1 only   (default: 5050)
  DATA_DIR  folder where messages are saved        (REQUIRED, must be writable)
"""
import html
import json
import os
import sys
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

PORT = int(os.environ.get("PORT", "5050"))
DATA_DIR = os.environ.get("DATA_DIR")

if not DATA_DIR:
    sys.exit("FATAL: DATA_DIR is not set")
DATA_FILE = os.path.join(DATA_DIR, "messages.json")
try:
    with open(os.path.join(DATA_DIR, ".write-test"), "w") as f:
        f.write("ok")
except OSError as e:
    sys.exit(f"FATAL: cannot write to DATA_DIR {DATA_DIR}: {e}")


def load():
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE) as f:
        return json.load(f)


def save(messages):
    with open(DATA_FILE, "w") as f:
        json.dump(messages, f, indent=1)


class ChaiChat(BaseHTTPRequestHandler):
    def send(self, code, body, ctype):
        data = body.encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        messages = load()
        if self.path == "/api/messages":
            self.send(200, json.dumps(messages), "application/json")
        elif self.path == "/":
            rows = "".join(
                f"<li><b>{html.escape(m['name'])}</b> ({m['time']}): {html.escape(m['text'])}</li>"
                for m in reversed(messages)
            )
            page = f"<h1>ChaiChat</h1><p>{len(messages)} messages</p><ul>{rows}</ul>"
            self.send(200, page, "text/html; charset=utf-8")
        else:
            self.send(404, '{"error": "not found"}', "application/json")

    def do_POST(self):
        if self.path != "/api/messages":
            self.send(404, '{"error": "not found"}', "application/json")
            return
        length = int(self.headers.get("Content-Length", 0))
        form = parse_qs(self.rfile.read(length).decode())
        name = form.get("name", [""])[0].strip()
        text = form.get("text", [""])[0].strip()
        if not name or not text:
            self.send(400, '{"error": "name and text are required"}', "application/json")
            return
        messages = load()
        messages.append({"name": name, "text": text,
                         "time": datetime.now().strftime("%Y-%m-%d %H:%M")})
        save(messages)
        self.send(201, json.dumps({"saved": True, "count": len(messages)}), "application/json")


print(f"ChaiChat listening on 127.0.0.1:{PORT}, data in {DATA_DIR}", flush=True)
HTTPServer(("127.0.0.1", PORT), ChaiChat).serve_forever()
