#!/bin/bash
##############################################################
# Script_Name : PROXY KNOW ADVANCED Script
# Description :  Install and configure a proxy server
# For Ubuntu 12 and later .04 LTS versions only
# Released : April 2019
# Web Site : https://ProxyKnow.com
# Author: Better Know
# Version : 2.0 Advanced
# Disclaimer : Script provided AS IS. Use it at your own risk!
# WARNING: Script is copyright protected.
###############################################################
rm /etc/tmp1
rm /etc/tmp2
apt-get install nano

ifextra=*"n"*
auth=*"pass"*
username=$1
password=$2

if [[ $ifextra == *"y"* ]] || [[ $ifextra == *"Y"* ]]
then
echo
echo
echo
echo -e "\e[1;91mA file will open next, insert your extra IPs each in its own line without the main IP, press Ctrl+X followed by Y and ENTER once you're done.
Press ENTER to continue  \e[0m"
read
nano /etc/tmp1
fi

apt-get update
#apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean -y
apt-get clean -y
apt-get install fail2ban software-properties-common -y
apt-get install build-essential libevent-dev libssl-dev -y
apt-get install ethtool -y
apt-get install curl -y
pIP=$(curl -s ipinfo.io/ip)
cd /usr/local/etc
wget https://github.com/z3APA3A/3proxy/archive/0.8.12.tar.gz
tar zxvf 0.8.12.tar.gz
rm 0.8.12.tar.gz
mv 3proxy-0.8.12 3proxy 
cd 3proxy
make -f Makefile.Linux
make -f Makefile.Linux install
mkdir log
cd cfg
rm 3proxy.cfg.sample
echo "#!/usr/local/bin/3proxy
daemon
pidfile /usr/local/etc/3proxy/3proxy.pid
nserver 1.1.1.1
nserver 1.0.0.1
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
log /usr/local/etc/3proxy/log/3proxy.log D
logformat \"- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T\"
archiver rar rar a -df -inul %A %F
rotate 30
internal 0.0.0.0
external 0.0.0.0
authcache ip 60




proxy -p3130 -a -n
" > /usr/local/etc/3proxy/cfg/3proxy.cfg
chmod 700 3proxy.cfg
sed -i '14s/.*/       \/usr\/local\/etc\/3proxy\/cfg\/3proxy.cfg/' /usr/local/etc/3proxy/scripts/rc.d/proxy.sh
sed -i "4ish /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start" /etc/rc.local
if [[ $auth == *"pass"* ]] || [[ $auth == *"Pass"* ]]
then
sed -i '17s/.*/auth strong/' /usr/local/etc/3proxy/cfg/3proxy.cfg
sed -i "15s/.*/users $username:CL:$password/" /usr/local/etc/3proxy/cfg/3proxy.cfg 
sed -i "18s/.*/allow $username /" /usr/local/etc/3proxy/cfg/3proxy.cfg 
else
sed -i '17s/.*/auth iponly/' /usr/local/etc/3proxy/cfg/3proxy.cfg
sed -i "18s/.*/allow * $authip/" /usr/local/etc/3proxy/cfg/3proxy.cfg 
fi
if [[ $ifextra == *"y"* ]] || [[ $ifextra == *"Y"* ]]
then
port=3130
echo "$pIP:3130" >> /etc/tmp2
for interface in $(ip -o link show | awk -F': ' '{print $2}')
do
    mac=$(ethtool -P $interface)
    [[ $mac != *"00:00:00:00:00:00"* ]]
done
sleep 1
cat /etc/tmp1 | while read line
do
port=$((port+1))
echo "proxy -p$port -a -n -i0.0.0.0 -e$line" >> /usr/local/etc/3proxy/cfg/3proxy.cfg
echo "$pIP:$port" >> /etc/tmp2
ifconfig $interface add $line
done
fi
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start
if [[ $ifextra == *"y"* ]] || [[ $ifextra == *"Y"* ]]
then
echo "Below are all your newly created proxies"
cat /etc/tmp2
fi
echo
/bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
/bin/echo -e "\e[1;36m#                Proxy Creation Successful!                   #\e[0m"
/bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
echo