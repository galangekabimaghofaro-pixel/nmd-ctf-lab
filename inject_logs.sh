#!/bin/bash
LOG_DIR="/opt/admin/logs"
sudo mkdir -p "$LOG_DIR"

# Membuat access.log
sudo bash -c "cat << 'EOF' > '$LOG_DIR/access.log'
192.168.1.100 - - [21/Aug/2026:18:45:00 +0700] \"GET / HTTP/1.1\" 200 512
10.10.14.50 - - [21/Aug/2026:18:50:00 +0700] \"GET /robots.txt HTTP/1.1\" 200 120 \"Mozilla/5.0\"
10.10.14.50 - - [21/Aug/2026:18:51:55 +0700] \"GET /dashboard?payload=<svg/onload=window['docu'+'ment']['coo'+'kie']... HTTP/1.1\" 200 350 \"Mozilla/5.0\" - \"UEhBTlRPTUdSSUR7QkxVRV9MMGdfSHVudDNyX000c3Qzcn0=\"
EOF"

# Membuat error.log
sudo bash -c "cat << 'EOF' > '$LOG_DIR/error.log'
[2026-08-21 18:50:15] [WAF] [WARNING] Blocked malicious payload containing <script> from IP 10.10.14.50
[2026-08-21 18:53:10] [CRITICAL] Authentication bypass anomaly detected: Session cookie reused without MFA validation step.
EOF"

echo "Log berhasil diinjeksikan ke $LOG_DIR"
