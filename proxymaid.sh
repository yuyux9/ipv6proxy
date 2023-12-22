#!/usr/bin/env bash

# ----------------------------------
#-COLORZ-
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

#~WELCOME MESSAGE~
cat << "EOF"
                                                                                                    .       ..       
                                                      ..                                           @88>   dF         
 .d``            .u    .          u.      uL   ..    @L             ..    .     :                  %8P   '88bu.      
 @8Ne.   .u    .d88B :@8c   ...ue888b   .@88b  @88R 9888i   .dL   .888: x888  x888.        u        .    '*88888bu   
 %8888:u@88N  ="8888f8888r  888R Y888r '"Y888k/"*P  `Y888k:*888. ~`8888~'888X`?888f`    us888u.   .@88u    ^"*8888N  
  `888I  888.   4888>'88"   888R I888>    Y888L       888E  888I   X888  888X '888>  .@88 "8888" ''888E`  beWE "888L 
   888I  888I   4888> '     888R I888>     8888       888E  888I   X888  888X '888>  9888  9888    888E   888E  888E 
   888I  888I   4888>       888R I888>     `888N      888E  888I   X888  888X '888>  9888  9888    888E   888E  888E 
 uW888L  888'  .d888L .+   u8888cJ888   .u./"888&     888E  888I   X888  888X '888>  9888  9888    888E   888E  888F 
'*88888Nu88P   ^"8888*"     "*888*P"   d888" Y888*"  x888N><888'  "*88%""*88" '888!` 9888  9888    888&  .888N..888  
~ '88888F`        "Y"         'Y"      ` "Y   Y"      "88"  888     `~    "    `"`   "888*""888"   R888"  `"888*""   
   888 ^                                                    88F                       ^Y"   ^Y'     ""       ""      
   *8E                                                     98"                                                       
   '8>                                                   ./"                                                         
    "                                                   ~`                                                                                                                                               
                                                      [yuyu]
                                                    [893crew~]

EOF

show_infinite_progress_bar() {
    local i=0
    local sp='/-\|'
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color

    # Current state msg
    local current_operation="Installing script"

    echo -ne "${GREEN}${current_operation}... ${NC}"

    while true; do
        echo -ne "${RED}${sp:i++%${#sp}:1} ${NC}\b\b"
        sleep 0.2
    done
}

show_final_message() {
    local download_link=$1
    local password=$2
    local local_path=$3
    
    echo -e "${GREEN}##################################################${NC}"
    echo -e "${GREEN}# Your link for proxy download - ${download_link}${NC}"
    echo -e "${GREEN}# Pass for archive - ${password}${NC}"
    echo -e "${GREEN}# You can find file with proxy on this link - ${local_path}${NC}"
    echo -e "${GREEN}##################################################${NC}"
}

start_progress_bar() {
    show_infinite_progress_bar &
    progress_bar_pid=$!
}

stop_progress_bar() {
    kill $progress_bar_pid
    wait $progress_bar_pid 2>/dev/null
}

# Void

array=(0 1 2 3 4 5 6 7 8 9 a b c d e f)

main_interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

random() {
    tr </dev/urandom -dc A-Za-z0-9 | head -c5
    echo
}

gen_segment() {
    echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
}

gen32() { echo "$1:$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment)"; }
gen48() { echo "$1:$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment)"; }
gen56() { echo "$1:$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment)"; }
gen64() { echo "$1:$(gen_segment):$(gen_segment):$(gen_segment):$(gen_segment)"; }

generate_ipv6() {
    local prefix=$1
    local subnet_size=$2

    case $subnet_size in
        32) ipv6_generated=$(gen32 $prefix) ;;
        48) ipv6_generated=$(gen48 $prefix) ;;
        56) ipv6_generated=$(gen56 $prefix) ;;
        64) ipv6_generated=$(gen64 $prefix) ;;
        *)
            echo "Error: Unsupported subnet size $subnet_size"
            return 1
            ;;
    esac

    echo $ipv6_generated
}

