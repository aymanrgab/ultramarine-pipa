Name:           hexagonrpc
Version:        0.4.0
Release:        1%{?dist}
Summary:        FastRPC ioctl wrapper and a reverse tunnel
License:        GPL-3.0-or-later
URL:            https://github.com/linux-msm/hexagonrpc/
Source0:        %{url}/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz
Source1:        hexagonrpcd-adsp-rootpd.service
Source2:        hexagonrpcd-adsp-sensorspd.service
Source3:        hexagonrpcd-sdsp.service
Source4:        sysusers.conf
Source5:        10-fastrpc.rules

BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  systemd-rpm-macros

Requires(post): systemd
%{?sysusers_requires_compat}

%description
FastRPC ioctl wrapper and a reverse tunnel. Used to communicate with
the Context Hub Runtime Environment on the DSP that manages sensors,
and to serve files to remote processors.

%package devel
Summary:        Development headers for %{name}
Requires:       %{name} = %{version}-%{release}

%description devel
%{summary}.

%prep
%setup -q -n %{name}-%{version}

%build
%meson
%meson_build

%install
%meson_install

mkdir -p %{buildroot}%{_includedir}
cp -a include/libhexagonrpc %{buildroot}%{_includedir}

install -Dm644 %{SOURCE1} %{buildroot}%{_unitdir}/hexagonrpcd-adsp-rootpd.service
install -Dm644 %{SOURCE2} %{buildroot}%{_unitdir}/hexagonrpcd-adsp-sensorspd.service
install -Dm644 %{SOURCE3} %{buildroot}%{_unitdir}/hexagonrpcd-sdsp.service
install -Dm644 %{SOURCE4} %{buildroot}%{_sysusersdir}/fastrpc.conf
install -Dm644 %{SOURCE5} %{buildroot}%{_udevrulesdir}/10-fastrpc.rules

%pre
%sysusers_create_compat %{SOURCE4}

%post
%systemd_post hexagonrpcd-adsp-rootpd.service
%systemd_post hexagonrpcd-adsp-sensorspd.service
%systemd_post hexagonrpcd-sdsp.service
systemctl stop hexagonrpcd-adsp-rootpd.service >/dev/null 2>&1 || :
systemctl disable hexagonrpcd-adsp-rootpd.service >/dev/null 2>&1 || :
systemctl mask hexagonrpcd-adsp-rootpd.service >/dev/null 2>&1 || :

%preun
%systemd_preun hexagonrpcd-adsp-rootpd.service
%systemd_preun hexagonrpcd-adsp-sensorspd.service
%systemd_preun hexagonrpcd-sdsp.service

%postun
%systemd_postun hexagonrpcd-adsp-rootpd.service
%systemd_postun_with_restart hexagonrpcd-adsp-sensorspd.service
%systemd_postun_with_restart hexagonrpcd-sdsp.service

%files
%doc README.md
%license COPYING
%{_unitdir}/*.service
%{_bindir}/hexagonrpcd
%{_libexecdir}/hexagonrpc
%{_sysusersdir}/fastrpc.conf
%{_udevrulesdir}/10-fastrpc.rules

%files devel
%{_includedir}/libhexagonrpc
%{_libdir}/libhexagonrpc.so

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 0.4.0-1
- Update to 0.4.0 for Ultramarine OS pipa port
