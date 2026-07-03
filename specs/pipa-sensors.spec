Name:           pipa-sensors
Version:        1.2
Release:        3%{?dist}
Summary:        Sensor configuration for the Xiaomi Pad 6
License:        MIT
BuildArch:      noarch

Source1:        81-libssc-xiaomi-pipa.rules
Source2:        hexagonrpcd-sdsp.conf
Source3:        pipa-prepare-sensor-persist
Source4:        pipa-sensors-persist.service
Source5:        pipa-sensors-resume
Source6:        iio-sensor-proxy-pipa-audio.conf
Source7:        pipa-audio-init-sensors.conf
Source8:        pipa-sensors.tmpfiles
Source9:        hexagonrpcd-sdsp-pipa-sensors.conf

BuildRequires:  systemd-rpm-macros

Requires:       xiaomi-pipa-firmware
Requires:       iio-sensor-proxy
Requires:       hexagonrpc

%description
Sensor configuration, udev rules, systemd services, and resume hooks
for the Xiaomi Pad 6 (pipa). Manages hexagonrpcd-sdsp configuration,
persist partition setup, and sleep/wake sensor recovery.

%install
install -Dm644 %{SOURCE1} %{buildroot}%{_udevrulesdir}/81-libssc-xiaomi-pipa.rules
install -Dm644 %{SOURCE2} %{buildroot}/usr/share/hexagonrpcd/hexagonrpcd-sdsp.conf
install -Dm644 %{SOURCE2} %{buildroot}/usr/share/hexagonrpcd/hexagonrpcd-adsp-rootpd.conf
install -Dm644 %{SOURCE2} %{buildroot}/usr/share/hexagonrpcd/hexagonrpcd-adsp-sensorspd.conf
install -Dm755 %{SOURCE3} %{buildroot}/usr/local/bin/pipa-prepare-sensor-persist
install -Dm644 %{SOURCE4} %{buildroot}%{_unitdir}/pipa-sensors-persist.service
install -Dm755 %{SOURCE5} %{buildroot}%{_prefix}/lib/systemd/system-sleep/pipa-sensors-resume
install -Dm644 %{SOURCE6} %{buildroot}%{_unitdir}/iio-sensor-proxy.service.d/10-pipa-audio.conf
install -Dm644 %{SOURCE7} %{buildroot}%{_unitdir}/pipa-audio-init.service.d/10-sensors.conf
install -Dm644 %{SOURCE8} %{buildroot}%{_tmpfilesdir}/pipa-sensors.conf
install -Dm644 %{SOURCE9} %{buildroot}%{_unitdir}/hexagonrpcd-sdsp.service.d/10-pipa-sensors.conf

%post
systemd-tmpfiles --create %{_tmpfilesdir}/pipa-sensors.conf >/dev/null 2>&1 || :
/usr/local/bin/pipa-prepare-sensor-persist >/dev/null 2>&1 || :

%files
%{_udevrulesdir}/81-libssc-xiaomi-pipa.rules
/usr/share/hexagonrpcd/hexagonrpcd-sdsp.conf
/usr/share/hexagonrpcd/hexagonrpcd-adsp-rootpd.conf
/usr/share/hexagonrpcd/hexagonrpcd-adsp-sensorspd.conf
/usr/local/bin/pipa-prepare-sensor-persist
%{_unitdir}/pipa-sensors-persist.service
%{_prefix}/lib/systemd/system-sleep/pipa-sensors-resume
%{_unitdir}/iio-sensor-proxy.service.d/10-pipa-audio.conf
%{_unitdir}/pipa-audio-init.service.d/10-sensors.conf
%{_tmpfilesdir}/pipa-sensors.conf
%{_unitdir}/hexagonrpcd-sdsp.service.d/10-pipa-sensors.conf

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 1.2-3
- Initial Ultramarine OS packaging
