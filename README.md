# Ultramarine OS for Xiaomi Pad 6 (pipa)

Ultramarine Linux (Fedora-based) port for the Xiaomi Pad 6, built with the
[Katsu](https://github.com/FyraLabs/katsu) image builder. Carries over all
hardware support from the [pipa-pkgs](https://github.com/aymanrgab/pipa-pkgs)
Arch Linux packages.

## What works

- Display (Freedreno / Mesa)
- Touchscreen (Novatek)
- Audio (AW88261 speaker amplifiers via TDM)
- WiFi and Bluetooth (ath11k / QCA6390)
- Rear camera (OV13B10, fixed-focus, via libcamera + SoftISP)
- Front camera (HI846, via libcamera + SoftISP CPU debayer)
- Sensors (accelerometer, gyroscope, light, proximity via SDSP/libssc)
- USB (host and peripheral)
- Battery and charging

## Repository structure

```
ultramarine-pipa/
├── specs/              # RPM .spec files for all pipa packages
├── sources/            # Patches, configs (populated by link-sources.sh)
├── katsu/              # Katsu image manifests
│   └── modules/ports/pipa/
│       ├── pipa.yaml           # Port module (packages + excludes)
│       ├── pipa-gnome.yaml     # Top-level GNOME disk image manifest
│       ├── pipa-grub-setup.sh  # GRUB configuration script
│       ├── pipa-services.sh    # Service enablement script
│       └── repodir/            # Local repo definition
├── scripts/            # Build, link, and flash helper scripts
├── assets/             # EFI template, vbmeta-disabled.img
├── repo/               # Built RPMs (local repo, git-ignored)
└── output/             # Final flash images (git-ignored)
```

## Building

### Prerequisites

- Fedora 44 (aarch64) or cross-build with `mock --arch=aarch64`
- `katsu` installed from [Terra](https://github.com/terrapkg/packages)
- `rpm-build`, `rpmdevtools`, `createrepo_c`, `mock`
- `/home/ayman/pipa-pkgs` with all patches and source files

### Quick build

```bash
# 1. Set up build environment
./scripts/setup-build-env.sh

# 2. Full pipeline: link sources -> build RPMs -> Katsu image -> flash images
./scripts/build-all.sh
```

### Step by step

```bash
# Link source files from pipa-pkgs
./scripts/link-sources.sh

# Build individual RPMs
./scripts/build-rpm.sh specs/kernel-pipa.spec
./scripts/build-rpm.sh specs/xiaomi-pipa-firmware.spec
# ... etc

# Refresh local repo
./scripts/refresh-repo.sh

# Build Katsu image
katsu -o disk-image katsu/modules/ports/pipa/pipa-gnome.yaml

# Post-process into flash images
sudo ./scripts/post-process-image.sh ultramarine-gnome-44-pipa.raw
```

## Flashing

Put the device into fastboot mode, then:

```bash
cd output/ultramarine-pipa-gnome-*/

# Single-boot (overwrites Android userdata)
./flash.sh

# Multiboot (flashes to a dedicated "linux" partition)
./flash-multiboot.sh linux boot_ab
```

### Partition mapping

| Image file | Target partition | Contents |
|---|---|---|
| `silicium.img` | `boot_ab` | Mu-Silicium UEFI firmware |
| `ultramarine_esp.raw` | `rawdump` | EFI System Partition |
| `ultramarine_boot.raw` | `cust` | /boot (kernel, initramfs, DTB, GRUB) |
| `ultramarine_rootfs.raw` | `userdata` | Root filesystem |

## Packages

| RPM Package | Source | Description |
|---|---|---|
| `kernel-pipa` | Custom 7.0.x kernel | 18 patches for camera, audio, sensors |
| `xiaomi-pipa-firmware` | Binary blobs | Speaker, DSP, touch, SoC firmware |
| `pipa-sound-conf` | WirePlumber config | Audio + camera PipeWire settings |
| `pipa-sensors` | Systemd units + udev | Sensor Core (SDSP) configuration |
| `pipa-dracut` | Dracut module | Initramfs firmware loading |
| `pipa-grub-config` | GRUB helper | Kernel-install plugin for GRUB |
| `hexagonrpc` | FastRPC daemon | DSP communication service |
| `libssc` | Patched upstream | Qualcomm Sensor Core library |
| `iio-sensor-proxy` | Patched upstream | D-Bus sensor proxy with SSC |
| `libcamera` | Patched upstream | Camera support with OV13B10/HI846 |
| `bootmac` | postmarketOS | MAC address configuration |
| `swclock-offset` | postmarketOS | Software clock for non-writable RTC |
| `pipa-metapkg` | Meta package | Pulls all pipa components |

## Credits

- Kernel and device tree work based on upstream Linux and Qualcomm SM8250 support
- Mu-Silicium UEFI firmware from [onesaladleaf/Mu-Silicium](https://github.com/onesaladleaf/Mu-Silicium)
- Image build system by [FyraLabs/Katsu](https://github.com/FyraLabs/katsu)
- Arch Linux packaging from [pipa-pkgs](https://github.com/aymanrgab/pipa-pkgs)
