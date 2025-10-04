# 🚀 Auto Installer WordPress + LAMP Stack (Optimized)
<p align="center"><img src="https://tjkt.smkyasmida.sch.id/wp-content/uploads/2025/02/Logo-TJKT-2022-Sampul-Youtube-1.png" width="600"></p>

---

Script Bash otomatis untuk **instalasi dan konfigurasi WordPress** di atas **LAMP Stack** (Linux, Apache, MariaDB, PHP-FPM) pada **Ubuntu Server**.  
Sudah termasuk **tuning Apache, PHP-FPM, dan MariaDB** agar performa lebih optimal sesuai spesifikasi server.

---

## ✨ Fitur
- 🔹 Instalasi otomatis **Apache2, MariaDB, PHP-FPM, dan WordPress**.  
- 🔹 **Input interaktif** untuk Database, User, Password, dan Domain.  
- 🔹 **Konfigurasi VirtualHost Apache** otomatis.  
- 🔹 **Optimasi Apache (MPM Event)**.  
- 🔹 **Optimasi PHP-FPM** (auto menyesuaikan CPU & RAM server).  
- 🔹 **Optimasi MariaDB** (alokasi buffer pool, max_connections, dll).  
- 🔹 WordPress otomatis di-setup di `/var/www/html/wordpress`.  

---


## 👨‍🍼PERSEMBAHAN
```bash
Demi pertemuan dengan-Nya
Demi kerinduan kepada utusan-Nya
Demi bakti kepada orangtua
Demi manfaat kepada sesama
Untuk itulah Sharing Ilmu

Semoga niat ini tetap lurus
Semoga menjadi ibadah
Semoga menjadi amal jariyah
Semoga bermanfaat
Aamiin

Tak lupa Script & Tulisan ini saya persembahkan kepada :
Istri saya tercinta
❤️**Siti Nur Holida**
Dan Anaku tersayang
❤️**Zein Khalisa Arivia**
❤️**Muhammad Zain Al-Fatih**
Aku mencintai kalian sepenuh hati.
```
---

## 💖 Donasi

Jika script ini bermanfaat untuk instalasi eRapor SMK, Anda dapat mendukung pengembang melalui:

- **Saweria** : [https://saweria.co/abdurrozakskom](https://saweria.co/abdurrozakskom)  
- **Trakteer** : [https://trakteer.id/abdurrozakskom/gift](https://trakteer.id/abdurrozakskom/gift)  
- **Paypal**  : [https://paypal.me/abdurrozakskom](https://paypal.me/abdurrozakskom)  

Setiap donasi sangat membantu untuk pengembangan fitur baru dan pemeliharaan script.

---

## 📦 Cara Menggunakan

### 1. Clone Repository
```bash
git clone https://github.com/abdurrozakskom/installer_wordpress.git
cd installer_wordpress
```

### 2. Beri Izin Eksekusi
```bash
chmod +x install_wordpress.sh
```

### 3. Jalankan Script
```bash
sudo ./install_wordpress.sh
```

## ⚙️ Input yang Dibutuhkan
- Saat menjalankan script, Anda akan diminta untuk memasukkan:
- Nama Database (default: wordpress_db)
- Username Database (default: wp_user)
- Password Database (default: wp_password)
- Domain / ServerName (default: _ → gunakan IP server)


## 📂 Lokasi File Penting
- WordPress : /var/www/html/wordpress
- VirtualHost : /etc/apache2/sites-available/wordpress.conf
- PHP-FPM Pool : /etc/php/*/fpm/pool.d/www.conf
- MariaDB Tuning : /etc/mysql/mariadb.conf.d/99-tuning.cnf

## 🔒 Keamanan
Disarankan setelah instalasi:
- Mengaktifkan HTTPS 
- Membatasi akses phpMyAdmin (jika diinstall).
- Menambahkan firewall (UFW/Iptables).

## 🛠️ Troubleshooting
Jika WordPress tidak terbuka → cek status Apache:
```bash
sudo systemctl status apache2
```
- Jika database gagal terkoneksi → cek user/password di wp-config.php.
- Jika memory kecil (<1 GB) → kurangi pm.max_children di PHP-FPM pool config.

## 👨‍💻 Author
Abdur Rozak
- Guru TKJ - SMKS YASMIDA Ambarawa

---

## 🌐 Sosial Media

Ikuti saya di sosial media untuk tips, update, dan info terbaru seputar eRapor SMK:

- **GitHub**    : [https://github.com/abdurrozakskom](https://github.com/abdurrozakskom)  
- **Lynk.id**   : [https://lynk.id/abdurrozak.skom](https://lynk.id/abdurrozak.skom)  
- **Instagram** : [https://instagram.com/abdurrozak.skom](https://instagram.com/abdurrozak.skom)  
- **Facebook**  : [https://facebook.com/abdurrozak.skom](https://facebook.com/abdurrozak.skom)  
- **TikTok**   : [https://tiktok.com/abdurrozak.skom](https://tiktok.com/abdurrozak.skom)  
- **YouTube**   : [https://www.youtube.com/@AbdurRozakSKom](https://www.youtube.com/@AbdurRozakSKom)  

---

## 📜 Lisensi
MIT License – Silakan gunakan, modifikasi, dan bagikan kembali.