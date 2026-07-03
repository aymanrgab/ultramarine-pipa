#!/bin/bash
set -x

echo "GRUB_DISABLE_OS_PROBER=true" > /etc/default/grub
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet clk_ignore_unused pd_ignore_unused"' >> /etc/default/grub
echo 'GRUB_TIMEOUT=5' >> /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg
rm -f /etc/default/grub

bootdev=$(findmnt -n -o SOURCE /boot 2>/dev/null || findmnt -n -o SOURCE /)
bootid=$(blkid -s UUID -o value "$bootdev")

mkdir -p /boot/efi/EFI/fedora
cat << EOF > /boot/efi/EFI/fedora/grub.cfg
search --no-floppy --fs-uuid --set=dev ${bootid}
set prefix=(\$dev)/grub2

export \$prefix
configfile \$prefix/grub.cfg
EOF

dracut -fN --add-drivers "virtio virtio_blk virtio_scsi mmc qcom-scm" --regenerate-all

rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection
rm -f /etc/machine-id
touch /etc/machine-id
rm -f /var/lib/rpm/__db*
