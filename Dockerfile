FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    supervisor \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN wget -q -O xp.iso \
    "https://archive.org/download/WinXPProSP3x86/en_windows_xp_professional_with_service_pack_3_x86_cd_vl_x14-73974.iso"

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

EXPOSE 8006

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
