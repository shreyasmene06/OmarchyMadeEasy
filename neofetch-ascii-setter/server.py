#!/usr/bin/env python3
"""
Neofetch ASCII Art Setter — Backend Server
Uses only Python stdlib (no pip installs needed).

Serves the web UI and handles two API endpoints:
  POST /api/set-ascii   — Saves custom ASCII art and updates neofetch config
  POST /api/reset-ascii — Restores neofetch to default distro ASCII art

The ASCII art is saved to ~/.config/neofetch/custom_ascii.txt
and the neofetch config's image_source is pointed to that file.
"""

import http.server
import json
import os
import re
import shutil
from pathlib import Path

# ===== Configuration =====
PORT = 8642
HOST = "127.0.0.1"

HOME = Path.home()
NEOFETCH_CONFIG_DIR = HOME / ".config" / "neofetch"
NEOFETCH_CONFIG = NEOFETCH_CONFIG_DIR / "config.conf"
CUSTOM_ASCII_FILE = NEOFETCH_CONFIG_DIR / "custom_ascii.txt"
CONFIG_BACKUP = NEOFETCH_CONFIG_DIR / "config.conf.bak"

# Directory containing this script (where the frontend files live)
SCRIPT_DIR = Path(__file__).parent.resolve()

# MIME types for serving static files
MIME_TYPES = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "application/javascript; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".png": "image/png",
    ".svg": "image/svg+xml",
    ".ico": "image/x-icon",
}


def update_neofetch_config(image_source_value: str) -> None:
    """Update the image_source line in neofetch config.conf"""
    if not NEOFETCH_CONFIG.exists():
        raise FileNotFoundError(f"Neofetch config not found at {NEOFETCH_CONFIG}")

    # Create backup if none exists yet
    if not CONFIG_BACKUP.exists():
        shutil.copy2(NEOFETCH_CONFIG, CONFIG_BACKUP)

    content = NEOFETCH_CONFIG.read_text(encoding="utf-8")

    # Replace the image_source line
    # Matches: image_source="..." with any value
    new_content, count = re.subn(
        r'(image_source=")[^"]*(")',
        rf'\g<1>{image_source_value}\2',
        content,
    )

    if count == 0:
        # If no match, try without quotes (some configs might differ)
        new_content, count = re.subn(
            r"(image_source=).*",
            rf'\1"{image_source_value}"',
            content,
        )

    if count == 0:
        raise ValueError("Could not find image_source in neofetch config")

    NEOFETCH_CONFIG.write_text(new_content, encoding="utf-8")


class AsciiSetterHandler(http.server.BaseHTTPRequestHandler):
    """HTTP request handler for the ASCII Art Setter."""

    def log_message(self, format, *args):
        """Custom log format with color."""
        msg = format % args
        if "POST" in msg:
            print(f"  \033[1;35m→\033[0m {msg}")
        elif "200" in msg or "204" in msg:
            print(f"  \033[1;32m✓\033[0m {msg}")
        elif "404" in msg or "500" in msg:
            print(f"  \033[1;31m✗\033[0m {msg}")
        else:
            print(f"  \033[1;34m·\033[0m {msg}")

    def send_json(self, data: dict, status: int = 200) -> None:
        """Send a JSON response."""
        body = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def send_error_json(self, message: str, status: int = 500) -> None:
        """Send a JSON error response."""
        self.send_json({"error": message}, status)

    def do_GET(self):
        """Serve static files."""
        path = self.path.split("?")[0]  # Strip query params

        if path == "/":
            path = "/index.html"

        # Security: prevent directory traversal
        safe_path = Path(path.lstrip("/"))
        if ".." in safe_path.parts:
            self.send_error(403)
            return

        file_path = SCRIPT_DIR / safe_path

        if file_path.is_file():
            ext = file_path.suffix.lower()
            mime = MIME_TYPES.get(ext, "application/octet-stream")

            content = file_path.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(content)))
            self.send_header("Cache-Control", "no-cache")
            self.end_headers()
            self.wfile.write(content)
        else:
            self.send_error(404)

    def do_POST(self):
        """Handle API requests."""
        path = self.path.split("?")[0]

        if path == "/api/set-ascii":
            self._handle_set_ascii()
        elif path == "/api/reset-ascii":
            self._handle_reset_ascii()
        else:
            self.send_error_json("Unknown endpoint", 404)

    def _read_json_body(self) -> dict:
        """Read and parse JSON from request body."""
        length = int(self.headers.get("Content-Length", 0))
        if length == 0:
            return {}
        raw = self.rfile.read(length)
        return json.loads(raw.decode("utf-8"))

    def _handle_set_ascii(self):
        """Save ASCII art and update neofetch config."""
        try:
            data = self._read_json_body()
            ascii_text = data.get("ascii", "").strip()

            if not ascii_text:
                self.send_error_json("No ASCII art provided", 400)
                return

            # Ensure config directory exists
            NEOFETCH_CONFIG_DIR.mkdir(parents=True, exist_ok=True)

            # Save the ASCII art file
            # neofetch expects each line prefixed with ${c1} or similar for color,
            # but raw text works fine too — neofetch displays it as-is
            CUSTOM_ASCII_FILE.write_text(ascii_text + "\n", encoding="utf-8")

            # Update neofetch config to use this file
            update_neofetch_config(str(CUSTOM_ASCII_FILE))

            self.send_json({
                "success": True,
                "message": "ASCII art saved and neofetch config updated",
                "file": str(CUSTOM_ASCII_FILE),
            })

        except FileNotFoundError as e:
            self.send_error_json(str(e), 404)
        except Exception as e:
            self.send_error_json(str(e), 500)

    def _handle_reset_ascii(self):
        """Reset neofetch to default ASCII art."""
        try:
            # Set image_source back to "auto"
            update_neofetch_config("auto")

            # Optionally remove custom ascii file
            if CUSTOM_ASCII_FILE.exists():
                CUSTOM_ASCII_FILE.unlink()

            self.send_json({
                "success": True,
                "message": "Neofetch reset to default ASCII art",
            })

        except FileNotFoundError as e:
            self.send_error_json(str(e), 404)
        except Exception as e:
            self.send_error_json(str(e), 500)


def main():
    """Start the server."""
    # Banner
    print()
    print("  \033[1;35m╔══════════════════════════════════════════╗\033[0m")
    print("  \033[1;35m║\033[0m  \033[1;37mNeofetch ASCII Art Setter\033[0m              \033[1;35m║\033[0m")
    print("  \033[1;35m║\033[0m  \033[0;36mOmarchyMadeEasy\033[0m                        \033[1;35m║\033[0m")
    print("  \033[1;35m╚══════════════════════════════════════════╝\033[0m")
    print()
    print(f"  \033[1;32m✓\033[0m Neofetch config: \033[0;36m{NEOFETCH_CONFIG}\033[0m")
    print(f"  \033[1;32m✓\033[0m Custom art file:  \033[0;36m{CUSTOM_ASCII_FILE}\033[0m")
    print()
    print(f"  \033[1;37m🌐 Open in browser:\033[0m \033[1;4;35mhttp://{HOST}:{PORT}\033[0m")
    print()
    print("  \033[0;90mPress Ctrl+C to stop the server\033[0m")
    print()

    server = http.server.HTTPServer((HOST, PORT), AsciiSetterHandler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n  \033[1;33m⚡\033[0m Server stopped.\n")
        server.server_close()


if __name__ == "__main__":
    main()
