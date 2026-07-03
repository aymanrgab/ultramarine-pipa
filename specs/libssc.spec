Name:           libssc
Version:        0.4.4
Release:        1%{?dist}
Summary:        Library to expose Qualcomm Sensor Core sensors
License:        GPL-3.0-or-later
URL:            https://codeberg.org/DylanVanAssche/libssc
Source:         %{url}/archive/v%{version}.tar.gz

Patch0001:      0001-ssc-guard-against-null-GError-in-g_warning-g_debug.patch
Patch0002:      0002-ssc-guard-null-GError-in-task-return.patch

BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  python3-devel
BuildRequires:  systemd
BuildRequires:  pkgconfig(libprotobuf-c)
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(gudev-1.0)
BuildRequires:  pkgconfig(qmi-glib)
BuildRequires:  pkgconfig(qrtr)
BuildRequires:  pkgconfig(udev)

%description
libssc exposes sensors managed by the Qualcomm Sensor Core found in
many Qualcomm SoCs from 2018 onwards. This build includes pipa-specific
patches for null GError guard.

%package devel
Summary:        Development headers for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
%{summary}.

%package -n python3-ssc
Summary:        Python bindings for libssc
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description -n python3-ssc
%{summary}.

%prep
%autosetup -p1 -n %{name}

%build
%meson
%meson_build

%install
%meson_install
ln -sf libssc.so.2 %{buildroot}%{_libdir}/libssc.so.0

%files
%license LICENSE
%{_bindir}/ssc-server
%{_bindir}/ssc-server-tests
%{_bindir}/ssccli
%{_libdir}/%{name}.so.2
%{_libdir}/%{name}.so.0

%files devel
%{_includedir}/%{name}
%{_libdir}/%{name}.so
%{_libdir}/pkgconfig/%{name}.pc

%files -n python3-ssc
%pycached %{python3_sitelib}/qmi.py
%pycached %{python3_sitelib}/ssc.py

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 0.4.4-1
- Update to 0.4.4 with pipa GError guard patches
