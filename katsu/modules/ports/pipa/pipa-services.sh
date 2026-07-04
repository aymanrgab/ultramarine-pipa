#!/bin/bash
set -x

# Display manager
systemctl enable gdm.service

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
