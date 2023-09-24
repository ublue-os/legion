ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}:-main"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-${BASE_IMAGE_NAME}${IMAGE_FLAVOR}}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS legion

ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

COPY legion-install.sh legion-packages.json /tmp/

# Remove Deck services when building for Legion Go
RUN if grep -q "deck" <<< ${BASE_IMAGE_NAME}; then \
    systemctl disable jupiter-fan-control.service && \
    systemctl disable jupiter-biosupdate.service && \
    systemctl disable jupiter-controller-update.service && \
    systemctl disable vpower.service && \
    systemctl --global disable sdgyrodsu.service && \
    rpm-ostree override remove \
        jupiter-fan-control \
        jupiter-hw-support-btrfs \
        powerbuttond \
        vpower \
        sdgyrodsu && \
    rm -rf /usr/lib/jupiter-dock-updater \
; fi

# Setup things which are the same for every image
RUN /tmp/legion-install.sh && \
    systemctl enable fprintd && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/tmp && chmod -R 1777 /tmp /var/tmp
