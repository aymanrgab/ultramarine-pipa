#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATE=$(date +%Y%m%d)
VARIANT="${VARIANT_NAME:-gnome}"
IMAGE_NAME="ultramarine-pipa-${VARIANT}-${DATE}"
RAW_IMAGE="${1:-$REPO_ROOT/katsu-work/image/katsu.img}"
OUTPUT_DIR="$REPO_ROOT/output/$IMAGE_NAME"

ROOTFS_LABEL="um-pipa"
BOOT_LABEL="boot"
ESP_LABEL="UMPIPAESP"

SILICIUM_URL="https://github.com/onesaladleaf/Mu-Silicium/releases/download/v3.5-pocketblue/Mu-pipa.img"
VBMETA_DISABLED="$REPO_ROOT/assets/vbmeta-disabled.img"
EFI_TEMPLATE_DIR="$REPO_ROOT/assets/efi-template"

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if [ ! -f "$RAW_IMAGE" ]; then
    echo "Raw image not found: $RAW_IMAGE"
    echo "Usage: $0 <path-to-katsu-raw-image>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
MNT=$(mktemp -d)
BOOT_MNT=$(mktemp -d)
ESP_MNT=$(mktemp -d)

cleanup() {
    umount "$MNT/boot" 2>/dev/null || true
    umount "$MNT" 2>/dev/null || true
    umount "$BOOT_MNT" 2>/dev/null || true
    umount "$ESP_MNT" 2>/dev/null || true
    rmdir "$MNT" "$BOOT_MNT" "$ESP_MNT" 2>/dev/null || true
    losetup -j "$RAW_IMAGE" | cut -d: -f1 | xargs -r losetup -d 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Setting up loop device ==="
LOOP=$(losetup --find --show --partscan "$RAW_IMAGE")

ESP_PART="${LOOP}p1"
BOOT_PART="${LOOP}p2"
ROOT_PART="${LOOP}p3"

echo "=== Extracting rootfs ==="
mount "$ROOT_PART" "$MNT"
mkdir -p "$MNT/boot"
mount "$BOOT_PART" "$MNT/boot"

KERNEL_VER=$(find "$MNT/usr/lib/modules" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)
echo "Kernel version: $KERNEL_VER"
echo "Boot contents:"
ls -la "$MNT/boot/" | head -20

SIZE=$(du -sBM "$MNT" | awk '{print $1}' | tr -d 'M')
SIZE=$((SIZE + (SIZE / 8) + 512))
echo "Rootfs size: ${SIZE}M"

truncate -s "${SIZE}M" "$OUTPUT_DIR/ultramarine_rootfs.raw"
MKE2FS_DEVICE_PHYS_SECTSIZE=4096 MKE2FS_DEVICE_SECTSIZE=4096 \
    mkfs.ext4 -L "$ROOTFS_LABEL" "$OUTPUT_DIR/ultramarine_rootfs.raw"
ROOT_MNT=$(mktemp -d)
mount -o loop "$OUTPUT_DIR/ultramarine_rootfs.raw" "$ROOT_MNT"
rsync -aHAX --exclude '/tmp/*' --exclude '/boot/*' "$MNT/" "$ROOT_MNT/"

cat > "$ROOT_MNT/etc/fstab" <<EOF
LABEL=$ROOTFS_LABEL / ext4 defaults,x-systemd.growfs 0 1
LABEL=$BOOT_LABEL /boot ext4 defaults 0 2
EOF

umount "$ROOT_MNT"
rmdir "$ROOT_MNT"

echo "=== Creating boot image ==="
truncate -s 1024M "$OUTPUT_DIR/ultramarine_boot.raw"
mkfs.ext4 -F -L "$BOOT_LABEL" -O ^64bit,^metadata_csum,^metadata_csum_seed,^orphan_file "$OUTPUT_DIR/ultramarine_boot.raw"
mount -o loop "$OUTPUT_DIR/ultramarine_boot.raw" "$BOOT_MNT"

KERNEL_IMAGE=""
for f in "$MNT/boot/Image.gz" "$MNT/boot/vmlinuz-$KERNEL_VER"; do
    [ -f "$f" ] && KERNEL_IMAGE="$f" && break
done
KERNEL_IMAGE_UNCOMPRESSED=""
for f in "$MNT/boot/Image" "$MNT/boot/vmlinuz-$KERNEL_VER.uncompressed"; do
    [ -f "$f" ] && KERNEL_IMAGE_UNCOMPRESSED="$f" && break
done
INITRAMFS="$MNT/boot/initramfs-$KERNEL_VER.img"
DTB="$MNT/boot/dtbs/qcom/sm8250-xiaomi-pipa.dtb"

cp "$KERNEL_IMAGE" "$BOOT_MNT/Image.gz"
[ -n "$KERNEL_IMAGE_UNCOMPRESSED" ] && cp "$KERNEL_IMAGE_UNCOMPRESSED" "$BOOT_MNT/Image"
[ -f "$INITRAMFS" ] && cp "$INITRAMFS" "$BOOT_MNT/initramfs-$KERNEL_VER.img"
mkdir -p "$BOOT_MNT/dtbs/qcom" "$BOOT_MNT/grub2"
[ -f "$DTB" ] && cp "$DTB" "$BOOT_MNT/dtbs/qcom/"
[ -f "$MNT/boot/System.map-$KERNEL_VER" ] && cp "$MNT/boot/System.map-$KERNEL_VER" "$BOOT_MNT/"
[ -f "$MNT/boot/config-$KERNEL_VER" ] && cp "$MNT/boot/config-$KERNEL_VER" "$BOOT_MNT/"

TARGET_KERNEL_CMDLINE="root=LABEL=$ROOTFS_LABEL rw rootwait boot=LABEL=$BOOT_LABEL console=tty0 quiet clk_ignore_unused pd_ignore_unused"
printf '%s\n' "$TARGET_KERNEL_CMDLINE" > "$BOOT_MNT/cmdline.txt"

if [ -d "$MNT/boot/grub2" ] && [ -f "$MNT/boot/grub2/grub.cfg" ]; then
    cp -a "$MNT/boot/grub2/." "$BOOT_MNT/grub2/"
else
    cat > "$BOOT_MNT/grub2/grub.cfg" <<GRUBCFG
set timeout=5
set default=0

menuentry "Ultramarine Linux (Xiaomi Pad 6)" {
    linux /Image.gz $TARGET_KERNEL_CMDLINE
    initrd /initramfs-${KERNEL_VER}.img
    devicetree /dtbs/qcom/sm8250-xiaomi-pipa.dtb
}
GRUBCFG
fi

umount "$BOOT_MNT"

echo "=== Creating ESP image ==="
truncate -s 128M "$OUTPUT_DIR/ultramarine_esp.raw"
mkfs.fat -F 16 -n "$ESP_LABEL" "$OUTPUT_DIR/ultramarine_esp.raw"
mount -o loop "$OUTPUT_DIR/ultramarine_esp.raw" "$ESP_MNT"

if [ -d "$EFI_TEMPLATE_DIR/EFI" ]; then
    cp -r "$EFI_TEMPLATE_DIR/EFI" "$ESP_MNT/"
elif mount "$ESP_PART" /mnt 2>/dev/null; then
    cp -r /mnt/EFI "$ESP_MNT/" 2>/dev/null || true
    umount /mnt
fi

mkdir -p "$ESP_MNT/EFI/fedora" "$ESP_MNT/EFI/BOOT"
if [ -f "$MNT/boot/efi/EFI/fedora/grubaa64.efi" ]; then
    cp "$MNT/boot/efi/EFI/fedora/grubaa64.efi" "$ESP_MNT/EFI/fedora/"
    cp "$MNT/boot/efi/EFI/fedora/grubaa64.efi" "$ESP_MNT/EFI/BOOT/BOOTAA64.EFI"
fi
if [ -f "$MNT/boot/efi/EFI/fedora/shimaa64.efi" ]; then
    cp "$MNT/boot/efi/EFI/fedora/shimaa64.efi" "$ESP_MNT/EFI/fedora/"
    cp "$MNT/boot/efi/EFI/fedora/shimaa64.efi" "$ESP_MNT/EFI/BOOT/BOOTAA64.EFI"
fi

for vendor_dir in fedora BOOT; do
cat > "$ESP_MNT/EFI/$vendor_dir/grub.cfg" 2>/dev/null <<ESPCFG || true
search --label $BOOT_LABEL --set prefix --no-floppy
if [ -d (\$prefix)/grub2 ]; then
  set prefix=(\$prefix)/grub2
  configfile \$prefix/grub.cfg
fi
boot
ESPCFG
done

umount "$ESP_MNT"
umount "$MNT/boot"
umount "$MNT"

echo "=== Fetching Mu-Silicium ==="
if [ ! -f "$OUTPUT_DIR/silicium.img" ]; then
    wget -O "$OUTPUT_DIR/silicium.img" "$SILICIUM_URL"
fi

echo "=== Copying vbmeta ==="
if [ -f "$VBMETA_DISABLED" ]; then
    cp "$VBMETA_DISABLED" "$OUTPUT_DIR/vbmeta-disabled.img"
else
    echo "WARNING: vbmeta-disabled.img not found at $VBMETA_DISABLED"
    echo "You'll need to provide this manually"
fi

echo "=== Writing flash scripts ==="
cat > "$OUTPUT_DIR/flash.sh" <<'FLASH'
#!/usr/bin/env bash
set -euo pipefail

echo "### Ultramarine OS - Xiaomi Pad 6 single-boot flasher"
echo "### This flashes Ultramarine rootfs to userdata."
echo

echo "### Verifying connected device..."
fastboot getvar product 2>&1 | grep pipa

read -r -p "Proceed with flashing? [Y/n]: " CONFIRM
case "${CONFIRM:-Y}" in
    y|Y|yes|YES|"") ;;
    *) echo "Aborted."; exit 0 ;;
