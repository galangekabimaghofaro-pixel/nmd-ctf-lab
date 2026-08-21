#!/bin/bash
set -e

# Konfigurasi Port SSH khusus 2275
sed -i 's/#Port 22/Port 2275/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/Port 22/Port 2275/' /etc/ssh/sshd_config 2>/dev/null || true
systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null || true

# Membuat User Blue Team analyst / blue_team_rocks
useradd -m -s /bin/bash analyst 2>/dev/null || true
echo "analyst:blue_team_rocks" | chpasswd

# Jalankan Injeksi Log & Docker
chmod +x inject_logs.sh
./inject_logs.sh
chown -R analyst:analyst /opt/admin/logs

docker-compose up -d --build

echo "Setup Proxmox VM Selesai!"
