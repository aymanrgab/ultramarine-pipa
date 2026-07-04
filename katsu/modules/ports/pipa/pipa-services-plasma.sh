#!/bin/bash
set -x

# Display manager
systemctl enable plasmalogin.service

# Core services
systemctl enable sshd NetworkManager iwd bluetooth systemd-resolved systemd-timesyncd

mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/wifi-iwd.conf <<'EOF'
[device]
wifi.backend=iwd
EOF

# Power management
systemctl enable tuned tuned-ppd

# Bluetooth MAC
systemctl enable bootmac-bluetooth || true

# Clock offset (no RTC on pipa)
systemctl enable swclock-offset-boot.service swclock-offset-shutdown.service

# Qualcomm firmware services
systemctl enable pd-mapper rmtfs tqftpserv || true

# Sensor stack
systemctl enable \
    pipa-sensors-persist \
    hexagonrpcd-sdsp \
    hexagonrpcd-adsp-sensorspd \
    iio-sensor-proxy \
    pipa-audio-init || true

# Masked services
systemctl mask hexagonrpcd-adsp-rootpd.service || true

# Plasma virtual keyboard
mkdir -p /etc/environment.d
cat > /etc/environment.d/90-plasma-keyboard.conf <<EOF
KWIN_IM_SHOW_ALWAYS=1
PLASMA_KEYBOARD_USE_QT_LAYOUTS=1
EOF
