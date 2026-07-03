Name:           pipa-sound-conf
Version:        1.4
Release:        8%{?dist}
Summary:        Sound and camera settings for Xiaomi Pad 6 (pipa)
License:        MIT
BuildArch:      noarch

Source1:        51-pipa.conf
Source2:        52-pipa-camera.conf
Source3:        pipewire-softisp-cpu.conf
Source4:        pipa-audio-init
Source5:        pipa-audio-init.service

BuildRequires:  systemd-rpm-macros

Requires:       alsa-ucm-conf-sm8250
Requires:       alsa-utils
Requires:       wireplumber

Provides:       alsa-ucm-conf-xiaomi-pipa = %{version}-%{release}
Obsoletes:      alsa-ucm-conf-xiaomi-pipa < %{version}-%{release}

%description
WirePlumber audio and camera configuration for the Xiaomi Pad 6 (pipa).
Includes volume capping for speaker amps, camera resolution limits,
PipeWire CPU debayer override, and ALSA UCM audio initialization.

%install
install -Dm644 %{SOURCE1} %{buildroot}/usr/share/wireplumber/wireplumber.conf.d/51-pipa.conf
install -Dm644 %{SOURCE2} %{buildroot}/usr/share/wireplumber/wireplumber.conf.d/52-pipa-camera.conf
install -Dm644 %{SOURCE3} %{buildroot}%{_userunitdir}/pipewire.service.d/softisp-cpu.conf
install -Dm755 %{SOURCE4} %{buildroot}/usr/local/bin/pipa-audio-init
install -Dm644 %{SOURCE5} %{buildroot}%{_unitdir}/pipa-audio-init.service

%post
%systemd_post pipa-audio-init.service

%preun
%systemd_preun pipa-audio-init.service

%postun
%systemd_postun_with_restart pipa-audio-init.service

%files
/usr/share/wireplumber/wireplumber.conf.d/51-pipa.conf
/usr/share/wireplumber/wireplumber.conf.d/52-pipa-camera.conf
%{_userunitdir}/pipewire.service.d/softisp-cpu.conf
/usr/local/bin/pipa-audio-init
%{_unitdir}/pipa-audio-init.service

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 1.4-8
- Add 52-pipa-camera.conf for camera resolution limits
- Add pipewire-softisp-cpu.conf for CPU debayer