auto_detect_ipv6_info() {
    local main_interface=$(ip -6 route show default | awk '{print $5}' | head -n1)
    local ipv6_address=$(ip -6 addr show dev "$main_interface" | grep 'inet6' | awk '{print $2}' | head -n1)
    local ipv6_prefix=$(echo "$ipv6_address" | sed -e 's/\/.*//g' | awk -F ':' '{print $1":"$2":"$3":"$4}')
    local ipv6_subnet_size=$(echo "$ipv6_address" | grep -oP '\/\K\d+')

    if [ -z "$ipv6_address" ] || [ -z "$ipv6_subnet_size" ]; then
        echo "Could not determine the address or subnet size for the interface $main_interface."
        return 1
    fi

    echo "$ipv6_prefix $ipv6_subnet_size"
}

ipv6_info=$(auto_detect_ipv6_info)
if [ $? -eq 0 ]; then
    read ipv6_prefix ipv6_subnet_size <<< "$ipv6_info"
    ipv6_generated=$(generate_ipv6 $ipv6_prefix $ipv6_subnet_size)
    if [ $? -eq 0 ]; then
        echo "Generated IPv6 address: $ipv6_generated"
    else
        echo "Error when generating IPv6 address."
        return 1
    fi
else
    echo "Error while determining IPv6 information."
    return 1
fi

gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
    if [[ $TYPE -eq 1 ]]
        then
          echo "$USERNAME/$PASSWORD/$IP4/$port/$(gen64 $IP6)"
        else
          echo "$USERNAME/$PASSWORD/$IP4/$FIRST_PORT/$(gen64 $IP6)"
        fi    
    done
}

gen_data_multiuser() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        if [[ $TYPE -eq 1 ]]
        then
          echo "$(random)/$(random)/$IP4/$port/$(gen64 $IP6)"
        else
          echo "$(random)/$(random)/$IP4/$FIRST_PORT/$(gen64 $IP6)"
        fi    
    done
}

install_3proxy() {
    echo "Installing proxy"
    mkdir -p /3proxy
    cd /3proxy
    #URL="https://github.com/z3APA3A/3proxy/archive/0.9.3.tar.gz"
    URL="https://raw.githubusercontent.com/mrtoan2808/3proxy-ipv6/master/3proxy-0.9.3.tar.gz"
    wget -qO- $URL | bsdtar -xvf-
    cd 3proxy-0.9.3
    make -f Makefile.Linux
    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    mv /3proxy/3proxy-0.9.3/bin/3proxy /usr/local/etc/3proxy/bin/
    wget https://raw.githubusercontent.com/mrtoan2808/3proxy-ipv6/master/3proxy.service-Centos8 --output-document=/3proxy/3proxy-0.9.3/scripts/3proxy.service2
    cp /3proxy/3proxy-0.9.3/scripts/3proxy.service2 /usr/lib/systemd/system/3proxy.service
    systemctl link /usr/lib/systemd/system/3proxy.service
    systemctl daemon-reload
    #systemctl enable 3proxy
    echo "* hard nofile 999999" >>  /etc/security/limits.conf -y > /dev/null 2>&1
    echo "* soft nofile 999999" >>  /etc/security/limits.conf -y > /dev/null 2>&1
    echo "net.ipv4.route.min_adv_mss = 1460" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.tcp_rmem = 8192 87380 4194304" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.tcp_wmem = 8192 87380 4194304" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.tcp_timestamps=0" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.tcp_window_scaling=0" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.tcp_max_syn_backlog = 4096" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv6.conf.all.proxy_ndp=1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv6.conf.default.forwarding=1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    echo "net.ipv6.ip_nonlocal_bind = 1" >> /etc/sysctl.conf -y > /dev/null 2>&1
    sysctl -p
    systemctl stop firewalld
    systemctl disable firewalld

    cd $WORKDIR
}

gen_3proxy() {
    cat <<EOF
daemon
nserver 127.0.0.1
nserver ::1
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
users $(awk -F "/" 'BEGIN{ORS="";} {print $1 ":CL:" $2 " "}' ${WORKDATA})
# HTTP proxy part
$(awk -F "/" '{print "auth strong\n" \
"allow " $1 "\n" \
"proxy -64 -n -a -p" $4 " -i" $3 " -e" $5 "\n" \
"flush\n"}' ${WORKDATA})
# SOCKS5 proxy part
$(awk -F "/" '{print "auth strong\n" \
"allow " $1 "\n" \
"socks -64 -n -a -p" $4+20000 " -i" $3 " -e" $5 "\n" \
"flush\n"}' ${WORKDATA})
EOF
}

