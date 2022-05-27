=begin
require 'net/ssh'

net_remote_ip = '74.208.37.122'
ssh_username = 'bots'
ssh_password = 'SantoBartolo707'
get_ssh_port = '22'

ssh = Net::SSH.start(net_remote_ip, ssh_username, :password => ssh_password, :port => get_ssh_port)

s = "bash --login -c 'sleep 600' >/dev/null 2>&1 &"
print "run (#{s})... "
stdout = ssh.exec!(s)
puts "done (#{stdout.strip})"

ssh.close

exit(0)
=end

require_relative '../config.rb'
require_relative '../lib/simple_proxies_deploying.rb'

logger = BlackStack::BaseLogger.new(nil)

commands = [
        'git fetch --all',
        'git reset --hard origin/master',
        'chmod +x ./*.rb',
        'chmod +x ./p/*.rb',
        'chmod +x ./cli/*.rb',
        'chmod +x ./bash/*.sh',
        'gem uninstall stealth_browser_automation --all -I',
        'gem uninstall nextobt --all -I',
        'gem uninstall bots --all -I',
        'cd ./gems; gem install stealth_browser_automation',
        'cd ./gems; gem install nextbot',
        'cd ./gems; gem install bots',

]

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

        logger.logs "kill... "
        output = host.ssh.exec!("pkill xterm")
        output = host.ssh.exec!("pkill chrome")
        output = host.ssh.exec!("pkill ruby")
        output = host.ssh.exec!("pkill bash")
        output = host.ssh.exec!("pkill multilogin")
        output = host.ssh.exec!("pkill headless")
        logger.logf "done (#{output.strip})"

        logger.logs "get display code... "
        display = host.ssh.exec!("ps -ef |grep Xauthor | grep -v grep | nawk '{print $9}'").strip
        # TODO: validar el output
        logger.logf "done (#{display.strip})"

        commands.each { |command|
                logger.logs "run (#{command})... "
                s = "DISPLAY=#{display};export DISPLAY;/bin/bash --login -c \"rvm use 2.2.4;cd /home/bots/code/tempora;#{command};\""
                stdout = host.ssh.exec!(s)
                # TODO: validar el output
                logger.done #logf "done (#{stdout.strip})"
        }

        logger.logf "done (#{errors.size} errors)"

    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_console})"
    end
}

