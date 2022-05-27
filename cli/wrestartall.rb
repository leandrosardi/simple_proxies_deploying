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
        'shm.rb',
        'mlalistener.rb port=45010',
        'mlalistener.rb port=45011',
        'mlalistener.rb port=45012',
        'mlalistener.rb port=45013',
        'mlalistener.rb port=45014',
        'mlalistener.rb port=45015',
        'mlalistener.rb port=45016',
        'mlalistener.rb port=45017',
        'worker.rb name=unicorn01',
        'worker.rb name=unicorn02',
        'worker.rb name=unicorn03',
        'worker.rb name=unicorn04',
        'worker.rb name=unicorn05',
        'worker.rb name=unicorn06',
        'worker.rb name=unicorn07',
        'worker.rb name=unicorn08',
        'worker.rb name=unicorn09',
        'worker.rb name=unicorn10',
        'worker.rb name=unicorn11',
        'worker.rb name=unicorn12',
        'worker.rb name=unicorn13',
        'worker.rb name=unicorn14',
        'worker.rb name=unicorn15',
        'worker.rb name=unicorn16',
]

WORKERS.each { |h|
    errors = []

    logger.logs "#{h[:net_remote_ip]}... "
    begin

        #logger.logs 'creating object... '
        host = RemoteHost.parse(h, logger)
        #logger.done

        #logger.logs 'connecting... '
        host.ssh_connect
        #logger.done

        #logger.logs "kill... "
        output = host.ssh.exec!("pkill xterm")
        output = host.ssh.exec!("pkill chrome")
        output = host.ssh.exec!("pkill ruby")
        output = host.ssh.exec!("pkill bash")
        output = host.ssh.exec!("pkill multilogin")
        output = host.ssh.exec!("pkill headless")
        #logger.logf "done (#{output.strip})"

        #logger.logs "get display code... "
        display = host.ssh.exec!("ps -ef |grep Xauthor | grep -v grep | nawk '{print $9}'").strip
        #logger.logf "done (#{display.strip})"

        commands.each { |command|
                #logger.logs "run (#{command})... "
                s = "DISPLAY=#{display};export DISPLAY;/bin/bash --login -c \"xterm -e bash -c 'cd /home/bots/code/tempora;./#{command};bash'\" >/dev/null 2>&1 &"
                stdout = host.ssh.exec!(s)
                #logger.logf "done (#{stdout.strip})"
        }

        logger.logf "done (#{errors.size} errors)"

    rescue SimpleProxiesDeployingException => e
        logger.logf "error #{e.code} (#{e.description})"
    rescue => e
        logger.logf "unhandled exception (#{e.to_console})"
    end
}

