require_relative '../config.rb'
require_relative '../lib/simpleproxiesdeploying.rb'

logger = BlackStack::LocalLogger.new('./checkall.log')

SERVERS.each { |h|
    errors = []

    logger.logs "#{h[:net_remote_ip]}... "
    begin

        #logger.logs 'creating object... '
        host = RemoteHost.parse(h)
        #logger.done

        #logger.logs 'connecting... '
        host.ssh_connect
        #logger.done

        #logger.logs 'checking ports configuration... '
        #errors = host.check_all_ipv6_proxies(DEFAULT_PROXY_PORT_FROM, DEFAULT_PROXY_PORT_TO)
        #logger.logf "done (#{errors.size} errors)"

        #logger.logs "disconnecting... "
        host.ssh_disconnect
        #logger.done

        logger.logf "done (#{errors.size} errors)"

    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_console})"
    end
}
