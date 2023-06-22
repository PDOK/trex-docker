FROM pdok/lighttpd:1.4.67 AS service

ARG trex_version=0.14.3

USER root

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Europe/Amsterdam

# Note: upgrade gdal once we migrate our lighttpd baseimage to a more recent debian image
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        libssl1.1 \
        gdal-bin \
        libgdal20 \
        curl \
        procps \
        supervisor && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get clean

# T-rex
RUN export $(cat /etc/os-release | grep VERSION_CODENAME) && \
    curl -O -L https://github.com/t-rex-tileserver/t-rex/releases/download/v${trex_version}/t-rex_${trex_version}-1.${VERSION_CODENAME}_amd64.deb && \
    dpkg -i t-rex_${trex_version}-1.${VERSION_CODENAME}_amd64.deb && \
    rm t-rex_*_amd64.deb

# Lighttpd
ADD generate-lighttpd-config.sh /srv/lighttpd/generate-lighttpd-config.sh
RUN chown www /srv/lighttpd/lighttpd.conf && \
    chown www /srv/lighttpd/generate-lighttpd-config.sh &&  \
    chmod +x /srv/lighttpd/generate-lighttpd-config.sh

# Supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

USER www

VOLUME ["/var/data/in"]
VOLUME ["/var/data/out"]

EXPOSE 80

ENV TREX_INSTANCES=1
ENV THREAD_COUNT=1

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
