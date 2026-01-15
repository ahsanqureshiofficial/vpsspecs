# Check for existing testfile and remove it
[ -f testfile ] && rm testfile

echo "----------------------------------------" && \
echo "CPU NAME: $(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{print $2}' | sed 's/^[ \t]*//')" && \
echo "TOTAL CORES: $(grep -c ^processor /proc/cpuinfo)" && \
echo "TOTAL RAM: $(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')" && \
echo "RAM DETAIL: $(sudo dmidecode --type memory 2>/dev/null | grep -E 'Type:|Speed:' | grep -v 'Unknown' | head -n 2 | awk -F: '{printf $2 " "}' | sed 's/^[ \t]*//')" && \
echo "AVAIABLE DISK SPACE: $(df -h / | awk 'NR==2 {print $4}')" && \
# Disk Write Speed (creating a 1GB file)
WRITE_SPEED=$(dd if=/dev/zero of=testfile bs=1G count=1 oflag=dsync 2>&1 | awk '/copied/ {print $NF " " $(NF-1)}') && \
echo "DISK WRITE SPEED: $WRITE_SPEED" && \
# Clear Cache and Disk Read Speed
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null && \
READ_SPEED=$(dd if=testfile of=/dev/null bs=1G count=1 2>&1 | awk '/copied/ {print $NF " " $(NF-1)}') && \
echo "DISK READ SPEED:  $READ_SPEED" && \
# Clean up testfile
rm testfile && \
# Network Speed Tests
RESULTS=$(curl -sSL raw.githubusercontent.com | python3 - --simple 2>/dev/null) && \
echo "DOWNLOAD SPEED: $(echo "$RESULTS" | grep 'Download' | awk '{print $2 " " $3}')" && \
echo "UPLOAD SPEED:   $(echo "$RESULTS" | grep 'Upload' | awk '{print $2 " " $3}')" && \
echo "----------------------------------------"



