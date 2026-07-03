FROM fedora:44

RUN dnf install -y \
    rpm-build rpmdevtools createrepo_c \
    git wget rsync zip unzip \
    e2fsprogs dosfstools mtools util-linux losetup \
    bc bison flex cpio kmod python3 tar xz \
    gcc gcc-c++ make meson ninja-build cmake \
    openssl-devel elfutils-devel dwarves hostname perl-interpreter \
    glib2-devel libgudev-devel polkit-devel libqmi-devel \
    protobuf-c-devel qrtr-devel systemd-devel \
    python3-devel python3-jinja2 python3-ply python3-pyyaml pybind11-devel \
    doxygen graphviz gtk-doc umockdev python3-dbusmock \
    gstreamer1-devel gstreamer1-plugins-base-devel \
    libdrm-devel libjpeg-turbo-devel libtiff-devel SDL2-devel libyaml-devel \
    qt6-qtbase-devel qt6-qttools-devel \
    dracut grub2-tools grub2-efi-aa64 grub2-efi-aa64-modules \
    shim-aa64 efibootmgr \
    systemd-rpm-macros \
    android-tools \
    && dnf clean all

RUN dnf install -y katsu 2>/dev/null || \
    dnf install -y 'dnf-command(copr)' && \
    dnf copr enable -y terrapkg/terra && \
    dnf install -y katsu || \
    echo "WARNING: katsu not available, install manually"

RUN rpmdev-setuptree

WORKDIR /build

COPY . /build/

RUN chmod +x scripts/*.sh

ENTRYPOINT ["/build/scripts/ci-build.sh"]
