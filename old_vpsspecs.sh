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

# Network Speed Tests using official speedtest-cli
echo "Running network speed test (may take a moment)..."
SPEEDTEST_OUTPUT=$(curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | bash -c '
    if command -v python3 &>/dev/null; then
        python3 -
    elif command -v python &>/dev/null; then
        python -
    elif command -v python2 &>/dev/null; then
        python2 -
    else
        echo "ERROR: No Python installation found!"
        exit 1
    fi
' 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$SPEEDTEST_OUTPUT" ]; then
    DOWNLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep -i 'Download:' | awk '{print $2 " " $3}')
    UPLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep -i 'Upload:' | awk '{print $2 " " $3}')
    echo "DOWNLOAD SPEED: $DOWNLOAD"
    echo "UPLOAD SPEED:   $UPLOAD"
else
    echo "DOWNLOAD SPEED: N/A (speed test failed)"
    echo "UPLOAD SPEED:   N/A (speed test failed)"
fi

echo "----------------------------------------"