gen_iptables() {
    cat <<EOF
    $(awk -F "/" '{print "iptables -I INPUT -p tcp --dport " $4 "  -m state --state NEW -j ACCEPT\n" \
                    "iptables -I INPUT -p udp --dport " $4 "  -m state --state NEW -j ACCEPT\n" \
                    "iptables -I INPUT -p tcp --dport " $4+20000 "  -m state --state NEW -j ACCEPT\n" \
                    "iptables -I INPUT -p udp --dport " $4+20000 "  -m state --state NEW -j ACCEPT"}' ${WORKDATA}) 
EOF
}

gen_ifconfig() {
    cat <<EOF
    $(awk -F "/" '{print "ifconfig '$main_interface' inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}

gen_proxy_file_for_user() {
    cat >proxy.txt <<EOF
===========================================================================
                                                        .__    .___
        _____________  _______  ______.__. _____ _____  |__| __| _/
        \____ \_  __ \/  _ \  \/  <   |  |/     \\__  \ |  |/ __ | 
        |  |_> >  | \(  <_> >    < \___  |  Y Y  \/ __ \|  / /_/ | 
        |   __/|__|   \____/__/\_ \/ ____|__|_|  (____  /__\____ | 
        |__|                     \/\/          \/     \/        \/ 
===========================================================================
$(awk -F "/" '{print $3 ":" $4 ":" $1 ":" $2 }' ${WORKDATA})
EOF
}

upload_proxy() {
    cd $WORKDIR
    local PASS=$(random)
    zip --password $PASS proxy.zip proxy.txt > /dev/null 2>&1
    response=$(curl -s -F "file=@proxy.zip" https://file.io)
    URL=$(echo $response | jq -r '.link')

    if [ -z "$URL" ]; then
        echo "Ошибка: не удалось получить URL для скачивания."
        return 1
    fi

    show_final_message "$URL" "$PASS" "$(pwd)/proxy.txt"
}

# Begin
echo "Welcome to your honey proxymaid"
echo "Now i will install for you all neccessary dependencies"

show_header
start_progress_bar
sudo yum update -y > /dev/null 2>&1
stop_progress_bar

show_header
start_progress_bar
sudo yum install gcc make wget nano tar gzip -y > /dev/null 2>&1
stop_progress_bar


show_header
start_progress_bar
sudo yum install epel-release -y > /dev/null 2>&1
stop_progress_bar
show_header
start_progress_bar
sudo yum update -y > /dev/null 2>&1
stop_progress_bar
show_header
start_progress_bar
sudo yum install jq -y > /dev/null 2>&1
stop_progress_bar


show_header
start_progress_bar
sudo yum group reinstall "Development Tools" -y > /dev/null 2>&1
stop_progress_bar


show_header
start_progress_bar
sudo yum upgrade -y > /dev/null 2>&1
stop_progress_bar


show_header
start_progress_bar
sudo yum install -y dnsmasq > /dev/null 2>&1
stop_progress_bar

echo "listen-address=127.0.0.1,::1" | sudo tee -a /etc/dnsmasq.conf

sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

show_header
start_progress_bar
yum -y install gcc net-tools bsdtar zip make > /dev/null 2>&1
stop_progress_bar

show_header
start_progress_bar
install_3proxy > /dev/null 2>&1
stop_progress_bar

echo "Working folder = /home/proxy-installer"
WORKDIR="/home/proxy-installer"
WORKDATA="${WORKDIR}/data.txt"
mkdir $WORKDIR && cd $_

USERNAME=$(random)
PASSWORD=$(random)
IP4=$(curl -4 -s icanhazip.com)
IP6=$(curl -6 -s icanhazip.com | cut -f1-4 -d':')

show_header
echo "Internal ip = ${IP4}. Exteranl sub for ip6 = ${IP6}"

show_header
echo "How many proxy should i create for you? e.g. 500"
read COUNT
echo "You set count of proxy to " $COUNT ""

FIRST_PORT=10000
LAST_PORT=$(($FIRST_PORT + $COUNT))

set_tcp_fingerprint() {
    local os=$1
	{
    echo "Применяем настройки для $os" 
    case "$os" in
        "Windows")
            sysctl -w net.ipv4.ip_default_ttl=128
            sysctl -w net.ipv4.tcp_syn_retries=2
            sysctl -w net.ipv4.tcp_fin_timeout=30
            sysctl -w net.ipv4.tcp_keepalive_time=7200
            ;;
        "MacOS")
            sysctl -w net.ipv4.ip_default_ttl=64
            sysctl -w net.ipv4.tcp_syn_retries=3
            sysctl -w net.ipv4.tcp_fin_timeout=15
            sysctl -w net.ipv4.tcp_keepalive_time=7200
            ;;
        "Linux")
            sysctl -w net.ipv4.ip_default_ttl=64
            sysctl -w net.ipv4.tcp_syn_retries=5
            sysctl -w net.ipv4.tcp_fin_timeout=60
            sysctl -w net.ipv4.tcp_keepalive_time=7200
            ;;
        "Android")
            sysctl -w net.ipv4.ip_default_ttl=64
            sysctl -w net.ipv4.tcp_syn_retries=5
            sysctl -w net.ipv4.tcp_fin_timeout=30
            sysctl -w net.ipv4.tcp_keepalive_time=600
            ;;
        "iPhone")
            sysctl -w net.ipv4.ip_default_ttl=64
            sysctl -w net.ipv4.tcp_syn_retries=3
            sysctl -w net.ipv4.tcp_fin_timeout=30
            sysctl -w net.ipv4.tcp_keepalive_time=7200
            ;;
        *)
            echo "Unknows OS: $os"
            return 1
            ;;
    esac > /dev/null 2>&1
    sysctl -p
    echo "Settings for "$os" being applied."
	} > /dev/null 2>&1
    return 0
}

