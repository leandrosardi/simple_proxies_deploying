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

    # dig inside the 3proxy.cfg file to find the ipv6 address assigned to this port
    # return nil if there is not external_ip (not proxy) defined for this port.
    # return the external IP if there is one.
    # 
    # raise an exception if there is more than 1 extenral IP defined for this host.
    # raise an exception if the external ip is not belonging the subnet defined at ipv6 subnet 48
    # 
    # TODO: deprecated!
    #
    def get_proxy_extenral_ip(proxy_port)
        # validation: this host must have defined an ipv6 subnet 48
        raise SimpleProxiesDeployingException.new(5) if !self.ipv6_subnet_48

        # validation: proxy_port must be a number
        raise SimpleProxiesDeployingException.new(2) if !RemoteHost.valid_port_number?(proxy_port)

        # validation: this host must have ssh connection
        raise SimpleProxiesDeployingException.new(3) if !self.ssh

        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'grep #{proxy_port} /usr/local/etc/3proxy/cfg/3proxy.cfg'")
        a = stdout.scan(MATCH_IPV6_STANDARD)

        # validation: there is no more than 1 extenral IP defined for this host
        raise SimpleProxiesDeployingException.new(7, a.join(', ')) if a.size > 1

        # validation: there is no extenral IP defined for this port
        # raise SimpleProxiesDeployingException.new(8) if a.size == 0

        # validation: the external ip must be belonging the subnet defined at ipv6 subnet 48
        raise SimpleProxiesDeployingException.new(6, "#{a[0]} and #{self.ipv6_subnet_48}") if !a[0].include?(self.ipv6_subnet_48)

        # return the external IP
        a.size == 0 ? nil : a[0]
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
    # validate if there is more than one external ip address belonging the same /64 subnet.
    # validate that each batch of 50 ports is all configured.
    # raise an exception if there are ports outside the range
    # raise an exception if proxy_port_from is not 4000.
    # raise an exception proxy_port_to is not higher than proxy_port_from.
    # raise an exception if proxy_port_to+1 is not mod 50.
    def check_all_ipv6_proxies(proxy_port_from=DEFAULT_PROXY_PORT_FROM, proxy_port_to=DEFAULT_PROXY_PORT_TO)
        raise SimpleProxiesDeployingException.new(9, "#{proxy_port_from}") if proxy_port_from != DEFAULT_PROXY_PORT_FROM
        raise SimpleProxiesDeployingException.new(10, "#{proxy_port_from} and #{proxy_port_to}") if proxy_port_from > proxy_port_to
        raise SimpleProxiesDeployingException.new(11, "from #{proxy_port_from} to #{proxy_port_to}") if (proxy_port_to-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE != 0

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
=begin
        # validation: that each batch of 50 ports is all configured, or ir is empty
        self.logger.logs 'Check non-completed batches... '
        i = 0
        results.each { |r|
            port = r[:port]
            # si es el fin de un batch
            if (port-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE == 0
                # cantidad de proxies configurados
                port_from = port - DEFAULT_PROXY_PORTS_BATCH_SIZE + 1
                port_to = port
                b = results.select { |s| s[:port]>=port_from && s[:port]<=port_to && s[:external_ip].nil? }
                c = results.select { |s| s[:port]>=port_from && s[:port]<=port_to && !s[:external_ip].nil? }
                if b.size != DEFAULT_PROXY_PORTS_BATCH_SIZE || b.size != DEFAULT_PROXY_PORTS_BATCH_SIZE
                    e = SimpleProxiesDeployingException.new(13, "#{c.size} proxies configured")
                    errors << { :proxy_port=>r[:port], :code=>e.code, :description=>e.description, :simple_description=>e.simple_description }
                    i += 1
                end
            end # if !r[:external_ip].nil?
        }             
        self.logger.logf "done (#{i.to_s} errors)"
=end
        # return
        errors
    end # def check_all_ipv6_proxies

    # check a list of port numbers and install the proxies that are not configured yet
    # raise an exception if proxy_port_from is not 4000.
    # raise an exception proxy_port_to is not higher than proxy_port_from.
    # raise an exception if proxy_port_to+1 is not mod 50.
    def install_ipv6_proxies(proxy_port_from=DEFAULT_PROXY_PORT_FROM, proxy_port_to=DEFAULT_PROXY_PORT_TO)
        raise SimpleProxiesDeployingException.new(9, "#{proxy_port_from}") if proxy_port_from != DEFAULT_PROXY_PORT_FROM
        raise SimpleProxiesDeployingException.new(10, "#{proxy_port_from} and #{proxy_port_to}") if proxy_port_from > proxy_port_to
        raise SimpleProxiesDeployingException.new(11, "from #{proxy_port_from} to #{proxy_port_to}") if (proxy_port_to-proxy_port_from+1) % DEFAULT_PROXY_PORTS_BATCH_SIZE != 0



    end

    def ssh_disconnect()
        self.ssh.close
    end

end # class RemoteHost