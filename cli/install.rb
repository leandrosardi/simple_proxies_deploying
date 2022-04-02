require_relative '../config.rb'
require_relative '../lib/simpleproxiesdeploying.rb'

PARSER = BlackStack::SimpleCommandLineParser.new(
  :description => 'Get insight details of all missconfigurations of a specific server.', 
  :configuration => [{
    :name=>'ip', 
    :mandatory=>true, 
    :description=>'IP of the server that you want to gathering error details.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]    
)

logger = BlackStack::BaseLogger.new(nil)

SERVERS.select { |s| s[:net_remote_ip] == PARSER.value('ip') }.each { |h|
    errors = []

    logger.logs "#{h[:net_remote_ip]}... "
    begin

        logger.logs 'creating object... '
        host = RemoteHost.parse(h, logger)
        logger.done

        logger.logs 'connecting... '
        host.ssh_connect
        logger.done

        # TODO: validate the current configuration before install anything?

        logger.logs 'install... '
        host.install(4099, 4101)
        logger.done

        logger.logs "disconnecting... "
        host.ssh_disconnect
        logger.done

        logger.logf "done (#{errors.size} errors)"

    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_console})"
    end
}

