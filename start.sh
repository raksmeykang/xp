#!/bin/bash
set -e

DISK="/storage/disk.qcow2"
ISO="/opt/xp.iso"
RAM="${RAM_SIZE:-512}"
CPU="${CPU_CORES:-1}"
RESOLUTION="${RESOLUTION:-1024x768}"

echo "=== Windows XP on ARM64 (QEMU x86 emulation) ==="

# Download XP ISO if not present
if [ ! -f "$ISO" ]; then
    echo "Downloading Windows XP ISO..."
    wget -q --show-progress -O "$ISO" \
        "https://archive.org/download/WinXPProSP3x86/en_windows_xp_professional_with_service_pack_3_x86_cd_x14-80428.iso" \
        || echo "WARNING: Could not download XP ISO. Place your own ISO at $ISO"
fi

# Create disk if not exists
if [ ! -f "$DISK" ]; then
    echo "Creating ${DISK_SIZE:-16G} disk image..."
    qemu-img create -f qcow2 "$DISK" "${DISK_SIZE:-16G}"
fi

# Start VNC server
Xvfb :0 -screen 0 ${RESOLUTION}x24 &
sleep 1

# Start QEMU
echo "Starting QEMU x86 emulation..."
qemu-system-i386 \
    -accel tcg,tb-size=512,multidec=on \
    -cpu pentium3,+sse \
    -smp ${CPU} \
    -m ${RAM} \
    -machine pc,accel=tcg \
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
    -name "Windows XP" &

QEMU_PID=$!

# Start VNC to WebSocket bridge
x11vnc -display :0 -forever -nopw -shared -rfbport 5900 &
sleep 1

websockify --web=/usr/share/novnc 6080 localhost:5900 &

# Start nginx
nginx -g "daemon off;" &

echo "=== Access Windows XP at http://localhost:8006 ==="
wait $QEMU_PID
