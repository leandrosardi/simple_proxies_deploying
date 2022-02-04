require 'net/ssh'

port = 4200

=begin
nano ./ipv6.install.2.sh
./ipv6.install.2.sh 2a0f:9400:8025 4200


echo b9a623e641831 | sudo ./ipv6.install.2.sh 2a0f:9400:8025 4200

echo 'b9a623e641831' | sudo -S su root -c './ipv6.install.2.sh 2a0f:9400:8025 4200'

echo 'SantaClara123' | sudo -S su root -c 'ufw disable'

wget http://raw.githubusercontent.com/leandrosardi/x/main/sh/ipv6.install.2.sh

wget 185.199.108.133/leandrosardi/x/main/sh/ipv6.install.2.sh
=end

user = 'leandros'
pass = 'SantaClara123'

servers = [
    {:ip => '185.14.97.236', :user => 'root', :password => 'Zwmp7597', :subnet => '2a03:94e0:2691', :additional_ips = []},
]

=begin
1. login to the SSH with root credentials
2. run the command
3. write the subnet
4. write the first port
5. restart the server

rm ipv6.install.2.sh;wget https://raw.githubusercontent.com/leandrosardi/x/main/sh/ipv6.install.2.sh;chmod +x ./ipv6.install.2.sh
./ipv6.install.2.sh 2a04:2180:7 4400
=end

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
    stdout = ssh.exec!("rm ./ipv4.install.2.sh")
#    puts stdout
#    puts
    
#    print "5. "
    stdout = ssh.exec!("wget https://raw.githubusercontent.com/leandrosardi/x/main/sh/ipv4.install.2.sh")
#    puts stdout
#    puts

#    print "6. "
    stdout = ssh.exec!("chmod +x ./ipv4.install.2.sh")
#    puts stdout
#    puts

#    print "7. "
    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c './ipv4.install.2.sh #{user} #{pass}'")
#    puts stdout
#    puts

#    print "disconnecting... "
    ssh.close
#    puts 'done'
#    puts

    if stdout =~ /Proxy Creation Successful/
        puts 'success'
    else
        puts "error: #{stdout}"
    end
}
