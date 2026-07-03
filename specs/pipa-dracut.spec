Name:           pipa-dracut
Version:        1.1
Release:        5%{?dist}
Summary:        Dracut modules for the Xiaomi Pad 6
License:        GPL-2.0-only
BuildArch:      noarch

Source1:        module-setup.sh
Source2:        pipa.conf
Source3:        pipa-refresh-initramfs

Requires:       xiaomi-pipa-firmware
Requires:       dracut

%description
Dracut module and configuration for the Xiaomi Pad 6 (pipa).
Includes firmware loading module and initramfs refresh helper.

%install
install -Dm755 %{SOURCE1} %{buildroot}/usr/lib/dracut/modules.d/90pipafw/module-setup.sh
install -Dm644 %{SOURCE2} %{buildroot}/usr/lib/dracut/dracut.conf.d/10-pipa.conf
install -Dm755 %{SOURCE3} %{buildroot}/usr/local/bin/pipa-refresh-initramfs

%post
/usr/local/bin/pipa-refresh-initramfs >/dev/null 2>&1 || :

%files
/usr/lib/dracut/modules.d/90pipafw/*
/usr/lib/dracut/dracut.conf.d/10-pipa.conf
/usr/local/bin/pipa-refresh-initramfs

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 1.1-5
- Initial Ultramarine OS packaging
