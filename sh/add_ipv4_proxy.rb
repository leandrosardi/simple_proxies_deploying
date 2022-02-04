require 'net/ssh'
require_relative './config.rb'

SERVERS.each { |h|
    print "#{h[:ip]}... "

    print 'connecting... '
    ssh = Net::SSH.start(h[:ip], h[:user], :password => h[:password])
    puts 'done'
    puts

    print "4. "
#    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c 'ufw disable'") # use this line of the use has not root privileges.
    stdout = ssh.exec!("ufw disable")
    puts stdout
    puts

    print "4. "
    stdout = ssh.exec!("rm ./ipv4.install.2.sh")
    puts stdout
    puts
    
    print "5. "
    stdout = ssh.exec!("wget https://raw.githubusercontent.com/leandrosardi/x/main/sh/ipv4.install.2.sh")
    puts stdout
    puts

    print "6. "
    stdout = ssh.exec!("chmod +x ./ipv4.install.2.sh")
    puts stdout
    puts

    print "7. "
#    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c './ipv4.install.2.sh #{USER} #{PASS}'") # use this line of the use has not root privileges.
    stdout = ssh.exec!("./ipv4.install.2.sh #{USER} #{PASS}")
    puts stdout
    puts

    print "disconnecting... "
    ssh.close
    puts 'done'
    puts

    if stdout =~ /Proxy Creation Successful/
        puts 'success'
    else
        puts "error: #{stdout}"
    end
}
