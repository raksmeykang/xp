FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    wget \
    curl \
    genisoimage \
    xorriso \
    supervisor \
    novnc \
    websockify \
    tightvncserver \
    ratpoison \
    nginx \
    pulseaudio \
    xvfb \
    x11-utils \
    xorg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

EXPOSE 8006

CMD ["/opt/start.sh"]
