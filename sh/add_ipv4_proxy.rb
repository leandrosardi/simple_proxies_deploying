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
#    {:ip => '185.14.97.236', :user => 'root', :password => 'Zwmp7597', :subnet => '2a03:94e0:2691', additional_ips => []},
    {:ip => '185.14.97.237', :user => 'root', :password => 'Hqsj1323', :subnet => '2a03:94e0:2697', additional_ips => []},
    {:ip => '185.14.97.239', :user => 'root', :password => 'Trwq6058', :subnet => '2a03:94e0:26a5', additional_ips => []},
    {:ip => '194.32.107.203', :user => 'root', :password => 'Jymd9533', :subnet => '2a03:94e0:27b5', additional_ips => []},
=begin
    {:ip => '185.125.168.3', :user => 'root', :password => 'Guyv1903', :subnet => '2a03:94e0:1406', additional_ips => []},
    {:ip => '185.125.168.4', :user => 'root', :password => 'Xgqy8874', :subnet => '2a03:94e0:1407', additional_ips => []},
    {:ip => '185.125.168.5', :user => 'root', :password => 'Pace7403', :subnet => '2a03:94e0:1408', additional_ips => []},
    {:ip => '185.125.168.6', :user => 'root', :password => 'Urtk7623', :subnet => '2a03:94e0:1409', additional_ips => []},
    {:ip => '185.125.168.8', :user => 'root', :password => 'Cdkx2857', :subnet => '2a03:94e0:140a', additional_ips => []},
    {:ip => '185.125.168.9', :user => 'root', :password => 'Huwn4072', :subnet => '2a03:94e0:140b', additional_ips => []},
    {:ip => '185.125.168.11', :user => 'root', :password => 'Faeg2413', :subnet => '2a03:94e0:140c', additional_ips => []},
    {:ip => '185.125.168.12', :user => 'root', :password => 'Gnxk4699', :subnet => '2a03:94e0:140d', additional_ips => []},
    {:ip => '185.125.168.14', :user => 'root', :password => 'Tdfa8254', :subnet => '2a03:94e0:1411', additional_ips => []},
    {:ip => '185.125.168.15', :user => 'root', :password => 'Zunq2163', :subnet => '2a03:94e0:1412', additional_ips => []},
    {:ip => '185.125.168.16', :user => 'root', :password => 'Ktdp3031', :subnet => '2a03:94e0:1414', additional_ips => []},
=end
    {:ip => '185.125.168.17', :user => 'root', :password => 'Vfhu9258', :subnet => '2a03:94e0:1415', additional_ips => []},
    {:ip => '185.125.168.18', :user => 'root', :password => 'Bexc5807', :subnet => '2a03:94e0:1416', additional_ips => []},
    {:ip => '185.125.168.19', :user => 'root', :password => 'Pcse6634', :subnet => '2a03:94e0:1418', additional_ips => []},
    {:ip => '185.125.168.13', :user => 'root', :password => 'Xqjp2759', :subnet => '2a03:94e0:1410', additional_ips => []},
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
#    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c 'ufw disable'") # use this line of the use has not root privileges.
    stdout = ssh.exec!("ufw disable")
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
#    stdout = ssh.exec!("echo '#{h[:password].gsub("'", "\\'")}' | sudo -S su root -c './ipv4.install.2.sh #{user} #{pass}'") # use this line of the use has not root privileges.
    stdout = ssh.exec!("./ipv4.install.2.sh #{user} #{pass}")
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
