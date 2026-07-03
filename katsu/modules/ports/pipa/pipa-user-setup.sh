#!/bin/bash
set -x

USER_NAME="pipa"
USER_PASS='$y$j9T$6/DebcxXazPrtBYnNXtEM.$yaUJHww5Mo1L8xNJ9IDJ.bvKOrIJxAG9PGQKWioBMx3'

useradd -m -G wheel -s /bin/bash "$USER_NAME" || true
echo "${USER_NAME}:${USER_PASS}" | chpasswd -e

echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pipa
chmod 440 /etc/sudoers.d/pipa

echo "root:${USER_PASS}" | chpasswd -e
