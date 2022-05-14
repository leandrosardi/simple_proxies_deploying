# Automated start of processes worker servers.

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

        logger.logs "starting workers... "
        stdout = host.ssh.exec!('
            cd ~/code/tempora/bash &
            DISPLAY=:10 &
            export DISPLAY &
            xterm -e bash -c "cd ~/code/tempora;./shm.rb;bash" &
        ')
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

