<img align="right" src="https://raw.githubusercontent.com/sdr-enthusiasts/sdr-enthusiast-assets/main/SDR%20Enthusiasts.svg" height="300">

# Docker-SDRPlay-Beast1090

An ADSB receiver for SDRPlay SDRs with output in BEAST and other formats

## Table of Contents

- [Docker-SDRPlay-Beast1090](#docker-sdrplay-beast1090)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Compatibility](#compatibility)
  - [Installation and use](#installation-and-use)
    - [Prerequisite: install `udev` rules on your host system](#prerequisite-install-udev-rules-on-your-host-system)
    - [Going live with Docker Compose](#going-live-with-docker-compose)
    - [Message decoding introspection](#message-decoding-introspection)

## Introduction

This repo and its accompanying container package provides an easy way to receive ADSB (1090 MHz) data using any of the SDRPlay devices. It consists of the SDRPlay API and a "special" version of dump1090 that is set up to communicate with the SDRPlay driver.

## Compatibility

The SDRPlay API supports all current and past SDRPlay SDR devices, including RSP1a, RSP1b, RSPdx, RSPduo, RSP1 (discontinued), RSP2 (discontinued), and RSP2Pro (discontinued).

The container is compatible with `arm64` and `amd64`. It is not compatible with some of the older, 32-bits architectures because the SDRPlay driver hasn't been released for these. However, it should work fine on Raspberry Pi 3B+, 4B with 64-bits OS, and on most Intel Linux machines.

## Installation and use

### Prerequisite: install `udev` rules on your host system

To ensure that the container has access to the SDRPlay device, you should install SDRPlay-specific `udev` rules on your host system. You can do this with these commands:

```bash
sudo mkdir -p -m 0755 /etc/udev/rules.d /etc/udev/hwdb.d
sudo curl -sL -o curl -sL -o /etc/udev/rules.d/66-mirics.rules https://raw.githubusercontent.com/sdr-enthusiasts/install-libsdrplay/main/66-mirics.rules
sudo curl -sL -o /etc/udev/hwdb.d/20-sdrplay.hwdb https://raw.githubusercontent.com/sdr-enthusiasts/install-libsdrplay/main/20-sdrplay.hwdb
sudo chmod 0755 /etc/udev/rules.d /etc/udev/hwdb.d
sudo chmod go=r /etc/udev/rules.d/* /etc/udev/hwdb.d/*
```

After installing these `udev` rules, you should unplug and replug your SDRPlay device to make sure the rules take effect.

You should also have `docker` installed on your machine. If you haven't please see [here](https://github.com/sdr-enthusiasts/docker-install) for instructions.

### Going live with Docker Compose

You can use the [`docker-compose.yml`](https://github.com/sdr-enthusiasts/docker-sdrplay-beast1090/blob/main/docker-compose.yml) file in this repository as an example. Feel free to add the relevant part to an existing docker compose stack.

If you need to add any additional parameter to `dump1090`, you can do so using the `DUMP1090_EXTRA_ARGS` environment parameter in `docker-compose.yml`. For example:

```yaml
    environment:
      - DUMP1090_EXTRA_ARGS=--fix --max-range 500 --phase-enhance --lat ${FEEDER_LAT} --lon ${FEEDER_LONG} --adsbMode 1
```

If you use the [`docker-ultrafeeder`](https://github.com/sdr-enthusiasts/docker-adsb-ultrafeeder) container, you should add the following to the environment variables to feed the Beast data to that container:

```yaml
      - 
      - ULTRAFEEDER_CONFIG=
        ...
        adsb,sdrplay-beast1090,30005,beast_in;
```

After saving your `docker-compose.yml`, don't forget to start the service with `docker compose up -d`.

### Message decoding introspection

You can look at individual messages and what information they contain, either for all or for an individual aircraft by hex:

```bash
# auto-updating table with all aircraft:
docker exec -it sdrplay-beast1090 viewadsb

# only for hex 3D3ED0
docker exec -it sdrplay-beast1090 viewadsb --show-only 3D3ED0

# all aircraft in a continuous stream
docker exec -it sdrplay-beast1090 viewadsb --no-interactive

# show position / CPR debugging for hex 3D3ED0
docker exec -it sdrplay-beast1090 viewadsb --cpr-focus 3D3ED0
```
