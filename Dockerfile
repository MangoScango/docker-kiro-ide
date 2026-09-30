# syntax=docker/dockerfile:1
# Kiro IDE in the browser — fork of linuxserver/docker-vscode with VS Code swapped for Kiro.

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

ARG BUILD_DATE
ARG VERSION
# Pin a Kiro release (e.g. 1.1.70); leave empty to pull the current stable.
ARG KIRO_VERSION
ARG TARGETARCH
LABEL build_version="Kiro IDE version:- ${VERSION} Build-date:- ${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/MangoScango/docker-kiro-ide"

ENV TITLE="Kiro" \
    NO_GAMEPAD=true \
    PIXELFLUX_WAYLAND=true

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    caja \
    chromium \
    chromium-l10n \
    git \
    gnome-keyring \
    jq \
    ssh-askpass \
    stterm && \
  echo "**** install kiro ****" && \
  case "${TARGETARCH:-amd64}" in \
    amd64) KIRO_ARCH=x64 ;; \
    arm64) KIRO_ARCH=arm64 ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  if [ -z "${KIRO_VERSION}" ]; then \
    KIRO_URL=$(curl -fsSL "https://prod.download.desktop.kiro.dev/stable/metadata-linux-${KIRO_ARCH}-deb-stable.json" \
      | jq -r '.releases[].updateTo.url | select(endswith(".deb"))' | head -n1); \
  else \
    KIRO_URL="https://prod.download.desktop.kiro.dev/releases/stable/linux-${KIRO_ARCH}/signed/${KIRO_VERSION}/deb/kiro-ide-${KIRO_VERSION}-stable-linux-${KIRO_ARCH}.deb"; \
  fi && \
  echo "Downloading ${KIRO_URL}" && \
  curl -fsSL -o /tmp/kiro.deb "${KIRO_URL}" && \
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y /tmp/kiro.deb && \
  echo "**** container tweaks ****" && \
  cp /usr/share/pixmaps/code-oss.png /usr/share/selkies/www/icon.png && \
  mv /usr/bin/chromium /usr/bin/chromium-real && \
  # deb symlinks /usr/bin/kiro -> real binary; remove so COPY doesn't clobber the target
  rm -f /usr/bin/kiro && \
  printf "Kiro IDE version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# add local files (wrappers + openbox autostart/menu)
COPY /root /

EXPOSE 3001

VOLUME /config
