%global kversion 7.0.8
%global krelease 21
%global kextra %{krelease}-pipa
%global commit afac0607a1046fe1dcdd341297a2144d5013272a
%global shortcommit %(c=%{commit}; echo ${c:0:12})

Name:           kernel-pipa
Version:        %{kversion}
Release:        %{krelease}%{?dist}
Summary:        Linux kernel for Xiaomi Pad 6 (Pipa)
License:        GPL-2.0-only
URL:            https://github.com/aymanrgab/linux
ExclusiveArch:  aarch64

Source0:        %{url}/archive/%{commit}/linux-%{shortcommit}.tar.gz
Source1:        pipa.config

Patch0002:      0002-media-i2c-ov13b10-Add-debug-logs-for-Pipa-camera-bring-up.patch
Patch0003:      0003-media-i2c-ov13b10-Fix-ACPI-PM-for-device-tree-systems.patch
Patch0004:      0004-media-i2c-hi846-Add-debug-logs-for-Pipa-camera-bring-up.patch
Patch0005:      0005-media-i2c-hi846-Fix-power-on-reset-sequencing.patch
Patch0006:      0006-media-i2c-hi846-Retry-clock-enable-and-set-rate-on-po.patch
Patch0007:      0007-media-i2c-ov13b10-Retry-clock-enable-and-set-rate-on-power_on.patch
Patch0008:      0008-clk-qcom-clk-rcg2-Keep-force-enable-in-shared_enable-t.patch
Patch0009:      0009-media-i2c-ov13b10-Add-get_selection-pad-operation.patch
Patch0010:      0010-media-hi846-Set-clock-to-24MHz.patch
Patch0012:      0012-arm64-dts-qcom-sm8250-xiaomi-pipa-Fix-TDM-dout-pin-d.patch
Patch0013:      0013-arm64-dts-qcom-sm8250-xiaomi-pipa-Fix-OV13B10-rear-c.patch
Patch0014:      0014-media-qcom-camss-Fix-video-pipeline-stop-streaming-s.patch
Patch0016:      0016-arm64-dts-qcom-sm8250-xiaomi-pipa-Add-dvdd-supply-fo.patch
Patch0017:      0017-remoteproc-qcom-emit-uevent-on-ADSP-crash-restart.patch
Patch0018:      0018-soc-qcom-qmi-return-error-on-lookup-server-registra.patch
Patch0019:      0019-soc-qcom-pdr-retry-service-lookup-on-transient-fail.patch
Patch0020:      0020-aw88261-reduce-boot-spam-and-use-sync-start.patch
Patch0021:      0021-arm64-dts-qcom-sm8250-xiaomi-pipa-Add-front-camera-s.patch

BuildRequires:  bc
BuildRequires:  bison
BuildRequires:  cpio
BuildRequires:  dwarves
BuildRequires:  elfutils-devel
BuildRequires:  flex
BuildRequires:  gcc
BuildRequires:  hostname
BuildRequires:  kmod
BuildRequires:  make
BuildRequires:  openssl-devel
BuildRequires:  perl-interpreter
BuildRequires:  python3
BuildRequires:  rsync
BuildRequires:  tar
BuildRequires:  xz

Requires:       dracut
Requires:       kmod
Requires:       xiaomi-pipa-firmware
Provides:       kernel = %{kversion}
Conflicts:      kernel

%description
Custom Linux kernel %{kversion} for the Xiaomi Pad 6 (SM8250 / pipa).
Includes device tree, camera, audio, sensor, and CAMSS patches.

%package headers
Summary:        Header files for kernel-pipa
Provides:       kernel-headers = %{kversion}
Conflicts:      kernel-headers

%description headers
Kernel header files for building out-of-tree modules against kernel-pipa.

%package modules
Summary:        Kernel modules for kernel-pipa
Requires:       kernel-pipa = %{version}-%{release}
Provides:       kernel-modules = %{kversion}

%description modules
Loadable kernel modules for kernel-pipa.

%prep
%setup -q -n linux-%{commit}
cp %{SOURCE1} .config

%patch -P 0002 -p1
%patch -P 0003 -p1
%patch -P 0004 -p1
%patch -P 0005 -p1
%patch -P 0006 -p1
%patch -P 0007 -p1
%patch -P 0008 -p1
%patch -P 0009 -p1
%patch -P 0010 -p1
%patch -P 0012 -p1
%patch -P 0013 -p1
%patch -P 0014 -p1
%patch -P 0016 -p1
%patch -P 0017 -p1
%patch -P 0018 -p1
%patch -P 0019 -p1
%patch -P 0020 -p1
%patch -P 0021 -p1

make EXTRAVERSION="-%{kextra}" olddefconfig

%build
make EXTRAVERSION="-%{kextra}" -j%{_smp_mflags} Image Image.gz modules dtbs

%install
KernelVer=$(make EXTRAVERSION="-%{kextra}" kernelrelease)

# Kernel image + DTB
install -Dm644 arch/arm64/boot/Image.gz %{buildroot}/boot/vmlinuz-${KernelVer}
install -Dm644 arch/arm64/boot/Image    %{buildroot}/boot/vmlinuz-${KernelVer}.uncompressed
install -Dm644 arch/arm64/boot/Image.gz %{buildroot}/boot/Image.gz
install -Dm644 arch/arm64/boot/Image    %{buildroot}/boot/Image
install -Dm644 System.map               %{buildroot}/boot/System.map-${KernelVer}
install -Dm644 .config                  %{buildroot}/boot/config-${KernelVer}
install -Dm644 arch/arm64/boot/dts/qcom/sm8250-xiaomi-pipa.dtb \
    %{buildroot}/boot/dtbs/qcom/sm8250-xiaomi-pipa.dtb

# Modules
make EXTRAVERSION="-%{kextra}" INSTALL_MOD_PATH=%{buildroot}/usr modules_install

ModDir=%{buildroot}/usr/lib/modules/${KernelVer}
install -d ${ModDir}/devicetree
cp arch/arm64/boot/dts/qcom/sm8250-xiaomi-pipa.dtb ${ModDir}/devicetree/
ln -s devicetree ${ModDir}/dtb
cp arch/arm64/boot/Image.gz ${ModDir}/vmlinuz
cp arch/arm64/boot/Image    ${ModDir}/vmlinuz.uncompressed
rm -f ${ModDir}/build ${ModDir}/source

# Headers
make EXTRAVERSION="-%{kextra}" INSTALL_HDR_PATH=%{buildroot}/usr headers_install
find %{buildroot}/usr/include -name '.*' -delete

%files
%license COPYING
/boot/vmlinuz-*
/boot/Image*
/boot/System.map-*
/boot/config-*
/boot/dtbs/

%files modules
/usr/lib/modules/

%files headers
/usr/include/

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 7.0.8-21
- Initial RPM packaging for Ultramarine OS pipa port
- 18 patches: camera, audio, sensor, CAMSS fixes
