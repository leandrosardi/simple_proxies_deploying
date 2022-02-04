require 'net/ssh'
require_relative './config.rb'

servers.each { |h|
    print "#{h[:ip]}... "

#    print 'connecting... '
    ssh = Net::SSH.start(h[:ip], h[:user], :password => h[:password])
#    puts 'done'
#    puts

#    print "4. "
    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c 'ufw disable'")
#    puts stdout
#    puts

#    print "4. "
    stdout = ssh.exec!("rm ./ipv6.install.2.sh")
#    puts stdout
#    puts
    
#    print "5. "
    stdout = ssh.exec!("wget https://raw.githubusercontent.com/leandrosardi/x/main/sh/ipv6.install.2.sh")
#    puts stdout
#    puts

#    print "6. "
    stdout = ssh.exec!("chmod +x ./ipv6.install.2.sh")
#    puts stdout
#    puts

#    print "7. "
    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c './ipv6.install.2.sh #{h[:subnet]} #{port}'")
#    puts stdout
#    puts

#    print "disconnecting... "
    ssh.close
#    puts 'done'
#    puts

    if stdout =~ /Copy your proxies to another file/
        puts 'success'
    else
        puts "error: #{stdout}"
    end
}
