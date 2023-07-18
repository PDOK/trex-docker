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

# Add scripts
ADD ./generate-lighttpd-config.sh /etc/scripts/generate-lighttpd-config.sh
ADD ./generate-supervisord-config.sh /etc/scripts/generate-supervisord-config.sh
ADD ./entrypoint.sh /etc/scripts/entrypoint.sh

# Set permissions
RUN chown www /srv/lighttpd/lighttpd.conf && \
    chown -R www /etc/supervisor/conf.d && \
    chown -R www /etc/scripts && \
    chmod +x /etc/scripts/generate-lighttpd-config.sh && \
    chmod +x /etc/scripts/generate-supervisord-config.sh && \
    chmod +x /etc/scripts/entrypoint.sh

USER www

VOLUME ["/var/data/in"]

EXPOSE 80

ENV THREAD_COUNT=1

ENTRYPOINT ["/etc/scripts/entrypoint.sh"]
