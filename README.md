# 🐇 White Rabbit – Wireless Security Toolkit

A modular and user-friendly toolkit designed for educational wireless security assessment, network research, and ethical penetration testing in controlled environments.
White Rabbit streamlines common Wi-Fi analysis tasks through a simple Bash-based interface.

🚀 Features
# 🛠️ Core Functionalities

- Monitor Mode Management
 Easily enable or disable monitor mode on supported wireless interfaces.

- Network Discovery
Scan for nearby wireless networks and access points across multiple channels.

- Targeted Analysis
Perform detailed scans on specific access points.

- WPS Discovery
Identify WPS-enabled networks for vulnerability research.

- Handshake Capture
Capture WPA/WPA2 authentication handshakes for offline analysis.

- Deauthentication Testing (for research & training only)
Run controlled deauth tests in approved environments.

- Results Management
Save and view scan results for later analysis.

# 📊 Scan Types

- Basic Network Discovery
Broad scan of all available channels.

- Targeted AP Scan
Focus on a specific access point for detailed reconnaissance.

- WPS Discovery
Identify networks with WPS enabled.

- Handshake Capture
Capture authentication handshakes for offline analysis.

# 📋 Prerequisites
# 🖥️ System Requirements

- Linux-based OS (Kali Linux recommended)

- Root or sudo privileges

- Wireless adapter supporting monitor mode

- airmon-ng (included with Aircrack-ng suite)

# 🛠️ Installation
# Clone the repository
👉 sudo git clone https://github.com/whiterabbit168/wireless-security-toolkit.git

👉 cd wireless-security-toolkit


# Make the script executable
sudo chmod +x wireless-security-toolkit.sh

# ▶️ Running the Tool

sudo ./wireless-security-toolkit.sh

# 📖 Usage Guide
Menu Options

1. Enable Monitor Mode
Prepare your wireless adapter for packet capture.

2. Basic Network Discovery
Scan all channels for visible Wi-Fi networks.

3. Targeted AP Scan
Analyze a specific access point in detail.

4. WPS Discovery
Detect WPS-enabled networks.

5. Handshake Capture
Capture WPA/WPA2 authentication handshakes.

6. View Scan Results
Display results saved from previous scans.

7. Disable Monitor Mode
Restore normal Wi-Fi functionality.

8. Stop Deauth Attack
Halt any ongoing deauthentication processes.

9. Deauthentication Attack (educational research only)
Conduct test deauth operations within legal environments.

10. Exit Program
11. Clean and safe shutdown.

# ⚖️ Ethical Guidelines
# ✅ Allowed

- Testing your own network

- Using in a controlled lab environment

- Obtaining written permission when testing for others


# ❌ Not Allowed ប្រយ័ត្នបាប​ រំខានអ្នកដទៃ

- Scanning networks without authorization

- Disrupting private or public networks

- Using the tool for malicious or illegal activities

⚠️ This toolkit is for educational and authorized security testing only.
The developer is not responsible for misuse.

# 🤝 Contributions

Pull requests are welcome!
If you have ideas to expand features or improve stability, feel free to contribute.

# ⭐ Support White Rabbit

If you like this toolkit, consider giving it a star on GitHub!
🐇✨

