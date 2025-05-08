#!/bin/bash

set -e

# ref: https://qfpl.io/posts/installing-nixos/

usage() {
  echo "$0 [-h] [-S SSID] [-P PASSPHRASE] -D DEVICE"
  echo ""
  echo "Options:"
  echo "  -h|--help:        Show this message"
  echo "  -S|--ssid:        SSID to connect to"
  echo "  -P|--passphrase:  WPA passphrase for SSID"
  echo "  -D|--device:      Block device to install, e.g., /dev/nvme0n1p"
}

confirm_or_exit() {
  read -p "$1 [yn]" -n1 -s -r
  echo
  while true; do
    case $REPLY in
      y|Y|j|J) return ;;
      n|N) exit 1
    esac
  done
}

SSID=""
PASSPHRASE=""
DISK=""

while test $# -gt 0; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -S|--ssid)
      SSID=$2
      ;;
    -P|--passphrase)
      PASSPHRASE=$2
      ;;
    -D|--device)
      DISK=$2
      ;;
    esac
    shift; shift
done

if test -n "${SSID}" -a -n "${PASSPHRASE}"; then
  echo "Connecting to ${SSID}"
  wpa_passphrase "$SSID" "$PASSPHRASE" > /etc/wpa_supplicant.conf
  systemctl restart wpa_supplicant.service
elif test -n "${SSID}" -a -z "${PASSPHRASE}"; then
  echo "Passphrase not set"
elif test -z "${SSID}" -a -n "${PASSPHRASE}"; then
  echo "SSID not set"
fi

if ! ping -c1 github.com >/dev/null; then
  echo "No network"
  usage
  exit 1
fi

if test -z "${DISK}"; then
  echo "Must select disk to install on"
  usage
  exit 1
fi

sgdisk -p "${DISK}"
confirm_or_exit "Repartition '${DISK}'?"
echo

sgdisk -Z "${DISK}"
sgdisk \
  -n 1:0:+512M -c 1:boot -t 1:ef00 \
  -n 2:0:0 -c 2:sys -t 2:8e00 \
  "${DISK}"
sgdisk -p "${DISK}"
confirm_or_exit "continue?"
echo

BOOT_PARTITION=${DISK}p1
LVM_PARTITION=${DISK}p2

echo "Setting up LUKS"
cryptsetup luksFormat "${LVM_PARTITION}"
cryptsetup luksOpen "${LVM_PARTITION}" nixos-enc
echo

echo "Creating volume group"
pvcreate /dev/mapper/nixos-enc
vgcreate nixos-vg /dev/mapper/nixos-enc
echo

echo "Creating volumes"
((SWAP_SIZE=($(awk '/^MemTotal/{print $2}' /proc/meminfo) + 1024*1024 - 1) / 1024 / 1024))
echo "  swap: ${SWAP_SIZE} GiB"
lvcreate -L ${SWAP_SIZE}G -n swap nixos-vg
lvcreate -l 100%FREE -n root nixos-vg
echo

echo "Creating file systems"
mkfs.vfat -n boot "$BOOT_PARTITION"
mkfs.ext4 -L nixos /dev/nixos-vg/root
mkswap -L swap /dev/nixos-vg/swap
swapon /dev/nixos-vg/swap
echo

echo "Mounting file systems"
mount /dev/nixos-vg/root /mnt
mkdir /mnt/boot
mount "${BOOT_PARTITION}" /mnt/boot
echo

echo "Configuring system"
nixos-generate-config --root /mnt

echo "Copy hardware configuration from /mnt/etc/nixos:"
ls -lh /mnt/etc/nixos

echo ""
echo "Set LUKS device:"
echo '  boot.initrd.luks.devices.root.device = "'"${LVM_PARTITION}"'"'

echo ""
echo "Install using"
echo "  nixos-install --flake /path/to/flake#host"
