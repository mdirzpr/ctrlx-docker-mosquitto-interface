FROM arm64v8/debian:buster-slim

LABEL 	Description="This Dockerfile is used to create an SiteManager Embedded container for Linux on ARM v8" \
	Vendor="Secomea A/S" \
	Version="1.0"

ENV SME_GM_CONTROL=7

RUN apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -c "https://firmware.secomea.com/api/download?product=6142&installer=true" -O - | tar -xz && mkdir /etc/sitemanager && mkdir /etc/config \
  && cd /SiteManager_Installer && ./install.sh -y -n -d / -c /dev/null && rm -rf /SiteManager_Installer

COPY config /etc/config

EXPOSE 11444/tcp

LABEL description="ctrlX SiteManager"
LABEL maintainer="S-Gilk <https://github.com/S-Gilk>"

ENTRYPOINT ["/bin/sh", "/etc/config/init.sh"]
# ENTRYPOINT "/sitemanager"