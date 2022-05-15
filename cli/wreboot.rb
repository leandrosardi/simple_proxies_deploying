# Automated reboot of worker servers.

require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::BaseLogger.new(nil)

WORKERS.each { |h|
    errors = []

    logger.logs "#{h[:name]} (#{h[:net_remote_ip]})... "
    begin

        logger.logs 'creating object... '
        host = RemoteHost.parse(h, logger)
        logger.done

        logger.logs 'connecting... '
        host.ssh_connect
        logger.done

        logger.logs "reboot... "
        #host.reboot()
        begin
            stdout = host.ssh.exec!("echo '#{host.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'reboot'")
        rescue
            # nothing here
        end
        logger.done

#        logger.logs "disconnecting... "
#        host.ssh_disconnect
#        logger.done

        logger.logf "done (#{errors.size} errors)"

    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_console})"
    end
}

