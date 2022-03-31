require 'net/ssh'
require 'blackstack_commons'
require_relative './config.rb'

# TODO: design the proxy server managment as an addon of SimpleHostMonitoring

# matching ipv6 addresses with standard notation (not compact. not mixed.)
MATCH_IPV6_STANDARD = /[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]/i # reference: https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch08s17.html
MATCH_IPV6_64_SUBNET_STANDARD = /^[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]:[A-F0-9][A-F0-9][A-F0-9][A-F0-9]/i

class SimpleProxyServerException < StandardError
    attr_accessor :code, :custom_description
  
    ERROR_CODES = [
        { :code => 1, :description => 'Host has not SSH parameters' },   
        { :code => 2, :description => 'Proxy port is not a valid port' },
        { :code => 3, :description => 'No SSH connection' },
        { :code => 4, :description => 'SSH connection failed' },
        { :code => 5, :description => 'IPv6 subnet /48 is not defined for this host' },
        { :code => 6, :description => 'Extenral IP is not belonging the IPv6 subnet /48 defined for this host' },
        { :code => 7, :description => 'More than 1 external IP defined for this proxy port' },
        { :code => 8, :description => 'There is not external IP defined for this proxy port' },
    ]

    def self.description(code)
        ERROR_CODES.each do |error_code|
            return error_code[:description] if error_code[:code] == code
        end
        return 'Unknown error code'
    end

    def simple_description
        self.class.description(self.code)
    end

    def description
        self.custom_description.nil? ? self.simple_description : self.custom_description
    end

    def initialize(the_code, the_custom_description = nil)
        self.code = the_code
        self.custom_description = the_custom_description.nil? ? nil : "#{SimpleProxyServerException.description(self.code)}: #{the_custom_description}" 
    end
end 

# TODO: replace RemoteHost class in SimpleHostsMonitoring library by this code 
class RemoteHost
    # TODO: this must be defined at class RemoteHost in the SimpleHostMonitoring library
    attr_accessor :cpu_architecture, :cpu_speed, :cpu_load_average, :cpu_model, :cpu_type, :cpu_number, :mem_total, :mem_free, :disk_total, :disk_free, :net_hostname, :net_remote_ip, :net_mac_address  
    attr_accessor :stealth_browser_technology_code, :ssh_username, :ssh_password, :ssh_port, :ipv6_subnet_48
    attr_accessor :ssh # this is the ssh connection

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

    def self.parse(h)
        o = RemoteHost.new
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
        raise SimpleProxyServerException.new(1) if !self.ssh_parameters?

        # connect
        self.ssh = Net::SSH.start(self.net_remote_ip, self.ssh_username, :password => self.ssh_password, :port => self.get_ssh_port)

        # validation: the connection must be established
        raise SimpleProxyServerException.new(4) if !self.ssh
    end

    # dig inside the 3proxy.cfg file to find the ipv6 address assigned to this port
    # return nil if there is not external_ip (not proxy) defined for this port.
    # return the external IP if there is one.
    # 
    # raise an exception if there is more than 1 extenral IP defined for this host.
    # raise an exception if the external ip is not belonging the subnet defined at ipv6 subnet 48
    # 
    def get_proxy_extenral_ip(proxy_port)
        # validation: this host must have defined an ipv6 subnet 48
        raise SimpleProxyServerException.new(5) if !self.ipv6_subnet_48

        # validation: proxy_port must be a number
        raise SimpleProxyServerException.new(2) if !RemoteHost.valid_port_number?(proxy_port)

        # validation: this host must have ssh connection
        raise SimpleProxyServerException.new(3) if !self.ssh

        stdout = ssh.exec!("echo '#{self.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'grep #{proxy_port} /usr/local/etc/3proxy/cfg/3proxy.cfg'")
        a = stdout.scan(MATCH_IPV6_STANDARD)

        # validation: there is no more than 1 extenral IP defined for this host
        raise SimpleProxyServerException.new(7, a.join(', ')) if a.size > 1

        # validation: there is no extenral IP defined for this port
        # raise SimpleProxyServerException.new(8) if a.size == 0

        # validation: the external ip must be belonging the subnet defined at ipv6 subnet 48
        raise SimpleProxyServerException.new(6, "#{a[0]} and #{self.ipv6_subnet_48}") if !a[0].include?(self.ipv6_subnet_48)

        # return the external IP
        a.size == 0 ? nil : a[0]
    end

    # check a list of port numbers and return the list of ports that are missconfigured
    # return an array of errors.
    # validate if there is more than one external ip address belonging the same /64 subnet.
    # validate that each batch of 50 ports is all configured.
    # proxy_port_from: must be 4000.
    # proxy_port_to: must be higher than proxy_port_from.
    # proxy_port_to+1: must be mod 50.
    def check_proxies(prox_port_from, proxy_port_to)
        # return this array with the list of glitches found
        errors = []
        
        # record all the /64 subnets of each external ip address, to check if there is more than one external ip address belonging the same /64 subnet 
        external_ip_64_subnets = [] # the /64 subnets of the external ip addresses

        port = prox_port_from
        while (port <= proxy_port_to)
            begin
                print "Checking port #{port}... "
                extip = self.get_proxy_extenral_ip(port)
                subnet64 = extip.scan(MATCH_IPV6_64_SUBNET_STANDARD)[0]

                # validation: there is more than one external ip address belonging the same /64 subnet.
                

                # validation: that each batch of 50 ports is all configured.


                puts "done (#{extip} / #{subnet64})"
            rescue SimpleProxyServerException => e
                errors << { :proxy_port=>port, :code=>e.code, :description=>e.description, :simple_description=>e.simple_description }
                puts "error #{e.code} (#{e.simple_description})"
            rescue => e
                puts "unhandled exception (#{e.to_s})"
            end
            port += 1
        end
        errors
    end

    # check a list of port numbers and install the proxies that are not configured yet
    def install_proxies(prox_port_from, proxy_port_to)
    end

    def ssh_disconnect()
        self.ssh.close
    end

end


SERVERS.each { |h|
    puts "#{h[:ip]}... "

    print 'checking ports configuration... '
    begin

        print 'connecting... '
        host = RemoteHost.parse(h)
        puts 'done'

        print 'connecting... '
        host.ssh_connect
        puts 'done'

        puts 'checking ports configuration... '
        errors = host.check_proxies(4000, 4010)
        puts "done (#{errors.size} errors)"

        print "disconnecting... "
        host.ssh_disconnect
        puts 'done'

        puts "done with #{h[:ip]}"

    rescue SimpleProxyServerException => e
        puts "error #{e.code} (#{e.description})"
    rescue => e
        puts "unhandled exception (#{e.to_console})"
    end

=begin
#    print "4. "
    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c 'ufw disable'")
#    puts stdout
#    puts

#    print "4. "
    stdout = ssh.exec!("rm ./ipv6.install.2.sh")
#    puts stdout
#    puts
    
#    print "5. "
    stdout = ssh.exec!("wget https://raw.githubusercontent.com/leandrosardi/x/main/sh/ipv6.install.2.sh")
#    puts stdout
#    puts

#    print "6. "
    stdout = ssh.exec!("chmod +x ./ipv6.install.2.sh")
#    puts stdout
#    puts

#    print "7. "
    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c './ipv6.install.2.sh #{h[:subnet]} #{PORT}'")
#    puts stdout
#    puts

    if stdout =~ /Copy your proxies to another file/
        puts 'success'
    else
        puts "error: #{stdout}"
    end
=end
}
