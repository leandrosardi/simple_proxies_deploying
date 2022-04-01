class SimpleProxiesDeployingException < StandardError
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

        # ports batch validations
        { :code => 9, :description => "By now proxy_port_from must be #{DEFAULT_PROXY_PORT_FROM}" },
        { :code => 10, :description => "proxy_port_to must be higher than proxy_port_from" },
        { :code => 11, :description => "[proxy_port_from..proxy_port_to] must be mod of batch size #{DEFAULT_PROXY_PORTS_BATCH_SIZE}" },
        { :code => 12, :description => "Other proxies are belonging the same /64 subnet" },
        { :code => 13, :description => "Each batch of 50 ports must be all configured or all empty" },
        { :code => 14, :description => "Ports outside the range found" },
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
        self.custom_description = the_custom_description.nil? ? nil : "#{SimpleProxiesDeployingException.description(self.code)}: #{the_custom_description}" 
    end
end 
