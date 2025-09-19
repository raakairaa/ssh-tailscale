#!/bin/bash
set -e
CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~"$CURRENT_USER")
print_info() { echo -e "\n\e[34m\e[1m[INFO]\e[0m $1\e[0m"; }
print_success() { echo -e "\e[32m\e[1m[SUCCESS]\e[0m $1\e[0m"; }
print_error() { echo -e "\e[31m\e[1m[ERROR]\e[0m $1\e[0m"; }

if [ -z "$1" ]; then
    print_error "Anda harus menentukan Desktop Environment yang diinginkan!"
    echo "Penggunaan: $0 <pilihan>"
    echo "Pilihan: xfce, kde, gnome, cinnamon, mate"
    exit 1
fi
DESKTOP_CHOICE=$(echo "$1" | tr '[:upper:]' '[:lower:]') # Ubah ke huruf kecil
EXEC_COMMAND=""
case $DESKTOP_CHOICE in
    xfce)
        print_info "Menginstal XFCE Desktop..."
        sudo apt-get install -y xfce4 xfce4-goodies
        # Perintah eksekusi XFCE dengan perbaikan D-Bus
        EXEC_COMMAND="dbus-launch --exit-with-session /usr/bin/xfce4-session"
        ;;
    kde)
        print_info "Menginstal KDE Plasma Desktop (standar)..."
        sudo apt-get install -y kde-standard
        EXEC_COMMAND="startplasma-x11"
        ;;
    gnome)
        print_info "Menginstal GNOME Shell..."
        sudo apt-get install -y gnome-shell
        EXEC_COMMAND="gnome-session"
        ;;
    cinnamon)
        print_info "Menginstal Cinnamon Desktop..."
        sudo apt-get install -y cinnamon-desktop-environment
        EXEC_COMMAND="cinnamon-session"
        ;;
    mate)
        print_info "Menginstal MATE Desktop..."
        sudo apt-get install -y mate-desktop-environment
        EXEC_COMMAND="mate-session"
        ;;
    *)
        print_error "Pilihan '$1' tidak dikenali."
        echo "pilihan yang ada: xfce, kde, gnome, cinnamon, mate"
        exit 1
        ;;
esac
print_info "Mengonfigurasi Chrome Remote Desktop untuk menjalankan '$DESKTOP_CHOICE'..."
# Ini adalah "resep universal" yang memperbaiki lingkungan
cat <<EOF > ~/.chrome-remote-desktop-session
#!/bin/bash
export HOME="${USER_HOME}"
export DESKTOP_SESSION="${DESKTOP_CHOICE}"
export XDG_SESSION_DESKTOP="${DESKTOP_CHOICE}"
export XDG_CURRENT_DESKTOP="${DESKTOP_CHOICE}"
cd "${USER_HOME}"

# start
exec ${EXEC_COMMAND}
EOF
print_success "File sesi telah dikonfigurasi."

# restart
print_info "Me-restart layanan Chrome Remote Desktop..."
sudo systemctl restart "chrome-remote-desktop@${CURRENT_USER}.service"
print_success "Selesai! Layanan telah di-restart."

echo -e "\n\e[32m\e[1mDesktop Environment Anda telah berhasil diubah menjadi ${DESKTOP_CHOICE^}!\e[0m"
echo "Silakan coba sambungkan kembali melalui Chrome Remote Desktop."
