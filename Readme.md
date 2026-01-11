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
command -v curl >/dev/null || (apt-get update -y && apt-get install curl -y) && curl -sSL https://raw.githubusercontent.com/ahsanqureshiofficial/vpsspecs/refs/heads/main/vpsspecs.sh | sh
```

Use code with caution.

### 🖥️ Sample Output
```
---
root@user:*****
----------------------------------------
TOTAL RAM INSTALLED: 30.49 GB
TOTAL CORES : 8
AVAIABLE DISK SPACE: 462G
NETWORK SPEED: 831.99 Mbit/s
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
