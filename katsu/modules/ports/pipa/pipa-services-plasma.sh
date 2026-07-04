#!/bin/bash
set -x

systemctl enable hexagonrpcd-sdsp.service
systemctl enable hexagonrpcd-adsp-sensorspd.service
systemctl enable pipa-sensors-persist.service
systemctl enable pipa-audio-init.service 2>/dev/null || true
systemctl enable bootmac-bluetooth.service
systemctl enable swclock-offset-boot.service
systemctl enable swclock-offset-shutdown.service

systemctl mask hexagonrpcd-adsp-rootpd.service

systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl enable bluetooth.service
systemctl enable tuned.service
