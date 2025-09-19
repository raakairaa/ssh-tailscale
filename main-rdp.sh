#!/bin/bash
#
# VERSI RDP 1.0 - Solusi RDP + XFCE yang Tangguh
# Script ini menginstal XFCE dan server xrdp, dengan semua perbaikan
# untuk mencegah masalah umum seperti layar hitam dan error izin.

# Hentikan eksekusi jika ada perintah yang gagal
set -e

# Fungsi untuk mencetak pesan dengan warna
print_info() {
    echo -e "\n\e[34m\e[1m[INFO]\e[0m $1\e[0m"
}
print_success() {
    echo -e "\e[32m\e[1m[SUCCESS]\e[0m $1\e[0m"
}
print_warning() {
    echo -e "\e[33m\e[1m[WARNING]\e[0m $1\e[0m"
}

# LANGKAH 1: PERSIAPAN SISTEM
print_info "Memperbarui dan meng-upgrade paket sistem..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# LANGKAH 2: INSTALASI XFCE DESKTOP
print_info "Menginstal desktop XFCE dan komponen inti..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes xfce4 desktop-base xfce4-goodies

# LANGKAH 3: INSTALASI SERVER XRDP
print_info "Menginstal server xrdp..."
sudo apt-get install --assume-yes xrdp

# LANGKAH 4: KONFIGURASI ANTI-GAGAL UNTUK XRDP (LANGKAH PALING PENTING)

# 4a: Memberi tahu xrdp untuk memulai XFCE
print_info "Mengonfigurasi XFCE sebagai sesi default untuk xrdp..."
# Perintah ini membuat file yang dibaca oleh xrdp saat login untuk memulai sesi.
echo xfce4-session > ~/.xsession
print_success "File ~/.xsession berhasil dibuat."

# 4b: Memperbaiki masalah izin sertifikat (penyebab umum layar hitam)
print_info "Menambahkan pengguna 'xrdp' ke grup 'ssl-cert'..."
sudo adduser xrdp ssl-cert
print_success "Izin sertifikat telah diperbaiki."

# 4c: Mengizinkan sesi RDP untuk otentikasi administratif (menghindari pop-up password)
print_info "Membuat aturan PolicyKit untuk pengalaman desktop yang lancar..."
cat <<EOF | sudo tee /etc/polkit-1/rules.d/02-allow-admin.rules
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("sudo")) {
        return polkit.Result.YES;
    }
});
EOF
print_success "Aturan PolicyKit berhasil dibuat."

# LANGKAH 5: KONFIGURASI FIREWALL
print_info "Memeriksa dan mengonfigurasi firewall (ufw)..."
if sudo ufw status | grep -q "Status: active"; then
    print_warning "Firewall UFW aktif. Membuka port RDP 3389..."
    sudo ufw allow 3389/tcp
    print_success "Port 3389 telah dibuka di UFW."
else
    print_info "Firewall UFW tidak aktif, tidak ada perubahan yang diperlukan."
fi

# LANGKAH 6: MENJALANKAN LAYANAN XRDP
print_info "Me-restart dan mengaktifkan layanan xrdp..."
sudo systemctl restart xrdp
sudo systemctl enable xrdp
print_success "Layanan xrdp sekarang berjalan dan aktif."

# LANGKAH 7: INSTRUKSI FINAL
SERVER_IP=$(hostname -I | awk '{print $1}')
CURRENT_USER=$(whoami)

echo -e "\n\e[32m\e[1m====== INSTALASI SERVER RDP SELESAI ======\e[0m"
echo -e "\nAnda sekarang dapat terhubung ke server ini menggunakan klien Remote Desktop."
echo ""
echo -e "Gunakan informasi berikut:"
echo -e "  \e[1mAlamat Komputer:\e[0m \e[33m${SERVER_IP}\e[0m"
echo -e "  \e[1mNama Pengguna:\e[0m   \e[33m${CURRENT_USER}\e[0m"
echo -e "  \e[1mKata Sandi:\e[0m      (Gunakan kata sandi login Ubuntu Anda)"
echo ""
echo -e "\e[1mPENTING:\e[0m Saat jendela login xrdp muncul, pastikan 'Session' diatur ke \e[33m'Xorg'\e[0m."
echo ""
echo -e "\e[1mUntuk verifikasi, Anda bisa menjalankan:\e[0m"
echo -e "\e[36msudo systemctl status xrdp\e[0m (pastikan outputnya 'active (running)')"
echo -e "\e[32m\e[1m====================================================\e[0m\n"
