FROM ghcr.io/sdr-enthusiasts/docker-baseimage:rtlsdr as build

RUN set -x && \
##define required packages
KEPT_PACKAGES=() && \
TEMP_PACKAGES=() && \
# packages needed to build
TEMP_PACKAGES+=(build-essential) && \
TEMP_PACKAGES+=(pkg-config) && \
TEMP_PACKAGES+=(git) && \
#
# install packages
apt-get update && \
apt-get install -q -o Dpkg::Options::="--force-confnew" -y --no-install-recommends  --no-install-suggests \
    "${KEPT_PACKAGES[@]}" \
    "${TEMP_PACKAGES[@]}" \
    && \
#
# Install the SDRPlay driver
mkdir -p /etc/udev/rules.d/ && \
curl --location --output /tmp/install_sdrplay.sh https://raw.githubusercontent.com/sdr-enthusiasts/install-libsdrplay/main/install_sdrplay.sh && \
chmod +x /tmp/install_sdrplay.sh && \
/tmp/install_sdrplay.sh --no-soapy && \
# build the special dump1090:
mkdir build && \
cd build && \
git clone --depth 1 --single-branch https://github.com/SDRplay/dump1090 && \
cd dump1090 && \
make RTLSDR=no AIRCRAFT_HASH_BITS=14 -j "$(nproc)" && \
cp dump1090 /

FROM ghcr.io/sdr-enthusiasts/docker-baseimage:wreadsb

ARG TARGETPLATFORM TARGETOS TARGETARCH

ENV S6_KILL_FINISH_MAXTIME=10000 \
    UPDATE_PLUGINS=true \
    SOAPYSDR=sdrplay

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=build /dump1090 /usr/bin/dump1090

RUN set -x && \
#
echo "TARGETPLATFORM $TARGETPLATFORM" && \
echo "TARGETOS $TARGETOS" && \
echo "TARGETARCH $TARGETARCH" && \
#
# define required packages
KEPT_PACKAGES=() && \
TEMP_PACKAGES=() && \
KEPT_PACKAGES+=(nano) && \
TEMP_PACKAGES+=(git) && \
#
# install packages
apt-get update && \
apt-get install -q -o Dpkg::Options::="--force-confnew" -y --no-install-recommends  --no-install-suggests \
    "${KEPT_PACKAGES[@]}" \
    "${TEMP_PACKAGES[@]}" \
    && \
#
# Install the SDRPlay driver
mkdir -p /etc/udev/rules.d/ && \
curl --location --output /tmp/install_sdrplay.sh https://raw.githubusercontent.com/sdr-enthusiasts/install-libsdrplay/main/install_sdrplay.sh && \
chmod +x /tmp/install_sdrplay.sh && \
/tmp/install_sdrplay.sh --no-soapy
#

COPY rootfs/ /

# Add Container Version
RUN set -x && \
pushd /tmp && \
    branch="##BRANCH##" && \
    [[ "${branch:0:1}" == "#" ]] && branch="main" || true && \
    git clone --depth=1 -b "$branch" https://github.com/sdr-enthusiasts/docker-sdrplay-beast1090.git && \
    cd docker-sdrplay-beast1090 && \
    echo "$(TZ=UTC date +%Y%m%d-%H%M%S)_$(git rev-parse --short HEAD)_$(git branch --show-current)" > "/.CONTAINER_VERSION" && \
popd && \
# Clean-up.
apt-get remove -y ${TEMP_PACKAGES[@]} && \
apt-get autoremove -y && \
rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
rm -f /usr/local/bin/viewadsb && ln -s /usr/local/bin/readsb /usr/local/bin/viewadsb
