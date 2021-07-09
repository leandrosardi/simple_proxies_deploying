#!/bin/bash
##############################################################
# Script_Name : PROXY KNOW ADVANCED Script
# Description :  Install and configure a proxy server
# For Ubuntu 12 and later .04 LTS versions only
# Released : April 2019
# Web Site : https://ProxyKnow.com
# Author: A. M. Abuelezz AKA Better Know
# Version : 2.0 Advanced
# Disclaimer : Script provided AS IS. Use it at your own risk!
# WARNING: Script is copyright protected.
# INTELLICTUAL PROPERTY OF OBRIB CONS.
###############################################################
echo "Enter your /48 network prefix: (example: a2c3:123a:49ff )"
read prefix
echo "What port would you like to start from? (If this is your first IPV6 batch then type 4000 )"
read port
ran=( a b c d e f 1 2 3 4 5 6 7 8 9 0 )
nip=50
ind=1
apt-get install ethtool
apt-get install curl
rm /etc/ipv6tmp
#interface=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | head -n1 | awk '{print $1;}')
interface=$(ip -o -4 route show to default | awk '{print $5}' | sed 1'!d')
sleep 1
mainIP=$(curl -s http://ipinfo.io/ip)

sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh stop

ifconfig $interface add $prefix::/48
ip -6 route add default via $prefix::1

echo "ifconfig $interface add $prefix::/48
ip -6 route add default via $prefix::1" >> /etc/network.conf

chmod +x /etc/rc.local
chmod +x /etc/network.conf

#REMOVE exit 0 FROM rc.local
sed -i '/exit 0/d' /etc/rc.local
echo "bash /etc/network.conf" >> /etc/rc.local

while [ "$ind" -le $nip ]; do
    a=${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}
    b=${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}
    c=${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}
    d=${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}
    e=${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}${ran[$RANDOM%16]}
    echo proxy -p$port -6 -a -n  -i0.0.0.0 -e$prefix:$a:$b:$c:$d:$e >> /usr/local/etc/3proxy/cfg/3proxy.cfg
    echo $mainIP:$port >> /etc/ipv6tmp
    port=$((port+1))
    ind=$((ind+1))
    ip address add $prefix:$a:$b:$c:$d:$e dev $interface  > /dev/null 2>&1

    echo "ip address add $prefix:$a:$b:$c:$d:$e dev $interface" >> /etc/network.conf
    echo "$prefix:$a:$b:$c:$d:$e" >> /etc/network.ips

done

sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start

echo "exit 0" >> /etc/rc.local

echo "Below are your new proxies:"
cat /etc/ipv6tmp
echo
echo
echo "Copy your proxies to another file, and make sure they are saved as they cannot be accessed again, highlight with your mouse and it'll be automatically copied."
echo
rm /etc/ipv6tmp
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh stop  > /dev/null 2>&1
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start  > /dev/null 2>&1