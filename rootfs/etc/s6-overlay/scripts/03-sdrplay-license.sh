#!/bin/bash

#shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

ARCH=$(uname -m)

# if we're on an unsupported architecture SDR play isn't installed, exit
if [ "${ARCH}" != "aarch64" ] && [ "$ARCH" != "x86_64" ]; then
    exit 0
fi

# see if the user has sdrplay in the $SOAPYSDR $SOAPYSDRDRIVER text

if [ -z "$SOAPYSDR" ] && [ -z "$SOAPYSDRDRIVER" ]; then
    exit 0
fi

# if the user has sdrplay in the $SOAPYSDR $SOAPYSDRDRIVER text

if [[ "$SOAPYSDR" != *"sdrplay"* ]] && [[ "$SOAPYSDRDRIVER" != *"sdrplay"* ]]; then
    exit 0
fi

# verify we have the license file

if [ ! -f /sdrplay_license.txt ]; then
    echo "No license file found. Exiting..."
    exit 0
fi

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)

#shellcheck disable=SC2154
"${s6wrap[@]}" echo "This container uses SDRPlay API V3. If you are using a device that will use SDRPlay please be sure"
"${s6wrap[@]}" echo "you are conforming to the license agreement."
"${s6wrap[@]}" echo "docker exec -it <container name> cat /sdrplay_license.txt"
"${s6wrap[@]}" echo "to view the license"
