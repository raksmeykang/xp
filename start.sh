#!/bin/bash
set -e

DISK="/storage/disk.qcow2"
ISO="/storage/xp.iso"
RAM="${RAM_SIZE:-512}"
CPU="${CPU_CORES:-1}"

echo "=== Windows XP on ARM64 (QEMU x86 emulation) ==="

mkdir -p /storage

# Download XP ISO only if not already cached
if [ ! -f "$ISO" ]; then
    echo "Downloading Windows XP ISO (one-time)..."
    wget -q --show-progress -O "$ISO" \
        "https://archive.org/download/WinXPProSP3x86/en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso"
    echo "ISO cached at $ISO"
else
    echo "Using cached ISO: $ISO"
fi

# Create disk if not exists
if [ ! -f "$DISK" ]; then
    echo "Creating ${DISK_SIZE:-16G} disk image..."
    qemu-img create -f qcow2 "$DISK" "${DISK_SIZE:-16G}"
fi

# Decide boot order: disk needs >1.5GB to be a valid XP install
DISK_FILE_SIZE=$(stat -c%s "$DISK" 2>/dev/null || echo 0)
if [ "$DISK_FILE_SIZE" -lt 1500000000 ]; then
    echo "Disk empty or incomplete — booting from CD to install XP..."
    BOOT="-boot d"
else
    echo "Disk has valid install — booting from HDD..."
    BOOT="-boot c"
fi

# Start QEMU
echo "Starting QEMU x86 emulation..."
exec qemu-system-i386 \
    -accel tcg,tb-size=1024,thread=multi \
    -cpu pentium3,+sse \
    -smp ${CPU} \
    -m ${RAM} \
    -hda "$DISK" \
    -cdrom "$ISO" \
    ${BOOT} \
    -vga std \
    -display none \
    -vnc :0 \
    -device e1000,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
    -usb \
    -device usb-tablet \
    -name "Windows XP"
