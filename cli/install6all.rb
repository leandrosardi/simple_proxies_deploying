require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::BaseLogger.new(nil)

SERVERS.each { |h|
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

        # TODO: validate the stdout of the command
        logger.logs 'backup old configuration file... '
        stdout = host.backup_configuration_file
        logger.logf("done (#{stdout})")

        logger.logs 'install 3proxy... '
        host.install6
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