# Меню выбора
echo "Choose an TCP/IP fingerprint for your proxies:"
echo "1 - Windows"
echo "2 - MacOS"
echo "3 - Linux"
echo "4 - Android"
echo "5 - iPhone"

read -p "Enter number (1-5): " os_choice

if [[ ! $os_choice =~ ^[1-5]$ ]]; then
    echo "Fuck you idiot..."
    exit 1
fi

os=""
case $os_choice in
    1) os="Windows" ;;
    2) os="MacOS" ;;
    3) os="Linux" ;;
    4) os="Android" ;;
    5) os="iPhone" ;;
esac

echo "You choosed: $os"
set_tcp_fingerprint "$os"

echo "What kind of proxy do you want to be created?"
echo "1 - Static"
echo "2 - Random"
read TYPE
if [[ $TYPE -eq 1 ]]
then
show_header
  echo "You choosed static proxy"
else
show_header
  echo "You choosed random proxy"
fi

echo "Do you want once log/pass for all proxy or not?"
echo "1 - One"
echo "2 - Different"
read NUSER
if [[ NUSER -eq 1 ]]
then
show_header
start_progress_bar
  echo "You choosed one log/pass"
  gen_data >$WORKDIR/data.txt
  stop_progress_bar
else
show_header
start_progress_bar
  echo "You choosed different log/pass"
  gen_data_multiuser >$WORKDIR/data.txt
  stop_progress_bar
fi

gen_iptables >$WORKDIR/boot_iptables.sh
gen_ifconfig >$WORKDIR/boot_ifconfig.sh
echo NM_CONTROLLED="no" >> /etc/sysconfig/network-scripts/ifcfg-${main_interface}
chmod +x $WORKDIR/boot_*.sh /etc/rc.local

gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

cat >>/etc/rc.local <<EOF
systemctl start NetworkManager.service
#ifup ${main_interface}
bash ${WORKDIR}/boot_iptables.sh
bash ${WORKDIR}/boot_ifconfig.sh
ulimit -n 65535
/usr/local/etc/3proxy/bin/3proxy /usr/local/etc/3proxy/3proxy.cfg &
EOF

bash /etc/rc.local

gen_proxy_file_for_user


upload_proxy


# End

cd /root
rm -f Final_Origin.sh
