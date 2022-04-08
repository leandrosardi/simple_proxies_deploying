require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

PARSER = BlackStack::SimpleCommandLineParser.new(
  :description => 'Get insight details of all missconfigurations of a specific server.', 
  :configuration => [{
    :name=>'ip', 
    :mandatory=>true, 
    :description=>'IP of the server that you want to gathering error details.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]    
)

PORTS = [3130, 4000, 4050, 4300]

logger = BlackStack::BaseLogger.new(nil)

SERVERS.select { |s| s[:net_remote_ip] == PARSER.value('ip') }.each { |h|
    errors = []

    logger.logs "#{h[:net_remote_ip]}... "
    begin

        logger.logs 'creating object... '
        host = RemoteHost.parse(h)
        logger.done

        logger.logs 'connecting... '
        host.ssh_connect
        logger.done

        logger.logs 'testing... '
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
        logger.done

        logger.logs "disconnecting... "
        host.ssh_disconnect
        logger.done

    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_console})"
    end
}
