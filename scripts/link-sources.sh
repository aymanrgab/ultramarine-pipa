#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIPA_PKGS="${PIPA_PKGS:-/home/ayman/pipa-pkgs}"
SOURCES="$REPO_ROOT/sources"

echo "=== Linking sources from pipa-pkgs ==="

link_files() {
    local dest="$1"
    shift
    mkdir -p "$dest"
    for src in "$@"; do
        if [ -e "$src" ]; then
            cp -v "$src" "$dest/"
        else
            echo "WARNING: $src not found"
        fi
    done
}

# kernel-pipa
link_files "$SOURCES/kernel-pipa" \
    "$PIPA_PKGS/sm8250/linux-pipa/pipa.config" \
    "$PIPA_PKGS/sm8250/linux-pipa/"0*.patch

# xiaomi-pipa-firmware
link_files "$SOURCES/xiaomi-pipa-firmware" \
    "$PIPA_PKGS/sm8250/xiaomi-pipa-firmware/awinic_firmware.files" \
    "$PIPA_PKGS/sm8250/xiaomi-pipa-firmware/dsp_firmware.files" \
    "$PIPA_PKGS/sm8250/xiaomi-pipa-firmware/qcom_firmware.files" \
    "$PIPA_PKGS/sm8250/xiaomi-pipa-firmware/novatek_firmware.files" \
    "$PIPA_PKGS/sm8250/xiaomi-pipa-firmware/nuvolta_firmware.files"

# pipa-sensors
link_files "$SOURCES/pipa-sensors" \
    "$PIPA_PKGS/sm8250/pipa-sensors/81-libssc-xiaomi-pipa.rules" \
    "$PIPA_PKGS/sm8250/pipa-sensors/hexagonrpcd-sdsp.conf" \
    "$PIPA_PKGS/sm8250/pipa-sensors/pipa-prepare-sensor-persist" \
    "$PIPA_PKGS/sm8250/pipa-sensors/pipa-sensors-persist.service" \
    "$PIPA_PKGS/sm8250/pipa-sensors/pipa-sensors-resume" \
    "$PIPA_PKGS/sm8250/pipa-sensors/iio-sensor-proxy-pipa-audio.conf" \
    "$PIPA_PKGS/sm8250/pipa-sensors/pipa-audio-init-sensors.conf" \
    "$PIPA_PKGS/sm8250/pipa-sensors/pipa-sensors.tmpfiles" \
    "$PIPA_PKGS/sm8250/pipa-sensors/hexagonrpcd-sdsp-pipa-sensors.conf"

# pipa-sound-conf
link_files "$SOURCES/pipa-sound-conf" \
    "$PIPA_PKGS/sm8250/pipa-sound-conf/51-pipa.conf" \
    "$PIPA_PKGS/sm8250/pipa-sound-conf/52-pipa-camera.conf" \
    "$PIPA_PKGS/sm8250/pipa-sound-conf/pipewire-softisp-cpu.conf" \
    "$PIPA_PKGS/sm8250/pipa-sound-conf/pipa-audio-init" \
    "$PIPA_PKGS/sm8250/pipa-sound-conf/pipa-audio-init.service"

# pipa-dracut
link_files "$SOURCES/pipa-dracut" \
    "$PIPA_PKGS/sm8250/pipa-dracut/module-setup.sh" \
    "$PIPA_PKGS/sm8250/pipa-dracut/pipa.conf" \
    "$PIPA_PKGS/sm8250/pipa-dracut/pipa-refresh-initramfs"

# pipa-grub-config
link_files "$SOURCES/pipa-grub-config" \
    "$PIPA_PKGS/sm8250/pipa-grub-config/pipa-refresh-grub-config"

# pipa-metapkg
link_files "$SOURCES/pipa-metapkg" \
    "$PIPA_PKGS/sm8250/pipa-metapkg/90-pipa-gsk-renderer.sh"

# hexagonrpc
link_files "$SOURCES/hexagonrpc" \
    "$PIPA_PKGS/common/hexagonrpc/hexagonrpcd-adsp-rootpd.service" \
    "$PIPA_PKGS/common/hexagonrpc/hexagonrpcd-adsp-sensorspd.service" \
    "$PIPA_PKGS/common/hexagonrpc/hexagonrpcd-sdsp.service" \
    "$PIPA_PKGS/common/hexagonrpc/sysusers.conf" \
    "$PIPA_PKGS/common/hexagonrpc/10-fastrpc.rules"

# libssc
link_files "$SOURCES/libssc" \
    "$PIPA_PKGS/common/libssc/"0*.patch

# iio-sensor-proxy
link_files "$SOURCES/iio-sensor-proxy" \
    "$PIPA_PKGS/common/iio-sensor-proxy/"0*.patch \
    "$PIPA_PKGS/common/iio-sensor-proxy/iio-sensor-proxy-resume"

# libcamera
link_files "$SOURCES/libcamera" \
    "$PIPA_PKGS/common/libcamera/"0*.patch \
    "$PIPA_PKGS/common/libcamera/hi846.yaml" \
    "$PIPA_PKGS/common/libcamera/ov13b10.yaml"

echo "=== Done linking sources ==="
