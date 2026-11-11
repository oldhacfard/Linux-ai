# Gerçek bir Ubuntu Linux sistemi kurar
FROM ubuntu:22.04

# Linux paketlerini günceller ve gerekli araçları (curl, python3, nano vb.) yükler
RUN apt-get update && apt-get install -y \
    python3 \
    curl \
    nano \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Basit bir Linux Python log sunucusu oluşturur (ek dosya gerektirmez)
RUN echo 'from http.server import BaseHTTPRequestHandler, HTTPServer\n\
import os, datetime\n\
\n\
class LogHandler(BaseHTTPRequestHandler):\n\
    def do_GET(self):\n\
        self.send_response(200)\n\
        self.send_header("Content-type", "text/plain; charset=utf-8")\n\
        self.end_headers()\n\
        if self.path == "/logs" and os.path.exists("logs.txt"):\n\
            with open("logs.txt", "r") as f:\n\
                self.wfile.write(f.read().encode())\n\
        else:\n\
            self.wfile.write("Ubuntu Linux Log Sunucusu Aktif!".encode())\n\
\n\
    def do_POST(self):\n\
        content_length = int(self.headers["Content-Length"])\n\
        post_data = self.rfile.read(content_length).decode("utf-8")\n\
        zaman = datetime.datetime.now().isoformat()\n\
        with open("logs.txt", "a") as f:\n\
            f.write(f"[{zaman}] {post_data}\\n")\n\
        self.send_response(200)\n\
        self.end_headers()\n\
        self.wfile.write(b"Log kaydedildi")\n\
\n\
port = int(os.environ.get("PORT", 10000))\n\
HTTPServer(("0.0.0.0", port), LogHandler).serve_forever()' > server.py

CMD ["python3", "server.py"]
