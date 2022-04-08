require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::LocalLogger.new('./checkall.log')

PORTS = [3130, 4000, 4050, 4300]

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
