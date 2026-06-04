#!/bin/bash

set -e

echo -e "\n[*] Starting Ultimate Kali VM Optimization..."

# =========================================================
# 1. AUTO LOGIN
# =========================================================
echo -e "\n[*] Configuring auto-login..."

sudo mkdir -p /etc/lightdm

sudo tee /etc/lightdm/lightdm.conf >/dev/null <<'EOF'
[Seat:*]
autologin-user=kali
autologin-user-timeout=0
user-session=xfce
EOF

echo "[✓] Done"

# =========================================================
# 2. FAST GRUB + REMOVE SPLASH
# =========================================================
echo -e "\n[*] Optimizing GRUB..."

sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub

sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash plymouth.enable=0 loglevel=3 systemd.show_status=0 rd.udev.log_level=3 vt.global_cursor_default=0"/' /etc/default/grub 

sudo update-grub

sudo update-initramfs -u

echo "[✓] Done"

# =========================================================
# 3. DISABLE XFCE COMPOSITING
# =========================================================
echo -e "\n[*] Disabling XFCE compositor..."

mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfwm4" version="1.0">
  <property name="general">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
EOF

echo "[✓] Done"

# =========================================================
# 4. DISABLE UNNECESSARY SERVICES
# =========================================================
echo -e "\n[*] Disabling unnecessary services..."

SERVICES=(
    bluetooth
    cups
    ModemManager
    NetworkManager-wait-online.service
    networking.service
    accounts-daemon.service
    systemd-binfmt.service
    e2scrub_reap.service
    colord.service
    plymouth-quit-wait.service
)

for service in "${SERVICES[@]}"; do
    sudo systemctl disable "$service" 2>/dev/null || true
done

echo "[✓] Done"

# =========================================================
# 5. REDUCE SWAPPINESS
# =========================================================
echo -e "\n[*] Optimizing memory usage..."

if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
fi

sudo sysctl -p

echo "[✓] Done"

# =========================================================
# 6. REMOVE TERMINAL LOGIN MESSAGE
# =========================================================
echo -e "\n[*] Removing terminal login spam..."

touch ~/.hushlogin

echo "[✓] Done"

# =========================================================
# 7. CLEAN SESSION CACHE
# =========================================================
echo -e "\n[*] Cleaning old session cache..."

rm -rf ~/.cache/sessions/* 2>/dev/null || true

echo "[✓] Done"

# =========================================================
# 8. FASTER SHUTDOWN
# =========================================================
echo -e "\n[*] Reducing shutdown timeout..."

sudo sed -i 's/^#\?DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf

if ! grep -q "^DefaultTimeoutStopSec=" /etc/systemd/system.conf; then
    echo "DefaultTimeoutStopSec=5s" | sudo tee -a /etc/systemd/system.conf
fi

echo "[✓] Done"

# =========================================================
# 9. Prevent sleep and lockscreen
# =========================================================
echo -e "\n[*] Preventing sleep and lockscreen..."

# 1. Disable the XFCE screensaver and lock screen
xfconf-query -c xfce4-screensaver -p /lock/enabled -n -t bool -s false
xfconf-query -c xfce4-screensaver -p /saver/enabled -n -t bool -s false

# 2. Prevent the display from blanking or turning off via Power Manager
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac -n -t bool -s false

# 3. Disable sleep/blanking when running on battery (if applicable)
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -n -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery -n -t bool -s false

echo "[✓] Done"

# =========================================================
# 10. SHOW BOOT ANALYSIS
# =========================================================
echo
echo -e "\n[*] Current boot timing:"
systemd-analyze || true

echo
echo "[✓] Ultimate Kali VM optimization complete."
echo -e "\n[*] Reboot your VM now."
