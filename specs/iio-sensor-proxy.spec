%global commit 0085ddf8ecb173a1c5fcf2344aa40e561125354f
%global shortcommit %(c=%{commit}; echo ${c:0:12})

Name:           iio-sensor-proxy
Version:        3.9
Release:        1%{?dist}
Summary:        IIO accelerometer sensor to input device proxy (with SSC/libssc support)
License:        GPL-3.0-or-later
URL:            https://gitlab.freedesktop.org/hadess/iio-sensor-proxy/
Source0:        %{url}/-/archive/%{commit}/%{name}-%{commit}.tar.gz
Source1:        iio-sensor-proxy-resume

Patch0001:      0001-iio-sensor-proxy-Do-not-exit-based-on-sensor-events.patch
Patch0002:      0002-drv-ssc-skip-close-in-discover.patch
Patch0003:      0003-ssc-drivers-guard-against-null-GError-in-g_warning.patch
Patch0004:      0004-ssc-drivers-fix-close-signal-handler.patch
Patch0005:      0005-drv-ssc-retry-open-after-resume.patch

BuildRequires:  meson
BuildRequires:  gcc
BuildRequires:  gtk-doc
BuildRequires:  pkgconfig(udev)
BuildRequires:  pkgconfig(systemd)
BuildRequires:  pkgconfig(libssc)
BuildRequires:  pkgconfig(gio-2.0)
BuildRequires:  pkgconfig(gudev-1.0)
BuildRequires:  pkgconfig(polkit-gobject-1)
BuildRequires:  systemd-rpm-macros
BuildRequires:  umockdev
BuildRequires:  python3-dbusmock

Requires:       libssc >= 0.2.2
%{?systemd_requires}

%description
iio-sensor-proxy provides a D-Bus proxy for IIO and SSC (Qualcomm Sensor
Core) sensors. This build includes pipa-specific patches for SSC
resume resilience and null GError guards.

%package docs
Summary:        Documentation for %{name}
License:        GFDL-1.1-or-later
BuildArch:      noarch

%description docs
Documentation for %{name}.

%prep
%autosetup -p1 -n %{name}-%{commit}

%build
%meson -Dgtk_doc=true -Dgtk-tests=false -Dssc-support=enabled
%meson_build

%install
%meson_install
install -Dpm0755 %{SOURCE1} %{buildroot}%{_prefix}/lib/systemd/system-sleep/iio-sensor-proxy-resume
install -d %{buildroot}%{_unitdir}/%{name}.service.d
cat > %{buildroot}%{_unitdir}/%{name}.service.d/hexagonrpcd.conf <<'EOF'
[Unit]
Wants=hexagonrpcd-sdsp.service
After=hexagonrpcd-sdsp.service
PartOf=hexagonrpcd-sdsp.service
EOF

%post
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.service

%postun
%systemd_postun_with_restart %{name}.service

%files
%license COPYING
%doc README.md
%{_bindir}/monitor-sensor
%{_libexecdir}/%{name}
%{_unitdir}/%{name}.service
%{_unitdir}/%{name}.service.d/hexagonrpcd.conf
%{_udevrulesdir}/*-%{name}*.rules
%{_datadir}/dbus-1/system.d/net.hadess.SensorProxy.conf
%{_datadir}/polkit-1/actions/net.hadess.SensorProxy.policy
%{_prefix}/lib/systemd/system-sleep/iio-sensor-proxy-resume

%files docs
%dir %{_datadir}/gtk-doc/
%dir %{_datadir}/gtk-doc/html/
%{_datadir}/gtk-doc/html/%{name}/

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 3.9-1
- Update to 3.9 with pipa SSC patches
