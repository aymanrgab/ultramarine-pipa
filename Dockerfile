FROM fedora:44

RUN dnf install -y \
    git wget rsync zip unzip \
    e2fsprogs dosfstools mtools util-linux \
    python3 tar xz \
    dracut grub2-tools grub2-efi-aa64 grub2-efi-aa64-modules \
    shim-aa64 efibootmgr \
    android-tools \
    && dnf clean all

RUN dnf install -y 'dnf-command(copr)' && \
    dnf copr enable -y terrapkg/terra && \
    dnf install -y katsu && \
    dnf clean all

WORKDIR /build

COPY . /build/

RUN chmod +x scripts/*.sh

ENTRYPOINT ["/build/scripts/ci-build.sh"]
