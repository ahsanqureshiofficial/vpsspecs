echo "----------------------------------------" && \
echo "TOTAL RAM INSTALLED: $(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')" && \
echo "TOTAL CORES : $(grep -c ^processor /proc/cpuinfo)" && \
echo "AVAIABLE DISK SPACE: $(df -h / | awk 'NR==2 {print $4}')" && \
echo -n "NETWORK SPEED: " && \
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | bash -c 'if command -v python3 &>/dev/null; then python3 - --simple; elif command -v python &>/dev/null; then python - --simple; elif command -v python2 &>/dev/null; then python2 - --simple; else echo "No Python installation found!"; exit 1; fi' | grep "Download" | awk '{print $2 " " $3}' && \
echo "----------------------------------------"
