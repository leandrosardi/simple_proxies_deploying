require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::BaseLogger.new(nil)

#PORTS = [3130, 4000, 4050, 4300, 4350, 4400, 4450]
PORTS = [4000]

SERVERS.each { |h|
    host = RemoteHost.parse(h)
    PORTS.each { |port|
        logger.logs "#{h[:net_remote_ip]}:#{port}... "
        begin
            host.test2('leandros', 'SantaClara123', port)
            logger.done
        rescue SimpleProxiesDeployingException => e
            logger.logf "error #{e.code} (#{e.description})"
        rescue => e
            logger.logf "unhandled exception (#{e.to_s})"
        end
    }
}
