#!/bin/bash

# Check for existing testfile and remove it
[ -f testfile ] && rm testfile

echo "----------------------------------------"
echo "CPU NAME: $(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{print $2}' | sed 's/^[ \t]*//')"
echo "TOTAL CORES: $(grep -c ^processor /proc/cpuinfo)"
echo "TOTAL RAM: $(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')"
echo "RAM DETAIL: $(sudo dmidecode --type memory 2>/dev/null | grep -E 'Type:|Speed:' | grep -v 'Unknown' | head -n 2 | awk -F: '{printf $2 " "}' | sed 's/^[ \t]*//')"
echo "AVAIABLE DISK SPACE: $(df -h / | awk 'NR==2 {print $4}')"

# Disk Write Speed (creating a 1GB file)
WRITE_SPEED=$(dd if=/dev/zero of=testfile bs=1G count=1 oflag=dsync 2>&1 | awk '/copied/ {print $NF " " $(NF-1)}')
echo "DISK WRITE SPEED: $WRITE_SPEED"

# Clear Cache and Disk Read Speed
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
READ_SPEED=$(dd if=testfile of=/dev/null bs=1G count=1 2>&1 | awk '/copied/ {print $NF " " $(NF-1)}')
echo "DISK READ SPEED:  $READ_SPEED"

# Clean up testfile
rm testfile


# Network Speed Test (official Ookla Speedtest CLI, default test size)
echo "Running network speed test (takes ~30-60 seconds)..."

OOKLA_VER="1.2.0"
SERVER_ID=""        # leave empty = auto-select closest/best server; or set e.g. SERVER_ID=1234
MAX_TIME=180        # hard cap for the whole test (seconds)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fail() {   # $1 = reason
    echo "DOWNLOAD SPEED: N/A ($1)"
    echo "UPLOAD SPEED:   N/A ($1)"
    echo "----------------------------------------"
    exit 1
}

# --- Make sure curl exists (install with default system packages if not) ---
ensure_curl() {
    command -v curl >/dev/null 2>&1 && return 0
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO="sudo" || return 1
    fi
    if   command -v apt-get >/dev/null 2>&1; then $SUDO apt-get update -qq >/dev/null 2>&1; $SUDO apt-get install -y -qq curl >/dev/null 2>&1
    elif command -v dnf     >/dev/null 2>&1; then $SUDO dnf install -y -q curl >/dev/null 2>&1
    elif command -v yum     >/dev/null 2>&1; then $SUDO yum install -y -q curl >/dev/null 2>&1
    elif command -v apk     >/dev/null 2>&1; then $SUDO apk add --no-cache curl >/dev/null 2>&1
    elif command -v zypper  >/dev/null 2>&1; then $SUDO zypper -n install curl >/dev/null 2>&1
    elif command -v pacman  >/dev/null 2>&1; then $SUDO pacman -Sy --noconfirm curl >/dev/null 2>&1
    else return 1
    fi
    command -v curl >/dev/null 2>&1
}

# --- Find or fetch the official Ookla binary ---
BIN=""
if command -v speedtest >/dev/null 2>&1 && speedtest --version 2>/dev/null | grep -qi 'ookla'; then
    BIN=$(command -v speedtest)
else
    ensure_curl || fail "curl missing and could not be installed"
    case "$(uname -m)" in
        x86_64|amd64)   ARCH="x86_64" ;;
        aarch64|arm64)  ARCH="aarch64" ;;
        armv7l|armv6l)  ARCH="armhf" ;;
        i386|i686)      ARCH="i386" ;;
        *) fail "unsupported CPU architecture: $(uname -m)" ;;
    esac
    URL="https://install.speedtest.net/app/cli/ookla-speedtest-${OOKLA_VER}-linux-${ARCH}.tgz"
    if ! curl -fsSL --max-time 60 "$URL" -o "$TMP/ookla.tgz"; then
        fail "could not download Ookla CLI from install.speedtest.net"
    fi
    tar -xzf "$TMP/ookla.tgz" -C "$TMP" speedtest >/dev/null 2>&1 || fail "could not extract Ookla CLI"
    chmod +x "$TMP/speedtest"
    BIN="$TMP/speedtest"
fi

# --- Run the test ---
ARGS="--accept-license --accept-gdpr -f json"
[ -n "$SERVER_ID" ] && ARGS="$ARGS -s $SERVER_ID"

