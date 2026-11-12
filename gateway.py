#!/usr/bin/env python3
"""Serveert de app (./app) en stuurt /api/* door naar MOTIS. Zo is alles één https-adres via Tailscale (geen CORS/mixed-content)."""
import http.server, os, urllib.request, urllib.error
ROOT = os.path.dirname(os.path.abspath(__file__)); MOTIS = os.environ.get("MOTIS_URL", "http://127.0.0.1:8080")
class H(http.server.SimpleHTTPRequestHandler):
    def __init__(s, *a, **k): super().__init__(*a, directory=os.path.join(ROOT, "app"), **k)
    def do_GET(s):
        if not s.path.startswith("/api/"): return super().do_GET()
        try:
            with urllib.request.urlopen(MOTIS + s.path, timeout=60) as r: code, body, ct = r.status, r.read(), r.headers.get("Content-Type", "application/json")
        except urllib.error.HTTPError as e: code, body, ct = e.code, e.read(), "application/json"
        except Exception as e: code, body, ct = 502, str(e).encode(), "text/plain"
        s.send_response(code); s.send_header("Content-Type", ct); s.send_header("Content-Length", str(len(body))); s.end_headers(); s.wfile.write(body)
http.server.ThreadingHTTPServer(("127.0.0.1", 8081), H).serve_forever()
