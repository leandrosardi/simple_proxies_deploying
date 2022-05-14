# Automated deploy of new version on worker servers.

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
=begin
        logger.logs "reboot... "
        host.reboot()
        logger.done
=end
        # TODO: validate the current configuration before deploying anything?

        # TODO: validate the stdout of the commands
#        logger.logs "Bash login... "
#        stdout = host.ssh.exec!("/bin/bash --login")
#        logger.logf "done (#{stdout.strip})"

        logger.logs "git fetch... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;git fetch --all;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "git reset... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;git reset --hard origin/master;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "chmod +x ./*.rb... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;chmod +x ./*.rb;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "chmod +x ./p/*.rb... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;chmod +x ./p/*.rb;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "chmod +x ./cli/*.rb... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;chmod +x ./cli/*.rb;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "chmod +x ./bash/*.sh... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;chmod +x ./bash/*.sh;
        ")
        logger.logf "done (#{stdout.strip})"
=begin
        logger.logs "bundler update... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora;bundler update;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "gem uninstall bots... "
        stdout = host.ssh.exec!("
            gem uninstall bots --all -I;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "gem uninstall nextbot... "
        stdout = host.ssh.exec!("
            gem uninstall nextbot --all -I;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "gem uninstall stealth_browser_automation... "
        stdout = host.ssh.exec!("
            gem uninstall stealth_browser_automation --all -I;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "gem install bots... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora/gems;gem install bots;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "gem install nextbot... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora/gems;gem install nextbot;
        ")
        logger.logf "done (#{stdout.strip})"

        logger.logs "gem install stealth_browser_automation... "
        stdout = host.ssh.exec!("
            cd ~/code/tempora/gems;gem install stealth_browser_automation;
        ")
        logger.logf "done (#{stdout.strip})"
=end
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

