echo "----------------------------------------" && \
echo "TOTAL RAM INSTALLED: $(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')" && \
echo "TOTAL CORES : $(grep -c ^processor /proc/cpuinfo)" && \
echo "AVAIABLE DISK SPACE: $(df -h / | awk 'NR==2 {print $4}')" && \
RESULTS=$(curl -sSL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 - --simple 2>/dev/null) && \
echo "DOWNLOAD SPEED: $(echo "$RESULTS" | grep 'Download' | awk '{print $2 " " $3}')" && \
echo "UPLOAD SPEED:   $(echo "$RESULTS" | grep 'Upload' | awk '{print $2 " " $3}')" && \
echo "----------------------------------------"
