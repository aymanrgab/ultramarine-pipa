#!/bin/bash
set -x

BOOT_LABEL="boot"
KERNEL_VER=$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)
CMDLINE="root=LABEL=um-pipa rw rootwait boot=LABEL=${BOOT_LABEL} console=tty0 quiet clk_ignore_unused pd_ignore_unused"

mkdir -p /boot/grub /boot/grub2

# Stage 1: rootfs redirect — tells GRUB to chain into the boot partition
cat > /boot/grub/grub.cfg <<EOF
search --no-floppy --label --set=boot ${BOOT_LABEL}
set prefix=(\$boot)/grub2
configfile (\$boot)/grub2/grub.cfg
EOF

# Stage 2: actual boot menu on /boot partition
cat > /boot/grub2/grub.cfg <<GRUBEOF
set timeout=5
set default=0

menuentry "Ultramarine Linux (Xiaomi Pad 6)" {
    linux /Image.gz ${CMDLINE}
    initrd /initramfs-${KERNEL_VER}.img
    devicetree /dtbs/qcom/sm8250-xiaomi-pipa.dtb
}

menuentry "Ultramarine Linux (recovery)" {
    linux /Image.gz ${CMDLINE} systemd.unit=multi-user.target
    initrd /initramfs-${KERNEL_VER}.img
    devicetree /dtbs/qcom/sm8250-xiaomi-pipa.dtb
}
GRUBEOF

# Regenerate initramfs (rely on pipa-dracut config, no explicit modules)
dracut --force --kver "$KERNEL_VER" "/boot/initramfs-${KERNEL_VER}.img" 2>/dev/null || \
    echo "WARNING: dracut failed, initramfs may need regeneration on first boot"

# Clean up build artifacts
rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection
rm -f /etc/machine-id
touch /etc/machine-id
rm -f /var/lib/rpm/__db*
