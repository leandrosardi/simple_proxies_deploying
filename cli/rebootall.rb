require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::BaseLogger.new(nil)

stdout = nil

SERVERS.each { |h|

    logger.logs "#{h[:net_remote_ip]}... "
    begin
        logger.logs 'creating object... '
        host = RemoteHost.parse(h, logger)
        logger.done

        logger.logs 'connecting... '
        host.ssh_connect
        logger.done

        logger.logs 'reboot... '
        #stdout = host.reboot
        begin
        stdout = host.ssh.exec!("echo '#{host.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'reboot'")
        rescue
        end
        logger.logf("done (#{stdout})")

        logger.logs 'wait... '
        sleep(15)
        logger.done

        logger.logs 'connecting... '
        host.ssh_connect
        logger.done

        logger.logs 'stop proxy service... '
        stdout = host.ssh.exec!("echo '#{host.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh stop  > /dev/null 2>&1'")
        logger.logf("done (#{stdout})")

        logger.logs 'start proxy service... '
        stdout = host.ssh.exec!("echo '#{host.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'sh /usr/local/etc/3proxy/scripts/rc.d/proxy.sh start  > /dev/null 2>&1'")
        logger.logf("done (#{stdout})")

        logger.logs 'setup network.conf... '
        stdout = host.ssh.exec!("echo '#{host.ssh_password.gsub("'", "\\'")}' | sudo -S su root -c 'bash /etc/network.conf'")
        logger.logf("done (#{stdout})")
        
        logger.logs "disconnecting... "
        host.ssh_disconnect
        logger.done
        
    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_s})"
    end
    logger.done


}
