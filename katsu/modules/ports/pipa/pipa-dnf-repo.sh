#!/bin/bash
set -eux

install -d /etc/yum.repos.d

cat > /etc/yum.repos.d/pipa-pkgs.repo <<'EOF'
[pipa-pkgs]
name=Pipa Packages for Xiaomi Pad 6
baseurl=https://thespider2.github.io/pipa-pkgs/repo/ultramarine/
enabled=1
gpgcheck=0
skip_if_unavailable=True
EOF
