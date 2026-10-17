Linux System Metrics One-Liner
A lightweight, zero-installation bash command to instantly retrieve key hardware and network performance data on Linux systems.
✨ Features

    RAM Info: Extracts total installed memory from /proc/meminfo.
    CPU Cores: Counts logical processors using /proc/cpuinfo.
    Disk Space: Reports available space on the root partition (/).
    Network Speed: Performs a real-time speed test via speedtest-cli (Python-based).

🚀 Usage
Simply copy and paste the following command into your terminal:
```
command -v curl >/dev/null || (apt-get update -y && apt-get install curl -y) && curl -sSL https://raw.githubusercontent.com/ahsanqureshiofficial/vpsspecs/refs/heads/main/vpsspecs.sh | tr -d '\r' | bash
```
**Test Speedtest Only**
```
command -v curl >/dev/null || (apt-get update -y && apt-get install -y curl) && curl -sSL https://raw.githubusercontent.com/ahsanqureshiofficial/vpsspecs/refs/heads/main/speedtestonly.sh | tr -d '\r' | bash
```

Use code with caution.

### 🖥️ Sample Output
```
---
root@user:*****
----------------------------------------
----------------------------------------
CPU NAME: AMD EPYC 7713 64-Core Processor
TOTAL CORES: 1
TOTAL RAM: 1.92 GB
RAM DETAIL: Multi-bit ECC  RAM
AVAIABLE DISK SPACE: 44G
DISK WRITE SPEED: MB/s 478
DISK READ SPEED:  MB/s 866
Running network speed test (takes ~30-60 seconds)...
VPS IP:          192.168.8.1
ISP:             Akamai Connected Cloud
TEST SERVER:     TELE AG (id 44477, speedtest.58243.as)
SERVER LOCATION: Frankfurt, Germany
PING:            0.617 ms (jitter 0.025 ms)
DOWNLOAD SPEED:  20397.13 Mbit/s (15259 MB transferred)
UPLOAD SPEED:    2022.83 Mbit/s (3129 MB transferred)
PACKET LOSS:     0%
RESULT URL:      https://www.speedtest.net/result/c/testresult
----------------------------------------

----------------------------------------
```



Use code with caution.
🛠️ Requirements

    OS: Any Linux distribution (Ubuntu, Debian, CentOS, etc.).
    Dependencies: curl and python (2 or 3) are required for the network speed test.

🤝 Contributing
Contributions are welcome! Feel free to fork this repository and submit pull requests for any improvements or additional metrics.
📄 License
This project is open-source and available under the MIT License.