if command -v timeout >/dev/null 2>&1; then
    timeout "$MAX_TIME" "$BIN" $ARGS > "$TMP/out.json" 2>&1
else
    "$BIN" $ARGS > "$TMP/out.json" 2>&1
fi
RC=$?

RESULT=$(grep '"type":"result"' "$TMP/out.json" | tail -1)

if [ -z "$RESULT" ]; then
    ERRMSG=$(grep '"message"' "$TMP/out.json" | tail -1 | sed -n 's/.*"message":"\([^"]*\)".*/\1/p')
    if [ "$RC" = "124" ]; then
        fail "test timed out after ${MAX_TIME}s"
    elif grep -qiE '429|too many|rate' "$TMP/out.json"; then
        fail "Rate limited by Ookla. Please try again in a few minutes"
    else
        fail "Ookla test failed${ERRMSG:+: $ERRMSG}"
    fi
fi

# --- Parse the JSON result (no jq / python needed) ---
num()  { echo "$RESULT" | sed -nE "s/$1/\1/p" | head -1; }
str()  { echo "$RESULT" | sed -nE "s/$1/\1/p" | head -1; }

PING_JITTER=$(num '.*"ping":\{"jitter":([0-9.]+),"latency":[0-9.]+.*')
PING_LAT=$(num '.*"ping":\{"jitter":[0-9.]+,"latency":([0-9.]+).*')
DL_BW=$(num '.*"download":\{"bandwidth":([0-9]+).*')
DL_BYTES=$(num '.*"download":\{"bandwidth":[0-9]+,"bytes":([0-9]+).*')
UL_BW=$(num '.*"upload":\{"bandwidth":([0-9]+).*')
UL_BYTES=$(num '.*"upload":\{"bandwidth":[0-9]+,"bytes":([0-9]+).*')
PLOSS=$(num '.*"packetLoss":([0-9.]+).*')
ISP=$(str '.*"isp":"([^"]*)".*')
EXT_IP=$(str '.*"externalIp":"([^"]*)".*')
SRV_NAME=$(str '.*"server":\{[^}]*"name":"([^"]*)".*')
SRV_HOST=$(str '.*"server":\{[^}]*"host":"([^"]*)".*')
SRV_LOC=$(str '.*"server":\{[^}]*"location":"([^"]*)".*')
SRV_CTRY=$(str '.*"server":\{[^}]*"country":"([^"]*)".*')
SRV_ID=$(num '.*"server":\{"id":([0-9]+).*')
RESULT_URL=$(str '.*"result":\{[^}]*"url":"([^"]*)".*')

mbit() { awk -v b="$1" 'BEGIN { if (b>0) printf "%.2f", b*8/1000000; else print "" }'; }
mb()   { awk -v b="$1" 'BEGIN { printf "%.0f", b/1000000 }'; }

DOWNLOAD=$(mbit "${DL_BW:-0}")
UPLOAD=$(mbit "${UL_BW:-0}")

# --- Output ---
echo "VPS IP:          ${EXT_IP:-N/A}"
echo "ISP:             ${ISP:-N/A}"
echo "TEST SERVER:     ${SRV_NAME:-N/A} (id ${SRV_ID:-N/A}, ${SRV_HOST:-N/A})"
echo "SERVER LOCATION: ${SRV_LOC:-N/A}, ${SRV_CTRY:-N/A}"
echo "PING:            ${PING_LAT:-N/A} ms (jitter ${PING_JITTER:-N/A} ms)"

if [ -n "$DOWNLOAD" ]; then
    echo "DOWNLOAD SPEED:  $DOWNLOAD Mbit/s ($(mb "${DL_BYTES:-0}") MB transferred)"
else
    echo "DOWNLOAD SPEED:  N/A (test failed)"
fi
if [ -n "$UPLOAD" ]; then
    echo "UPLOAD SPEED:    $UPLOAD Mbit/s ($(mb "${UL_BYTES:-0}") MB transferred)"
else
    echo "UPLOAD SPEED:    N/A (test failed)"
fi
echo "PACKET LOSS:     ${PLOSS:-0}%"
[ -n "$RESULT_URL" ] && echo "RESULT URL:      $RESULT_URL"

echo "----------------------------------------"