esac

echo "### Flashing Mu-Silicium to boot_ab"
fastboot flash boot_ab silicium.img

echo "### Flashing ESP to rawdump"
fastboot flash rawdump ultramarine_esp.raw

echo "### Flashing boot to cust"
fastboot flash cust ultramarine_boot.raw

echo "### Flashing rootfs to userdata"
fastboot flash userdata ultramarine_rootfs.raw

echo "### Rebooting..."
fastboot reboot
FLASH
chmod +x "$OUTPUT_DIR/flash.sh"

cat > "$OUTPUT_DIR/flash-multiboot.sh" <<'MFLASH'
#!/usr/bin/env bash
set -euo pipefail

echo "### Ultramarine OS - Xiaomi Pad 6 multiboot flasher"
echo "### This flashes rootfs to a dedicated partition."
echo

ROOTFS_PART="${1:-linux}"
BOOT_SLOT="${2:-boot_ab}"

echo "### Verifying connected device..."
fastboot getvar product 2>&1 | grep pipa

echo "Flash plan:"
echo "  Mu-Silicium  -> $BOOT_SLOT"
echo "  ESP          -> rawdump"
echo "  boot         -> cust"
echo "  rootfs       -> $ROOTFS_PART"
echo

read -r -p "Proceed? [Y/n]: " CONFIRM
case "${CONFIRM:-Y}" in
    y|Y|yes|YES|"") ;;
    *) echo "Aborted."; exit 0 ;;
