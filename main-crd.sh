#!/bin/bash
set -e

CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~"$CURRENT_USER")

info() { echo -e "\n\e[34m\e[1m[INFO]\e[0m $1\e[0m"; }
ok() { echo -e "\e[32m\e[1m[OK]\e[0m $1\e[0m"; }
warn() { echo -e "\e[33m\e[1m[!!]\e[0m $1\e[0m"; }

info "install default de xfce..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 desktop-base xfce4-goodies xfce4-session dbus-x11

info "bersihin Chrome Remote Desktop lama dulu..."
sudo systemctl stop "chrome-remote-desktop@${CURRENT_USER}.service" || true
sudo systemctl disable "chrome-remote-desktop@${CURRENT_USER}.service" || true
sudo apt-get purge -y chrome-remote-desktop || true
sudo systemctl daemon-reload
ok "CRD lama udah dibuang."

info "download & install Chrome Remote Desktop yang baru..."
rm -f chrome-remote-desktop_current_amd64.deb*
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install -y ./chrome-remote-desktop_current_amd64.deb

info "bikin file konfigurasi XFCE..."
cat <<EOF > ~/.chrome-remote-desktop-session
#!/bin/bash
export HOME="${USER_HOME}"
cd "${USER_HOME}"
unset XDG_RUNTIME_DIR
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session /usr/bin/xfce4-session
EOF
ok "konfigurasi CRD siap dipakai."

info "setting grup & service biar otomatis jalan..."
sudo groupadd --system chrome-remote-desktop || true
sudo usermod -a -G chrome-remote-desktop "${CURRENT_USER}"
sudo systemctl daemon-reload
sudo systemctl enable "chrome-remote-desktop@${CURRENT_USER}.service"
ok "Grup & service beres."

info "bersihin file installer yang udah enggak kepake..."
rm chrome-remote-desktop_current_amd64.deb

echo -e "\n\e[32m\e[1m====== XFCE + Chrome Remote Desktop siap dipakai! ======\e[0m"
echo -e "\nsekarang tinggal otorisasi akun Google mu."
echo -e "buka: \e[33mhttps://remotedesktop.google.com/headless\e[0m"
echo -e "pilih debian/linux, copy perintahnya, paste di sini, enter."
