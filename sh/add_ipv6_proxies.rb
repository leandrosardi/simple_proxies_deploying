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

servers = [
=begin
    {:ip => '185.64.105.125', :user => 'root', :password => '5aNfY81SsM11nEm', :subnet => '2a04:2180:7',},
    {:ip => '185.25.48.64', :user => 'root', :password => 'Yb73t7@tY9#BgI', :subnet => '2a04:2180:d',},
    {:ip => '185.25.48.65', :user => 'root', :password => '1Ss1hvA9T[*aU0', :subnet => '2a04:2180:e',},
    {:ip => '185.25.48.66', :user => 'root', :password => 'TyZE4m]ul93M6;', :subnet => '2a04:2180:f',},
    {:ip => '206.83.41.80', :user => 'vpsuser716', :password => 'b9a623e641831', :subnet => '2a0f:9400:8025',},
    {:ip => '103.144.177.106', :user => 'vpsuser550', :password => 'SantaClara123', :subnet => '2a0f:9400:771a',},
#    {:ip => '206.83.40.47', :user => 'vpsuser550', :password => 'SantaClara123', :subnet => '2a0f:9400:770c',},
    {:ip => '103.144.176.151', :user => 'vpsuser550', :password => 'SantaClara123', :subnet => '2602:fed2:770f',},
    {:ip => '23.152.224.26', :user => 'vpsuser550', :password => 'SantaClara123', :subnet => '2602:fed2:7314 ',},
    {:ip => '103.144.177.107', :user => 'vpsuser550', :password => 'SantaClara123', :subnet => '2a0f:9400:771b',},
#    {:ip => '23.152.226.78 ', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:7317',},
=end
    {:ip => '103.144.177.89', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:7316',},
    {:ip => '206.83.40.83', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2a0f:9400:772d',},
    {:ip => '103.144.176.27', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:7129',},
    {:ip => '206.83.41.85', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2a0f:9400:772c',},
    {:ip => '23.154.81.14', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:7128',},
    {:ip => '23.152.226.80', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:770e',},
    {:ip => '103.144.177.88', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:7311',},
    {:ip => '206.83.40.85', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2a0f:9400:772b',},
    {:ip => '103.144.176.195', :user => 'vpsuser-550', :password => 'SantaClara123', :subnet => '2602:fed2:770a',},
]
=begin
servers = [
    {:ip => '206.83.40.47', :user => 'vpsuser550', :password => 'SantaClara123', :subnet => '2a0f:9400:770c',},
]
=end

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
