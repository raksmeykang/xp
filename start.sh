#!/bin/bash
set -e

DISK="/storage/disk.qcow2"
ISO="/opt/xp.iso"
RAM="${RAM_SIZE:-512}"
CPU="${CPU_CORES:-1}"

echo "=== Windows XP on ARM64 (QEMU x86 emulation) ==="

mkdir -p /storage

# Create disk if not exists
if [ ! -f "$DISK" ]; then
    echo "Creating ${DISK_SIZE:-16G} disk image..."
    qemu-img create -f qcow2 "$DISK" "${DISK_SIZE:-16G}"
fi

# Start QEMU
echo "Starting QEMU x86 emulation..."
exec qemu-system-i386 \
    -accel tcg,tb-size=512 \
    -cpu pentium3,+sse \
    -smp ${CPU} \
    -m ${RAM} \
    -drive file="$DISK",format=qcow2,if=virtio,cache=none,discard=unmap,aio=native \
    -cdrom "$ISO" \
    -boot d \
    -vga virtio \
    -display none \
    -vnc :0 \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
    -usb \
    -device usb-tablet \
    -name "Windows XP"
