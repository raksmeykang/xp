FROM arm64v8/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    supervisor \
    websockify \
    python3-numpy \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc_auto.html /opt/noVNC/index.html

WORKDIR /opt

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

EXPOSE 8006

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
