#!/bin/bash
set -x

KERNEL_VER=$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | head -n 1)
CMDLINE="quiet clk_ignore_unused pd_ignore_unused"

mkdir -p /boot/grub2

cat > /boot/grub2/grub.cfg <<GRUBEOF
set timeout=5
set default=0

menuentry "Ultramarine Linux (Xiaomi Pad 6)" {
    linux /Image.gz root=LABEL=um-pipa rw rootwait boot=LABEL=boot console=tty0 ${CMDLINE}
    initrd /initramfs-${KERNEL_VER}.img
    devicetree /dtbs/qcom/sm8250-xiaomi-pipa.dtb
}

menuentry "Ultramarine Linux (recovery)" {
    linux /Image.gz root=LABEL=um-pipa rw rootwait boot=LABEL=boot console=tty0 systemd.unit=multi-user.target ${CMDLINE}
    initrd /initramfs-${KERNEL_VER}.img
    devicetree /dtbs/qcom/sm8250-xiaomi-pipa.dtb
}
GRUBEOF

bootdev=$(findmnt -n -o SOURCE /boot 2>/dev/null || findmnt -n -o SOURCE /)
bootid=$(blkid -s UUID -o value "$bootdev" 2>/dev/null || echo "UNKNOWN")

mkdir -p /boot/efi/EFI/fedora
cat > /boot/efi/EFI/fedora/grub.cfg <<ESPEOF
search --no-floppy --fs-uuid --set=dev ${bootid}
set prefix=(\$dev)/grub2

export \$prefix
configfile \$prefix/grub.cfg
ESPEOF

dracut -fN --add-drivers "mmc qcom-scm" --regenerate-all 2>/dev/null || \
    echo "WARNING: dracut failed, initramfs may need regeneration on first boot"

rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection
rm -f /etc/machine-id
touch /etc/machine-id
rm -f /var/lib/rpm/__db*
