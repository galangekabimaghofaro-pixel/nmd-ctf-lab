Red vs. Blue CTF Lab: Cookies Reuse & MFA Bypass
Repositori ini berisi infrastruktur dan kode laboratorium "Red vs. Blue" CTF untuk asesmen praktis Cyber Range Engineering di PT Nauli Mula Data.

Panduan Deployment (Proxmox VM / Linux Environment)
Clone Repositori:
git clone https://github.com/galangekabimaghofaro-pixel/nmd-ctf-lab
cd nmd-ctf-lab

Eksekusi Script Automasi:
chmod +x setup_vm.sh
sudo ./setup_vm.sh

Akses Layanan:

Web Application: http://:3075

SSH Analyst (Blue Team): ssh analyst@ -p 2275 (Password: blue_team_rocks)

Ringkasan Walkthrough
Red Team Attack Path
Recon: Temukan header X-Powered-By: Node.js, periksa /robots.txt, dan dapatkan cookie pre_mfa_session (HttpOnly: False).

Defense Evasion: Bypass WAF endpoint /feedback menggunakan  serta obfuskasi window['docu'+'ment']['coo'+'kie'].

MFA Bypass: Lakukan session replay dengan prefix adm_sess pada /dashboard untuk mendapatkan flag utama: SCENARIO75{RED_C00k13_MFA_Byp4ss_0wn3d}.

Blue Team Forensic Path
Log Forensics: Analisis log di /opt/admin/logs untuk melacak IP penyerang 10.10.14.50.

Incident Response: Temukan alert WAF CRITICAL dan dekode string Base64 44 karakter pada header untuk mendapatkan flag: SCENARIO75{BLUE_L0G_HUnt3r_M4st3r}.
