# Docker-SDRPlay-Beast1090

<img align="right" alt="SDR-Enthusiasts logo" src="https://raw.githubusercontent.com/sdr-enthusiasts/sdr-enthusiast-assets/main/SDR%20Enthusiasts.svg" height="300">

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

<details>
  <summary>&lt;&dash;&dash; Click the arrow to see all possible command line options you can pass to `dump1090` using the <code>DUMP1090_EXTRA_ARGS</code> parameter</summary>

```text
-------------------------------------------------------------------------------
| dump1090 ModeS Receiver     dump1090-mutability dump1090_mutability_sdrplay |
-------------------------------------------------------------------------------
--device-index <index>     Select RTL device (default: 0)
--dev-sdrplay              use RSP device instead of RTL device (default: RTL).
--ifMode                   IF Mode (0: ZIF, 1: LIF) (default: 0).
--bwMode                   BW Mode (0: 1.536MHz, 1: 5MHz) (default: 1).
--gain <db>                Set gain (default: max gain. Use -10 for auto-gain)
--enable-agc               Enable the Automatic Gain Control (default: RTL:off, RSP:on)
--freq <hz>                Set frequency (default: 1090 Mhz)
--ifile <filename>         Read data from file (use '-' for stdin)
--iformat <format>         Sample format for --ifile: UC8 (default), SC16, SC16int, or SC16Q11
--throttle                 When reading from a file, play back in realtime, not at max speed
--interactive              Interactive mode refreshing data on screen. Implies --throttle
--interactive-rows <num>   Max number of rows in interactive mode (default: 15)
--interactive-ttl <sec>    Remove from list if idle for <sec> (default: 60)
--interactive-rtl1090      Display flight table in RTL1090 format
--raw                      Show only messages hex values
--net                      Enable networking
--modeac                   Enable decoding of SSR Modes 3/A & 3/C
--net-only                 Enable just networking, no SDR device or file used
--net-bind-address <ip>    IP address to bind to (default: Any; Use 127.0.0.1 for private)
--net-http-port <ports>    HTTP server ports (default: 8080)
--net-ri-port <ports>      TCP raw input listen ports  (default: 30001)
--net-ro-port <ports>      TCP raw output listen ports (default: 30002)
--net-sbs-port <ports>     TCP BaseStation output listen ports (default: 30003)
--net-bi-port <ports>      TCP Beast input listen ports  (default: 30004,30104)
--net-bo-port <ports>      TCP Beast output listen ports (default: 30005)
--net-ro-size <size>       TCP output minimum size (default: 0)
--net-ro-interval <rate>   TCP output memory flush rate in seconds (default: 0)
--net-heartbeat <rate>     TCP heartbeat rate in seconds (default: 60 sec; 0 to disable)
--net-buffer <n>           TCP buffer size 64Kb * (2^n) (default: n=0, 64Kb)
--net-verbatim             Do not apply CRC corrections to messages we forward; send unchanged
--forward-mlat             Allow forwarding of received mlat results to output ports
--lat <latitude>           Reference/receiver latitude for surface posn (opt)
--lon <longitude>          Reference/receiver longitude for surface posn (opt)
--max-range <distance>     Absolute maximum range for position decoding (in nm, default: 300)
--fix                      Enable single-bits error correction using CRC
--no-fix                   Disable single-bits error correction using CRC
--no-crc-check             Disable messages with broken CRC (discouraged)
--phase-enhance            Enable phase enhancement
--mlat                     display raw messages in Beast ascii mode
--stats                    With --ifile print stats at exit. No other output
--stats-range              Collect/show range histogram
--stats-every <seconds>    Show and reset stats every <seconds> seconds
--onlyaddr                 Show only ICAO addresses (testing purposes)
--metric                   Use metric units (meters, km/h, ...)
--hae                      Show altitudes as HAE (with H suffix) when available
--snip <level>             Strip IQ file removing samples < level
--debug <flags>            Debug mode (verbose), see README for details
--quiet                    Disable output to stdout. Use for daemon applications
--show-only <addr>         Show only messages from the given ICAO on stdout
--ppm <error>              Set receiver error in parts per million (default 0)
--html-dir <dir>           Use <dir> as base directory for the internal HTTP server. Defaults to ./public_html
--write-json <dir>         Periodically write json output to <dir> (for serving by a separate webserver)
--write-json-every <t>     Write json output every t seconds (default 1)
--json-location-accuracy   <n>  Accuracy of receiver location in json metadata: 0=no location, 1=approximate, 2=exact
--oversample               Use the 2.4MHz(RTL) / 8MHz(RSP) demodulator
--dcfilter                 Apply a 1Hz DC filter to input data (requires lots more CPU)
--measure-noise            Measure noise power (requires slightly more CPU)
--rsp-device-serNo <serNo> Used to select between multiple devices when more than one RSP device is present
--rsp2-antenna-portA       Select Antenna Port A on RSP2 (default Antenna Port B)
--rspdx-antenna-portA      Select Antenna Port A on RSPdx (default Antenna Port B)
--rspduo-tuner1            Select Tuner 1 on RSPduo (default Tuner 2 if Master or Single Tuner)
--rspduo-single            Use Single Tuner mode for RSPduo if available (default Master/Slave mode)
--adsbMode                 Set SDRplay ADSB mode (default 1 for ZIF and 2 for LIF)
--enable-biasT             Enable BiasT network on RSP2/RSPdx Antenna Port B or RSP1A or RSPduo Tuner 2
--disable-broadcast-notch  Disable Broadcast notch filter (RSP1A/RSP2/RSPdx/RSPduo)
--disable-dab-notch        Disable DAB notch filter (RSP1A/RSPdx/RSPduo)
--help                     Show this help

ADSB Modes 0 = ADSB_DECIMATION, 1 = ADSB_NO_DECIMATION_LOWPASS, 2 = ADSB_NO_DECIMATION_BANDPASS_2MHZ
           3 = ADSB_NO_DECIMATION_BANDPASS_3MHZ

Debug mode flags: d = Log frames decoded with errors
                  D = Log frames decoded with zero errors
                  c = Log frames with bad CRC
                  C = Log frames with good CRC
                  p = Log frames with bad preamble
                  n = Log network debugging info
                  j = Log frames to frames.js, loadable by debug.html
```

</details>

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
