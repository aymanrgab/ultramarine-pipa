Name:           swclock-offset
Version:        0.3.0
Release:        1%{?dist}
Summary:        Keep system time at an offset to a non-writable RTC
License:        GPL-3.0-or-later
BuildArch:      noarch
URL:            https://gitlab.postmarketos.org/postmarketOS/swclock-offset
Source0:        %{url}/-/archive/%{version}/%{name}-%{version}.tar.gz

BuildRequires:  systemd-rpm-macros

Requires:       systemd

%description
Keeps system time at an offset to a non-writable RTC. Needed on devices
like the Xiaomi Pad 6 where the hardware RTC is not directly writable.

%prep
%autosetup -n %{name}-%{version}

%build
sed -e 's+STORAGE_PATH+/var/cache+g' "src/%{name}-boot.sh.in" > "src/%{name}-boot.sh"
sed -e 's+STORAGE_PATH+/var/cache+g' "src/%{name}-shutdown.sh.in" > "src/%{name}-shutdown.sh"
sed -e 's+SWCLOCK_PATH+/usr/bin+g' "systemd/%{name}-boot.service.in" > "systemd/%{name}-boot.service"
sed -e 's+SWCLOCK_PATH+/usr/bin+g' "systemd/%{name}-shutdown.service.in" > "systemd/%{name}-shutdown.service"

%install
install -Dm755 "src/%{name}-boot.sh" "%{buildroot}%{_bindir}/%{name}-boot"
install -Dm755 "src/%{name}-shutdown.sh" "%{buildroot}%{_bindir}/%{name}-shutdown"
install -Dm644 "systemd/%{name}.target" "%{buildroot}%{_unitdir}/%{name}.target"
install -Dm644 "systemd/%{name}-boot.service" "%{buildroot}%{_unitdir}/%{name}-boot.service"
install -Dm644 "systemd/%{name}-shutdown.service" "%{buildroot}%{_unitdir}/%{name}-shutdown.service"

%post
%systemd_post %{name}-boot.service %{name}-shutdown.service

%preun
%systemd_preun %{name}-boot.service %{name}-shutdown.service

%postun
%systemd_postun %{name}-boot.service %{name}-shutdown.service

%files
%{_bindir}/%{name}-boot
%{_bindir}/%{name}-shutdown
%{_unitdir}/%{name}.target
%{_unitdir}/%{name}-boot.service
%{_unitdir}/%{name}-shutdown.service

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 0.3.0-1
- Package for Ultramarine OS pipa port
