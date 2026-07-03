%global _firmwarepath /usr/lib/firmware
%global _hexagonpath /usr/share/qcom/sm8250/Xiaomi/pipa
%global commit 842d35beffeda8c6d1b0e611b335543bf0e6b41e
%global shortcommit %(c=%{commit}; echo ${c:0:12})
%global __requires_exclude ^.*\\.so.*$

Name:           xiaomi-pipa-firmware
Version:        1.1
Release:        3%{?dist}
Summary:        Firmware package for Xiaomi Pad 6 (pipa)
License:        Proprietary
URL:            https://github.com/pipa-mainline/xiaomi-pipa-firmware
BuildArch:      noarch

Source0:        %{url}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz
Source1:        awinic_firmware.files
Source2:        dsp_firmware.files
Source3:        qcom_firmware.files
Source4:        novatek_firmware.files
Source5:        nuvolta_firmware.files

Requires:       linux-firmware

%description
Firmware for various components in Xiaomi Pad 6 (pipa) including
speaker amplifiers, DSP, touchscreen, SoC, and wireless charging.

%prep
tar -xzf %{SOURCE0}

%install
cd %{name}-%{commit}

for firmware in $(cat %{SOURCE1}); do
    install -Dm644 "${firmware}" "%{buildroot}/%{_firmwarepath}/awinic/$(basename "${firmware}")"
done

for firmware in $(cat %{SOURCE2}); do
    install -Dm644 "${firmware}" "%{buildroot}/${firmware}"
done

for firmware in $(cat %{SOURCE3}); do
    install -Dm644 "${firmware}" "%{buildroot}/%{_firmwarepath}/qcom/sm8250/xiaomi/pipa/$(basename "${firmware}")"
done

for firmware in $(cat %{SOURCE4}); do
    install -Dm644 "${firmware}" "%{buildroot}/%{_firmwarepath}/novatek/$(basename "${firmware}")"
done

for firmware in $(cat %{SOURCE5}); do
    install -Dm644 "${firmware}" "%{buildroot}/%{_firmwarepath}/nuvolta/$(basename "${firmware}")"
done

%files
%{_firmwarepath}/qcom/*
%{_firmwarepath}/novatek/*
%{_firmwarepath}/nuvolta/*
%{_firmwarepath}/awinic/*
%{_hexagonpath}/*

%changelog
* Thu Jul 03 2026 Ayman <ayman@pipa> - 1.1-3
- Initial Ultramarine OS packaging
