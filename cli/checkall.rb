require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::LocalLogger.new('./checkall.log')

SERVERS.each { |h|
    errors = []
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
}