esac

fastboot flash "$BOOT_SLOT" silicium.img
fastboot flash rawdump ultramarine_esp.raw
fastboot flash cust ultramarine_boot.raw
fastboot flash "$ROOTFS_PART" ultramarine_rootfs.raw

echo "### Rebooting..."
fastboot reboot
MFLASH
chmod +x "$OUTPUT_DIR/flash-multiboot.sh"

echo "=== Writing build metadata ==="
cat > "$OUTPUT_DIR/BUILDINFO.txt" <<EOF
Ultramarine OS Pipa Image Build
================================
Desktop:        ${VARIANT}
Build date:     $DATE
Kernel:         ${KERNEL_VER:-unknown}
Rootfs label:   $ROOTFS_LABEL
Boot label:     $BOOT_LABEL
ESP label:      $ESP_LABEL
Silicium URL:   $SILICIUM_URL
EOF

echo "=== Generating checksums ==="
(cd "$OUTPUT_DIR" && sha256sum -- *.raw *.img *.sh BUILDINFO.txt > SHA256SUMS)

echo "=== Creating ZIP archive ==="
(cd "$OUTPUT_DIR" && zip -r "../$IMAGE_NAME.zip" .)

echo ""
echo "=== Done! ==="
echo "Output: $OUTPUT_DIR/"
echo "ZIP:    $REPO_ROOT/output/$IMAGE_NAME.zip"
