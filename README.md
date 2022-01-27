# x

Installation and Remote Configuration of Residential and Datacenter Proxy.

**IMPORTANT:** This project is under construction!

*(abstract pending)*

# Outline

*(pending)*

# Required Packages

sudo su

apt-get install make

wget raw.githubusercontent.com/leandrosardi/x/main/ipv4.install.sh

chmod -x ipv4.install.sh

# Note about Ubuntu 18.04 or higher

The /etc/rc.local file on Ubuntu and Debian systems are used to execute commands at system startup. But there's no such file in Ubuntu 18.04.

So what can we do? We can just create the file. Let's do it. Create the /etc/rc.local file with nano text editor,

nano /etc/rc.local
Paste the following lot,

#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
That's the content of Ubuntu 16.04's stock /etc/rc.local file. Now make it executable,

chmod +x /etc/rc.local
That's it. You can now use this file to execute commands at system boot. Just paste your commands above the line that says exit 0

# 1. Datacenter IPv4 Proxies

*(abstract pending)*

## 1.1. Configuration

*(pending)*

## 1.2. Restarting

*(pending)*

## 1.3. Changing Authentication

*(pending)*

# 2. Datacenter IPv6 Proxies

*(abstract pending)*

## 2.1. Configuration

*(pending)*

## 2.2. Restarting

*(pending)*

## 2.3. Changing Authentication

*(pending)*
