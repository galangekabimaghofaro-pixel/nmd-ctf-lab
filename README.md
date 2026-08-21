1. **Panduan Deployment:** Langkah clone repo, menjalankan script setup Proxmox/Linux, dan detail akses layanan (Web & SSH).
2. **Walkthrough Red Team:** Panduan langkah demi langkah penembusan WAF & bypass MFA.
3. **Walkthrough Blue Team:** Panduan langkah demi langkah analisis log & ekstraksi flag via terminal.

---

### Teks Lengkap README.md (Siap Copy-Paste):

```markdown
# Red vs. Blue CTF Lab: Cookies Reuse & MFA Bypass

Repositori ini berisi infrastruktur dan kode laboratorium "Red vs. Blue" CTF untuk asesmen praktis Cyber Range Engineering di PT Nauli Mula Data.

---

## Panduan Deployment (Proxmox VM / Linux Environment)

1. **Clone Repositori:**
   ```bash
   git clone [https://github.com/galangekabimaghofaro-pixel/nmd-ctf-lab](https://github.com/galangekabimaghofaro-pixel/nmd-ctf-lab)
   cd nmd-ctf-lab

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

## Panduan Walkthrough Laboratorium

### Red Team Attack Path

1. **Reconnaissance:**
* Akses `http://localhost:3075/robots.txt` untuk menemukan dua endpoint tersembunyi: `/api/verify-mfa` dan `/dashboard`.
* Periksa DevTools Cookies untuk mengidentifikasi cookie `pre_mfa_session` yang tidak memiliki atribut `HttpOnly`.


2. **Defense Evasion (Uji Penembusan WAF):**
* Buka halaman form feedback pada aplikasi web.
* **Uji 1:** Masukkan payload `<script>alert(1)</script>` *(Hasil: Terblokir dengan respon HTTP 403 Forbidden)*.
* **Uji 2:** Masukkan payload `<svg onload="fetch('/dashboard')">` *(Hasil: Berhasil lolos dengan respon HTTP 200 OK)*.
* **Penjelasan:** WAF aplikasi memiliki kelemahan karena hanya menggunakan *blacklist* pada kata kunci `<script>`. Dengan memanfaatkan *event-handler* HTML5 pada tag `<svg>`, payload berhasil melewati filter WAF.


3. **MFA Bypass & Extraction Flag Utama:**
* Pada panel DevTools Cookies, ubah nama cookie `pre_mfa_session` menjadi `adm_sess`.
* Ubah nilainya menjadi token admin, lalu buka URL `http://localhost:3075/dashboard` pada address bar.
* **Penjelasan:** Aplikasi menderita kerentanan *Broken Authentication* karena validasi session hanya mengecek keberadaan nama cookie `adm_sess` di sisi client. Tanpa perlu memasukkan OTP/MFA, hak akses admin langsung didapatkan.
* **Flag Utama Red Team:** `SCENARIO75{RED_C00k13_MFA_Byp4ss_0wn3d}`



---

### Blue Team Forensic Path (5 Menit)

#### **Langkah 1 (Akses Terminal / File Log):**

* Jalankan terminal Git Bash untuk memeriksa lokasi log `/opt/admin/logs/`.

#### **Langkah 2 (Analisis Incident):**

* Jalankan pencarian IP penyerang pada log akses:
```bash
cat /opt/admin/logs/access.log | grep "10.10.14.50"

```


* **Penjelasan:** Terlacak pergerakan IP `10.10.14.50` dari `/robots.txt`, `/submit-feedback`, hingga `/dashboard`.


* Jalankan pemeriksaan alert WAF:
```bash
cat /opt/admin/logs/error.log

```


* **Penjelasan:** Terdeteksi alert WAF CRITICAL dan korelasi bypass otentikasi.



#### **Langkah 3 (Ekstraksi Flag):**

* Eksekusi dekode Base64 telemetry log:
```bash
echo "U0NFTkFSSU83N3tCTFVFX0wwR19IVW50M3JfTTRzdDNyfQ==" | base64 -d; echo ""

```


* **Penjelasan:** Mengartikan artefak string Base64 44 karakter dari header telemetry log untuk mendapatkan Flag Utama Blue Team.


* **Flag Utama Blue Team:** `SCENARIO75{BLUE_L0G_HUnt3r_M4st3r}`

```

*(Tips: Saat menempelkan ke editor GitHub, gunakan **`Ctrl + Shift + V`** agar URL `git clone` tidak otomatis terformat sebagai tautan yang rusak).*

```
