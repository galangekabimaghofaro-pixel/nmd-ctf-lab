# Red vs. Blue CTF Lab: Cookies Reuse & MFA Bypass

Repositori ini berisi infrastruktur dan kode laboratorium "Red vs. Blue" CTF untuk asesmen praktis Cyber Range Engineering di PT Nauli Mula Data.

---

## Technical Specifications & Requirement Matrix

### Red Team Technical Criteria
* **Phase 1: Reconnaissance**
  * `X-Powered-By` Header: `SCENARIO75{Node.js}`
  * Disallowed Path (`robots.txt`): `SCENARIO75{/api/verify-mfa}`
  * Restricted Admin Path: `SCENARIO75{/dashboard}`
  * HTML Comment Clue: `SCENARIO75{robots.txt}`
  * Pre-Auth Cookie Name & Value: `SCENARIO75{pre_mfa_session}` = `SCENARIO75{pending_mfa_verification}`
* **Phase 2: Defense Evasion (WAF & XSS)**
  * Endpoint Method: `SCENARIO75{POST}`
  * WAF Block Status Code: `SCENARIO75{403}`
  * WAF Bypass Tag: `SCENARIO75{<svg>}`
  * Obfuscation Payload: `SCENARIO75{window['docu'+'ment']['coo'+'kie']}`
  * Cookie Atribute: HttpOnly set to `SCENARIO75{False}`
  * Exfiltration Mechanism: `SCENARIO75{fetch}`
* **Phase 3: Initial Access (MFA Bypass & Session Replay)**
  * Skipped Endpoint: `SCENARIO75{/api/verify-mfa}`
  * Session Prefix: `SCENARIO75{adm_sess}`
  * Visual Element Class: `SCENARIO75{xss-payload}`
  * **Red Team Final Flag:** `SCENARIO75{RED_C00k13_MFA_Byp4ss_0wn3d}`

### Blue Team Technical Criteria
* **Phase 1: Log Forensics**
  * Log Directory: `SCENARIO75{/opt/admin/logs}`
  * Attacker Footprint: IP `SCENARIO75{10.10.14.50}` | User-Agent `SCENARIO75{Mozilla/5.0}`
  * Dashboard Access Log: Status `SCENARIO75{200}` pada timestamp `SCENARIO75{18:51:55}`
  * Header Telemetry Base64: `SCENARIO75{UEhBTlRPTUdSSUR7QkxVRV9MMGdfSHVudDNyX000c3Qzcn0=}`
* **Phase 2: Threat Hunting**
  * Baseline Traffic IP: `SCENARIO75{192.168.1.100}`
  * Attacker Subnet: `SCENARIO75{10.10.14.0/24}`
  * First WAF Block Log: Tag `SCENARIO75{<script>}` pada timestamp `SCENARIO75{18:50:15}`
  * MFA Endpoint Reached by Attacker: `SCENARIO75{No}`
* **Phase 3: Incident Response**
  * Encoding & Length: `SCENARIO75{Base64}` | Length `SCENARIO75{44}`
  * Severity Level: `SCENARIO75{CRITICAL}`
  * Anomaly Warning (18:53:10): `SCENARIO75{Authentication bypass anomaly}`
  * **Blue Team Final Flag:** `SCENARIO75{BLUE_L0G_HUnt3r_M4st3r}`

---

## Panduan Deployment (Proxmox VM / Linux Environment)

1. **Clone Repositori:**
   ```bash
   git clone https://github.com/galangekabimaghofaro-pixel/nmd-ctf-lab 

```

2. **Eksekusi Script Automasi:**
```bash
chmod +x setup_vm.sh
sudo ./setup_vm.sh

```


3. **Akses Layanan:**
* **Web Application:** `http://<IP_VM>:3075`
* **SSH Analyst (Blue Team):** `ssh analyst@<IP_VM> -p 2275` *(Password: `blue_team_rocks`)*



---

## Ringkasan Walkthrough Laboratorium

### Red Team Attack Path

1. **Reconnaissance:**
* Akses `http://localhost:3075/robots.txt` untuk menemukan dua endpoint tersembunyi: `/api/verify-mfa` dan `/dashboard`.
* Periksa DevTools Cookies untuk mengidentifikasi cookie `pre_mfa_session` dengan nilai `pending_mfa_verification` yang tidak memiliki atribut `HttpOnly` (`HttpOnly: False`).


2. **Defense Evasion (Uji Penembusan WAF):**
* Buka halaman form feedback pada aplikasi web (metode `POST`).
* **Uji 1:** Masukkan payload `<script>alert(1)</script>` *(Hasil: Terblokir dengan respon HTTP 403 Forbidden)*.
* **Uji 2:** Masukkan payload `<svg onload="fetch('/dashboard')">` dengan teknik obfusksi `window['docu'+'ment']['coo'+'kie']` *(Hasil: Berhasil lolos dengan respon HTTP 200 OK)*.
* **Penjelasan:** WAF aplikasi memiliki kelemahan karena hanya menggunakan *blacklist* pada kata kunci `<script>`. Dengan memanfaatkan *event-handler* HTML5 pada tag `<svg>`, payload berhasil melewati filter WAF.


3. **MFA Bypass & Extraction Flag Utama:**
* Pada panel DevTools Cookies, ubah nama cookie `pre_mfa_session` menggunakan prefix `adm_sess`.
* Ubah nilainya menjadi token admin, lalu buka URL `http://localhost:3075/dashboard` pada address bar.
* **Penjelasan:** Aplikasi menderita kerentanan *Broken Authentication* karena validasi session hanya mengecek keberadaan nama cookie `adm_sess` di sisi client dan melewati endpoint `/api/verify-mfa`. Elemen visual payload ditampilkan pada container `.xss-payload`.
* **Flag Utama Red Team:** `SCENARIO75{RED_C00k13_MFA_Byp4ss_0wn3d}`



---

### Blue Team Forensic Path (5 Menit)

#### **Langkah 1 (Akses Terminal / File Log):**

* Akses lokasi log sistem pada direktori `/opt/admin/logs/` melalui SSH.

#### **Langkah 2 (Analisis Incident & Threat Hunting):**

* Jalankan pencarian IP penyerang (`10.10.14.50`) pada subnet `10.10.14.0/24`:
```bash
cat /opt/admin/logs/access.log | grep "10.10.14.50"

```


* **Penjelasan:** Terlacak pergerakan IP penyerang dari `/robots.txt`, `/submit-feedback`, hingga `/dashboard` (status 200 pada timestamp `18:51:55`). Terkonfirmasi penyerang tidak pernah (`No`) menyentuh `/api/verify-mfa`.


* Jalankan pemeriksaan log error WAF:
```bash
cat /opt/admin/logs/error.log

```


* **Penjelasan:** Terdeteksi blok pertama WAF untuk tag `<script>` pada timestamp `18:50:15`, alert level `CRITICAL`, serta peringatan `Authentication bypass anomaly` pada timestamp `18:53:10`.



#### **Langkah 3 (Ekstraksi Flag):**

* Eksekusi dekode Base64 (44 karakter) dari header telemetry log (`X-Forwarded-For`):
```bash
echo "UEhBTlRPTUdSSUR7QkxVRV9MMGdfSHVudDNyX000c3Qzcn0=" | base64 -d; echo ""

```


* **Penjelasan:** Mengartikan artefak string Base64 44 karakter untuk mendapatkan Flag Utama Blue Team.


* **Flag Utama Blue Team:** `SCENARIO75{BLUE_L0G_HUnt3r_M4st3r}`

```

---
