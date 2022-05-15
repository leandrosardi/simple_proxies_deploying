# Remove Multilogin installation

require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::BaseLogger.new(nil)

WORKERS.each { |h|
    errors = []

    logger.logs "#{h[:net_remote_ip]}... "
    begin

        logger.logs 'creating object... '
        host = RemoteHost.parse(h, logger)
        logger.done

        logger.logs 'connecting... '
        host.ssh_connect
        logger.done

        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S") 
        logger.logs "starting workers (#{timestamp})... "
        stdout = host.ssh.exec!("echo '#{host.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'mv /opt/Multilogin /opt/Multilogin.#{timestamp}'")
        logger.logf "done (#{stdout.strip})"

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

