# Simple Proxies Deploying

## 1. Installation

```bash
gem install simple_proxies_deploying
```

## 5. Installing IPv4 Datanceter Proxy

```ruby
require 'simple_proxies_deploying'

logger = BlackStack::BaseLogger.new(nil)

# define hash descriptor of the server
h = {
    :net_remote_ip => '103.144.176.151', 
    :ssh_username => 'vpsuser550', 
    :ssh_password => 'SantaClara123', 
}

logger.logs 'creating object... '
host = RemoteHost.parse(h, logger)
logger.done

logger.logs 'connecting... '
host.ssh_connect
logger.done

logger.logs 'install IPv4 proxy listening port 3130... '
host.install4('foouser', 'foopassword', 3130)
logger.done

logger.logs "disconnecting... "
host.ssh_disconnect
logger.done
```

## 6. Installing IPv6 Datanceter Proxies

```ruby
require 'simple_proxies_deploying'

# define hash descriptor of the server
h = {
    :net_remote_ip => '103.144.176.151', 
    :ssh_username => 'vpsuser550', 
    :ssh_password => 'SantaClara123', 
    :ipv6_subnet_48 => '2602:fed2:770f', # /48 subnet attached to the server
}

logger = BlackStack::BaseLogger.new(nil)

logger.logs 'creating object... '
host = RemoteHost.parse(h, logger)
logger.done

logger.logs 'connecting... '
host.ssh_connect
logger.done

logger.logs 'install 500 IPv6 proxies... '
host.install6(4000, 4499)
logger.done

logger.logs "disconnecting... "
host.ssh_disconnect
logger.done
```

## 4. Looking IPv6 Proxies Missconfigurations

```ruby
require 'simple_proxies_deploying'

# array of missconfigurations found on IPv6 proxies configuration
errors = []

# define hash descriptor of the server
h = {
    :net_remote_ip => '103.144.176.151', 
    :ssh_username => 'vpsuser550', 
    :ssh_password => 'SantaClara123', 
    :ipv6_subnet_48 => '2602:fed2:770f', # /48 subnet attached to the server
}

logger = BlackStack::BaseLogger.new(nil)

logger.logs 'creating object... '
host = RemoteHost.parse(h, logger)
logger.done

logger.logs "#{h[:net_remote_ip]}... "
begin
    host = RemoteHost.parse(h)
    host.ssh_connect
    errors = host.check_all_ipv6_proxies
    host.ssh_disconnect
    logger.logf "done (#{errors.size} errors)"
rescue SimpleProxiesDeployingException => e
    logger.logf "error #{e.code} (#{e.description})"
rescue => e
    logger.logf "unhandled exception (#{e.to_s})"
end

# show errors
if errors.size > 0
    errors.each { |error|
        logger.log ''
        logger.log error.to_s.gsub(' :', "\n\t:")
    }
end

logger.logs "disconnecting... "
host.ssh_disconnect
logger.done
```

## 5. Problems Resolution Procedure for Datacenter Proxies

In case that proxies stop working,  follow the procedure below.

### 5.1. Check if the proxy server is running

Run this command

```
ps aux | grep 3proxy | grep -v grep
```

If the output is empty, then start the service:

```
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh stop  > /dev/null 2>&1
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start  > /dev/null 2>&1
```

Run this command again,

```
ps aux | grep 3proxy | grep -v grep
```

and you should see an output like this:

```
root     24274  0.0  0.6 539752  6128 ?        Ssl  13:57   0:00 /usr/local/bin/3proxy /usr/local/etc/3proxy/cfg/3proxy.cfg
```

### 5.2. Check if there are not duplicated routes in the 

Run this command, for the port that is not working:

```
grep 4000 /usr/local/etc/3proxy/cfg/3proxy.cfg
```

Check if there is only one proxy defined against each port. CASE 3!!!

```
proxy -p4000 -6 -a -n -i0.0.0.0 -e2a0f:9981:20:857d:6245:b1f3:b822:1ce8
proxy -p4000 -6 -a -n -i0.0.0.0 -e2a0f:9981:20:d9e8:5d21:d12b:3a70:e6d5
```

If the output shows multiple values; open the config file in the editor of choice and remove more than 1 values.

```
nano /usr/local/etc/3proxy/cfg/3proxy.cfg
```

After edition of `3proxy.cfg`, reassign the IPs by running this command:

```
bash /etc/network.conf
```

### 5.3. Check if the address is assigned to the interface.

Get the IPv6 address from 3proxy config: For port 4000:

 ```
 grep 4000 /usr/local/etc/3proxy/cfg/3proxy.cfg
 ```

You should see an output like this:

```
proxy -p4000 -6 -a -n -i0.0.0.0 -e2a0f:9981:20:d9e8:5d21:d12b:3a70:e6d5
 ```

Check if the address [2a0f:9981:20:d9e8:5d21:d12b:3a70:e6d5] is assigned to the interface.
Remove any leading 0s; otherwise grep will not match.

 ```
ip -6 a | grep 2a0f:9981:20:d9e8:5d21:d12b:3a70:e6d5
```

You should see an output like this:

```
inet6 2a0f:9981:20:d9e8:5d21:d12b:3a70:e6d5/128 scope global
 ```

If the output is empty: run the following command.
This will reassign the IPs.

 ```
 bash /etc/network.conf
 ```

 ### 5.4. Check if Firewall is not ON

Disable firewall:

```
sudo ufw disable
```

Then try again to connect the proxy.

### 5.5. Restart the proxyserver

Restart proxy server:

```
pkill -9 3proxy;sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start
```

Then try again to connect the proxy.

### 5.6. Reboot the Server

If nothing before worked to get the proxies working, try this:

First, reboot the server:

```
sudo reboot
```

After reboot, run these 3 commands:

```
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh stop  > /dev/null 2>&1
sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start  > /dev/null 2>&1
bash /etc/network.conf
```

### 5.6. Ask the ISP if the /48 subnet is routed to the VPS

If nothing before worked to get the proxies working, ask the ISP if the /48 subnet is routed to the VPS.


## 6. Well Known Problems

### 6.1. When running a command, I am getting error "Authentication token is no longer valid; new one required"

Access the server via SSH, and chage the root passowrd with this command:

```bash
sudo -u root passwd
```

## 7. Further Work

### 7.1. Enhancements

1. Enhance installation of IPv4 proxies, by validating the stdout of each one of the commands executed in SSH.
2. Enhance installation of IPv6 proxies, by validating the stdout of each one of the commands executed in SSH.
3. Installation of multiple IPv4 proxies on the same server.
4. Integration of this library as an add-on of [Simple Host Monitoring](https://github.com/leandrosardi/simple_host_monitoring).

### 7.2. New Features

5. Support for mobile 4g/LTE proxies.
6. Support for mobile 5g proxies.