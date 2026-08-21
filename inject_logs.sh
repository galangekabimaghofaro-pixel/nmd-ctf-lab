#!/bin/bash
LOG_DIR="/opt/admin/logs"
mkdir -p "$LOG_DIR"

# Membuat access.log
cat << 'EOF' > "$LOG_DIR/access.log"
192.168.1.100 - - [21/Aug/2026:18:45:00 +0700] "GET /dashboard HTTP/1.1" 200 1024
10.10.14.50 - - [21/Aug/2026:18:50:00 +0700] "GET /robots.txt HTTP/1.1" 200 120 "Mozilla/5.0"
10.10.14.50 - - [21/Aug/2026:18:50:15 +0700] "POST /submit-feedback HTTP/1.1" 403 250 "Mozilla/5.0"
10.10.14.50 - - [21/Aug/2026:18:51:55 +0700] "GET /dashboard HTTP/1.1" 200 2048 "Mozilla/5.0" - "UEhBT1RPTUdSSUR7QkxVRV9MMGdfSHVudDNyX000c3Qzcn0}"
EOF

# Membuat error.log
cat << 'EOF' > "$LOG_DIR/error.log"
2026/08/21 18:50:15 [error] WAF Blocked Payload: <script> detected from IP 10.10.14.50
2026/08/21 18:53:10 [CRITICAL] Authentication bypass anomaly: Cookie reuse detected without MFA verification step.
EOF

echo "Log telemetri berhasil diinjeksikan ke $LOG_DIR"
