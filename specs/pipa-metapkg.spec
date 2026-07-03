Name:           pipa-metapkg
Version:        1.1
Release:        1%{?dist}
Summary:        Xiaomi Pad 6 support meta package for Ultramarine OS
License:        MIT
BuildArch:      noarch

Source1:        90-pipa-gsk-renderer.sh

Requires:       kernel-pipa
Requires:       kernel-pipa-modules
Requires:       xiaomi-pipa-firmware
Requires:       pipa-dracut
Requires:       pipa-grub-config
Requires:       pipa-sound-conf
Requires:       pipa-sensors
Requires:       swclock-offset
Requires:       bootmac
Requires:       hexagonrpc
Requires:       libssc
Requires:       libcamera
Requires:       libcamera-ipa
Requires:       libcamera-tools
Requires:       gstreamer1-plugin-libcamera
Requires:       iio-sensor-proxy
Requires:       qrtr
Requires:       tqftpserv
Requires:       pd-mapper
Requires:       mesa-dri-drivers
Requires:       wireless-regdb
Requires:       tuned
Requires:       tuned-ppd

%description
Meta package that pulls in all components needed for running
Ultramarine OS on the Xiaomi Pad 6 (pipa): custom kernel, firmware,
sensors, audio, camera, and boot configuration.

%install
install -Dm755 %{SOURCE1} %{buildroot}%{_sysconfdir}/profile.d/90-pipa-gsk-renderer.sh

%files
%config(noreplace) %{_sysconfdir}/profile.d/90-pipa-gsk-renderer.sh

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 1.1-1
- Initial Ultramarine OS meta package
