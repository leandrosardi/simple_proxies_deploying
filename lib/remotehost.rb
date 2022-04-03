# TODO: replace RemoteHost class in SimpleHostsMonitoring library by this code 
class RemoteHost
    # TODO: this must be defined at class RemoteHost in the SimpleHostMonitoring library
    attr_accessor :cpu_architecture, :cpu_speed, :cpu_load_average, :cpu_model, :cpu_type, :cpu_number, :mem_total, :mem_free, :disk_total, :disk_free, :net_hostname, :net_remote_ip, :net_mac_address  
    attr_accessor :stealth_browser_technology_code, :ssh_username, :ssh_password, :ssh_port, :ipv6_subnet_48
    attr_accessor :ssh # this is the ssh connection
    attr_accessor :logger

    def initialize(the_logger=nil)
        self.logger=the_logger
        self.logger = BlackStack::DummyLogger.new(nil) if self.logger.nil? # assign a dummy logger that just generate output on the screen
    end

    # TODO: mover esto al modulo BaseHost de SimpleHostMonitoring
    def self.valid_port_number?(n)
        return false if !n.is_a?(Numeric)
        return false if n < 1 || n > 65535
        true
    end

    # return the same hash as the class poll() method, but connecting the server via SSH.
    # we are assuming the server is a Linux server.
    # TODO: write the list of software packages that server must have installed.
    def poll_thru_ssh()
        # TODO: code me!
    end

    # TODO: this must be defined at module BaseHost in the SimpleHostMonitoring library
    def parse(h)
        # parameters regarding the current status of the host
        self.cpu_architecture = h[:cpu_architecture]
        self.cpu_speed = h[:cpu_speed]
        self.cpu_load_average = h[:cpu_load_average]
        self.cpu_model = h[:cpu_model]
        self.cpu_type = h[:cpu_type]
        self.cpu_number = h[:cpu_number]
        self.mem_total = h[:mem_total]
        self.mem_free = h[:mem_free]
        self.disk_total = h[:disk_total]
        self.disk_free = h[:disk_free]
        self.net_hostname = h[:net_hostname]
        self.net_mac_address = h[:net_mac_address]

        # parameters regarding the remote controling of the server
        self.net_remote_ip = h[:net_remote_ip]
        self.ssh_username = h[:ssh_username]
        self.ssh_password = h[:ssh_password]
        self.ssh_port = h[:ssh_port]

        # StealthBrowserAutomation monkey-patch add-on: parameters regarding the usage of stealth browser for automation
        self.stealth_browser_technology_code = h[:stealth_browser_technology_code]

        # SimpleProxyServer monkey-patch add-on: paremeters regarding the installation of proxies
        self.ipv6_subnet_48 = h[:ipv6_subnet_48]
    end

    def self.parse(h, logger=nil)
        o = RemoteHost.new(logger)
        o.parse(h)
        o
    end

    # TODO: this must be defined at module BaseHost in the SimpleHostMonitoring library
    def to_hash
        {
            # parameters regarding the current status of the host
            :cpu_architecture => self.cpu_architecture,
            :cpu_speed => self.cpu_speed,
            :cpu_load_average => self.cpu_load_average,
            :cpu_model => self.cpu_model,
            :cpu_type => self.cpu_type,
            :cpu_number => self.cpu_number,
            :mem_total => self.mem_total,
            :mem_free => self.mem_free,
            :disk_total => self.disk_total,
            :disk_free => self.disk_free,
            :net_hostname => self.net_hostname,
            :net_remote_ip => self.net_remote_ip,
            :net_mac_address => self.net_mac_address,

            # parameters regarding the remote controling of the server
            :ssh_username => self.ssh_username,
            :ssh_password => self.ssh_password,
            :ssh_port => self.ssh_port,

            # StealthBrowserAutomation monkey-patch add-on: parameters regarding the usage of stealth browser for automation
            :stealth_browser_technology_code => self.stealth_browser_technology_code,

            # SimpleProxyServer monkey-patch add-on: paremeters regarding the installation of proxies
            :ipv6_subnet_48 => self.ipv6_subnet_48,
        }
    end
  

    def ssh_parameters?
        self.net_remote_ip && self.ssh_username && self.ssh_password
    end

    def get_ssh_port()
        self.ssh_port.nil? ? 22 : self.ssh_port
    end

    def ssh_connect()
        # validation: this host must have ssh parameters
        raise SimpleProxiesDeployingException.new(1) if !self.ssh_parameters?

        # connect
        self.ssh = Net::SSH.start(self.net_remote_ip, self.ssh_username, :password => self.ssh_password, :port => self.get_ssh_port)

        # validation: the connection must be established
        raise SimpleProxiesDeployingException.new(4) if !self.ssh
    end

    # Parse the file /usr/local/etc/3proxy/cfg/3proxy.cfg
    # Return an array of hash descriptors like this: {:port=>"3130", :external_ip=>"185.165.34.31"}
    def get_ipv4_proxies()
        # TODO: Code Me!
    end

    # Parse the file /usr/local/etc/3proxy/cfg/3proxy.cfg
    # Return an array of hash descriptors like this: {:port=>"4248", :external_ip=>"2602:fed2:770f:df10:8dc9:556f:dfba:8ee3", :subnet64=>"2602:fed2:770f:df10"}
    def get_ipv6_proxies()
        # validation: this host must have defined an ipv6 subnet 48
        raise SimpleProxiesDeployingException.new(5) if !self.ipv6_subnet_48

        # validation: this host must have ssh connection
        raise SimpleProxiesDeployingException.new(3) if !self.ssh

        results = []
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'grep \"proxy -p\" /usr/local/etc/3proxy/cfg/3proxy.cfg'")
        a = stdout.split("\n") # stdout.scan(MATCH_IPV6_STANDARD)
        a.select { |x| 
            # filter all the IPv6 proxies
            x.include?('-6') 
        }.each { |x|
            # example: proxy -p4245 -6 -a -n -i0.0.0.0 -e2602:fed2:770f:e75c:dc88:fab6:7623:1f47
            port = x.scan(MATCH_PORT_IN_3PROXY_CONF)[0].gsub(/\-p/, '')
            external_ip = x.scan(MATCH_IPV6_STANDARD)[0]
            subnet64 = external_ip.scan(MATCH_IPV6_64_SUBNET_STANDARD)[0]
            results << { :port => port.to_i, :external_ip => external_ip.to_s, :subnet64 => subnet64.to_s }
        }
        results
    end


    # check a list of port numbers and return the list of ports that are missconfigured
    # return an array of errors.
    def check_all_ipv4_proxies()
        # TODO: Code Me!
    end
    
    # check a list of port numbers and return the list of ports that are missconfigured
    # return an array of errors.
    # validate if there is more than one external ip address belonging the same /64 subnet.
    # validate that each batch of 50 ports is all configured.
    # raise an exception if there are ports outside the range
    # raise an exception proxy_port_to is not higher than proxy_port_from.
    def check_all_ipv6_proxies(proxy_port_from=DEFAULT_PROXY_PORT_FROM, proxy_port_to=DEFAULT_PROXY_PORT_TO)
        #raise SimpleProxiesDeployingException.new(9, "#{proxy_port_from}") if proxy_port_from != DEFAULT_PROXY_PORT_FROM
        raise SimpleProxiesDeployingException.new(10, "#{proxy_port_from} and #{proxy_port_to}") if proxy_port_from > proxy_port_to
        #raise SimpleProxiesDeployingException.new(11, "from #{proxy_port_from} to #{proxy_port_to}") if (proxy_port_to-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE != 0

        # return this array with the list of glitches found
        errors = []
        
        # record all the /64 subnets of each external ip address, to check if there is more than one external ip address belonging the same /64 subnet 
        # records all the extenral ips of each port, to check that each batch of 50 ports is all configured, or it is empty
        results = self.get_ipv6_proxies

        # validate there is not ports outside the range
        a = results.select { |x| 
            x[:port]<proxy_port_from || x[:port]>proxy_port_to 
        }.map { |x| 
            x[:port] 
        }
        raise SimpleProxiesDeployingException.new(14, a.join(', '))  if a.size > 1

        port = proxy_port_from
        while port <= proxy_port_to
            # map the external IPs to the port
            a = results.select { |x| x[:port] == port }.map { |x| x[:external_ip] }

            # validation: there is no extenral IP defined for this port
            # raise SimpleProxiesDeployingException.new(8) if a.size == 0

            if a.size > 0
                # validation: there is no more than 1 extenral IP defined for this host
                if a.size > 1
                    e = SimpleProxiesDeployingException.new(7, "#{port.to_s} - #{a.join(', ')}") 
                    errors << { :proxy_port=>port, :code=>e.code, :description=>e.description, :simple_description=>e.simple_description }
                end

                # validation: the external ip must be belonging the subnet defined at ipv6 subnet 48
                if !a[0].include?(self.ipv6_subnet_48)
                    e = SimpleProxiesDeployingException.new(6, "#{a[0]} and #{self.ipv6_subnet_48}") 
                    errors << { :proxy_port=>port, :code=>e.code, :description=>e.description, :simple_description=>e.simple_description }
                end
            end # if a.size > 0

            port += 1
        end

        # validation: there is more than one external ip address belonging the same /64 subnet.
        self.logger.logs 'Check duplicated /64 subnets... '
        i = 0
        results.each { |r|
            if !r[:external_ip].nil?
                b = results.select { |s| s[:port]!=r[:port] && s[:subnet64]==r[:subnet64] }
                if b.size > 1
                    e = SimpleProxiesDeployingException.new(12, b.join(', '))
                    errors << { :proxy_port=>r[:port], :code=>e.code, :description=>e.description, :simple_description=>e.simple_description }
                    i += 1
                end
            end # if !r[:external_ip].nil?
        }             
        self.logger.logf "done (#{i.to_s} errors)"

        # return
        errors
    end # def check_all_ipv6_proxies


    # run linux command to get the interface name
    # TODO: validate outout
    def get_interface_name()
        # validation: this host must have ssh connection
        raise SimpleProxiesDeployingException.new(3) if !self.ssh
        ssh.exec!("ip -o -4 route show to default | awk '{print $5}' | sed 1'!d'").strip
    end

    # run linux command to stop the proxy server
    # TODO: validate outout
    def stop_proxies()
        # validation: this host must have ssh connection
        raise SimpleProxiesDeployingException.new(3) if !self.ssh
        ssh.exec!("sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh stop > /dev/null 2>&1")
    end

    # run linux command to stop the proxy server
    # TODO: get this working
    # TODO: validate outout
    def start_proxies()
        # validation: this host must have ssh connection
        raise SimpleProxiesDeployingException.new(3) if !self.ssh
        ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start > /dev/null 2>&1'")
    end


    # setup custom IP authorization for a proxy
    def setup_custom_ip_auth(port)
        # TODO: Code Me!
    end

    # setup custom user/pass authorization for a proxy
    def setup_custom_pass_auth(port)
        # TODO: Code Me!
    end


    # install ipv4 proxies
    def install_3proxy()
        #raise SimpleProxiesDeployingException.new(9, "#{proxy_port_from}") if proxy_port_from != DEFAULT_PROXY_PORT_FROM
        #raise SimpleProxiesDeployingException.new(10, "#{proxy_port_from} and #{proxy_port_to}") if proxy_port_from > proxy_port_to
        #raise SimpleProxiesDeployingException.new(11, "from #{proxy_port_from} to #{proxy_port_to}") if (proxy_port_to-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE != 0

        # TODO: validate the output
        logger.logs "Get interface name... "
        interface = self.get_interface_name
        logger.logf "done (#{interface})"

        logger.logs "Get server main ip from configuration... "
        mainip = self.net_remote_ip
        logger.logf "done (#{mainip})"

        # TODO: validate the output
        logger.logs "Install packages... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c '
            apt-get install nano
            apt-get update
            apt-get autoremove -y
            apt-get autoclean -y
            apt-get clean -y
            apt-get install fail2ban software-properties-common -y
            apt-get install build-essential libevent-dev libssl-dev -y
            apt-get install ethtool -y
            apt-get install curl -y
        '")
        logger.logf "done (#{stdout})"

        # TODO: validate the output
        logger.logs "Install 3proxy... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c '
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
        '")
        logger.logf "done (#{stdout})"

        # TODO: validate the output
        logger.logs "Install 3proxy... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c '        
            echo \"#!/usr/local/bin/3proxy
            daemon
            pidfile /usr/local/etc/3proxy/3proxy.pid
            nserver 1.1.1.1
            nserver 1.0.0.1
            nscache 65536
            timeouts 1 5 30 60 180 1800 15 60
            log /usr/local/etc/3proxy/log/3proxy.log D
            logformat \\\"- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T\\\"
            archiver rar rar a -df -inul %A %F
            rotate 30
            internal 0.0.0.0
            external 0.0.0.0
            authcache ip 60
            proxy -p3130 -a -n
            \" > /usr/local/etc/3proxy/cfg/3proxy.cfg
        '")
        logger.logf "done (#{stdout})"

        
        chmod 700 3proxy.cfg
        sed -i '14s/.*/       \/usr\/local\/etc\/3proxy\/cfg\/3proxy.cfg/' /usr/local/etc/3proxy/scripts/rc.d/proxy.sh
        sed -i "4ish /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start" /etc/rc.local
        sed -i '17s/.*/auth strong/' /usr/local/etc/3proxy/cfg/3proxy.cfg
        sed -i "15s/.*/users $username:CL:$password/" /usr/local/etc/3proxy/cfg/3proxy.cfg 
        sed -i "18s/.*/allow $username /" /usr/local/etc/3proxy/cfg/3proxy.cfg 
    end # def install_3proxy
                
    # install ipv4 proxies
    # raise an exception proxy_port_to is not higher than proxy_port_from.
    def install4(username, password)
        #raise SimpleProxiesDeployingException.new(9, "#{proxy_port_from}") if proxy_port_from != DEFAULT_PROXY_PORT_FROM
        raise SimpleProxiesDeployingException.new(10, "#{proxy_port_from} and #{proxy_port_to}") if proxy_port_from > proxy_port_to
        #raise SimpleProxiesDeployingException.new(11, "from #{proxy_port_from} to #{proxy_port_to}") if (proxy_port_to-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE != 0

    end # def install4

    # install ipv6 proxies
    # raise an exception proxy_port_to is not higher than proxy_port_from.
    def install6(proxy_port_from=DEFAULT_PROXY_PORT_FROM, proxy_port_to=DEFAULT_PROXY_PORT_TO)
        #raise SimpleProxiesDeployingException.new(9, "#{proxy_port_from}") if proxy_port_from != DEFAULT_PROXY_PORT_FROM
        raise SimpleProxiesDeployingException.new(10, "#{proxy_port_from} and #{proxy_port_to}") if proxy_port_from > proxy_port_to
        #raise SimpleProxiesDeployingException.new(11, "from #{proxy_port_from} to #{proxy_port_to}") if (proxy_port_to-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE != 0

        # TODO: validate the output
        logger.logs "Get interface name... "
        interface = self.get_interface_name
        logger.logf "done (#{interface})"

        logger.logs "Get server main ip from configuration... "
        mainip = self.net_remote_ip
        logger.logf "done (#{mainip})"

        logger.logs "Install ethtool... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'apt-get install ethtool'")
        logger.done

        # get list of 4-hex-digits subnets
        logger.logs "Initialize list of 4-hex-digit numbers... "
        hex4digits = []
        "123456789ABCDEF".split('').each { |a| # don't inclulude codes with leading 0, in order to get codes that are 4 digits even in STANDARD notation
            "0123456789ABCDEF".split('').each { |b|
                "0123456789ABCDEF".split('').each { |c|
                    "0123456789ABCDEF".split('').each { |d|
                        hex4digits << "#{a}#{b}#{c}#{d}".downcase
                    }
               }
            }
        }
        logger.logf "done (#{hex4digits.size} numbers)"

        logger.logs "Shuffle list of 4-hex-digit numbers... "
        hex4digits.shuffle!
        logger.logf "done (#{hex4digits[0]}, #{hex4digits[1]}, #{hex4digits[2]}, ...)"

        logger.logs "Initialize list proxies... "
        results = get_ipv6_proxies
        logger.logf "done (#{results.size} ports)"

        # TODO: validate the output
        logger.logs "Install ethtool... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'apt-get install ethtool'")
        logger.done

        # TODO: validate the output
        logger.logs "Install curl... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'apt-get install curl'")
        logger.done
        
        logger.logs "Stop proxy server... "
        stdout = self.stop_proxies
        logger.done #logf "done (#{stdout})"

        # TODO: validate this output
        logger.logs "Add /48 subnet to interface... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'ifconfig #{interface} add #{self.ipv6_subnet_48}::/48'")
        logger.done #logf "done (#{stdout})"

        # TODO: validate this output
        logger.logs "Add default route for IPv6... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'ip -6 route add default via #{self.ipv6_subnet_48}::1'")
        logger.done #logf "done (#{stdout})"

        # TODO: validate this output
        logger.logs "Setup /etc/network.conf... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'echo \"ifconfig #{interface} add #{self.ipv6_subnet_48}::/48
        ip -6 route add default via #{self.ipv6_subnet_48}::1\" >> /etc/network.conf'")
        logger.done #.logf "done (#{stdout})"

        # TODO: validate this output
        logger.logs "Remove exit 0 FROM rc.local... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c \"sed -i '/exit 0/d' /etc/rc.local\"")
        logger.done #.logf "done (#{stdout})"

        # TODO: validate this output
        logger.logs "Remove exit 0 FROM rc.local... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'echo \"bash /etc/network.conf\" >> /etc/rc.local'")
        logger.done #.logf "done (#{stdout})"

        logger.logs "Remove not available /64 subnets... "
        available_hex4digits = hex4digits.reject { |hex|
            results.map { |result| 
                result[:subnet64] 
            }.include?("#{self.ipv6_subnet_48}:#{hex}") 
        }
        logger.logf("done (#{available_hex4digits.size})")

        logger.logs "Iterate ports... "
        port = proxy_port_from
        while port<=proxy_port_to
            logger.logs "Checking port #{port}... "
            if results.map { |result| result[:port].to_i }.include?(port)
                logger.logf "done (already installed)"
            else
                #logger.logs "Get an available subnet64... "
                hex = available_hex4digits[0]
                subnet64 = "#{self.ipv6_subnet_48}:#{hex}"
                #logger.logf "done (#{subnet64})"

                #logger.logs "Remove #{subnet64} from list of available subnets64... "
                available_hex4digits.reject! { |x| x == hex }
                #logger.logf("done (#{available_hex4digits.size})")

                #logger.logs "Build random IPv6... "
                ipv6 = "#{subnet64}:#{hex4digits.shuffle[0]}:#{hex4digits.shuffle[0]}:#{hex4digits.shuffle[0]}:#{hex4digits.shuffle[0]}" 
                #logger.logf("done (#{ipv6})")
                
                #logger.logs "Add record to configuration file... "
                stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'echo proxy -p#{port} -6 -a -n  -i0.0.0.0 -e#{ipv6} >> /usr/local/etc/3proxy/cfg/3proxy.cfg'")
                #logger.logf("done (#{stdout})")

                #logger.logs "Add IPv6 address... "
                stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'ip address add #{ipv6} dev #{interface} > /dev/null 2>&1'")
                #logger.logf("done (#{stdout})")

                logger.done
            end
            port += 1
        end

        # TODO: validate this output
        logger.logs "Start proxy server... "
        stdout = self.start_proxies
        logger.done #logf "done (#{stdout})"

        # TODO: validate this output
        logger.logs "Add exit 0 TO rc.local... "
        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'echo \"exit 0\" >> /etc/rc.local'")
        logger.logf "done (#{stdout})"
    
    end

    def ssh_disconnect()
        self.ssh.close
    end

end # class RemoteHost