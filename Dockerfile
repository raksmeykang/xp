FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    supervisor \
    novnc \
    websockify \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

EXPOSE 8006

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
