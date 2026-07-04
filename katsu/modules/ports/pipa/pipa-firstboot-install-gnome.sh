#!/bin/bash
set -eux
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/pipa-firstboot-install.sh" gdm
