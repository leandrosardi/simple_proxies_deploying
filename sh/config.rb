require 'net/ssh'

PORT = 4000
USER = 'leandros'
PASS = 'SantaClara123'

SERVERS = [
#    {:ip => '185.14.97.236', :user => 'root', :password => 'Zwmp7597', :subnet => '2a03:94e0:2691', :additional_ips => []},
    {:ip => '185.14.97.237', :user => 'root', :password => 'Hqsj1323', :subnet => '2a03:94e0:2697', :additional_ips => []},
    {:ip => '185.14.97.239', :user => 'root', :password => 'Trwq6058', :subnet => '2a03:94e0:26a5', :additional_ips => []},
    {:ip => '194.32.107.203', :user => 'root', :password => 'Jymd9533', :subnet => '2a03:94e0:27b5', :additional_ips => []},
=begin
    {:ip => '185.125.168.3', :user => 'root', :password => 'Guyv1903', :subnet => '2a03:94e0:1406', :additional_ips => []},
    {:ip => '185.125.168.4', :user => 'root', :password => 'Xgqy8874', :subnet => '2a03:94e0:1407', :additional_ips => []},
    {:ip => '185.125.168.5', :user => 'root', :password => 'Pace7403', :subnet => '2a03:94e0:1408', :additional_ips => []},
    {:ip => '185.125.168.6', :user => 'root', :password => 'Urtk7623', :subnet => '2a03:94e0:1409', :additional_ips => []},
    {:ip => '185.125.168.8', :user => 'root', :password => 'Cdkx2857', :subnet => '2a03:94e0:140a', :additional_ips => []},
    {:ip => '185.125.168.9', :user => 'root', :password => 'Huwn4072', :subnet => '2a03:94e0:140b', :additional_ips => []},
    {:ip => '185.125.168.11', :user => 'root', :password => 'Faeg2413', :subnet => '2a03:94e0:140c', :additional_ips => []},
    {:ip => '185.125.168.12', :user => 'root', :password => 'Gnxk4699', :subnet => '2a03:94e0:140d', :additional_ips => []},
    {:ip => '185.125.168.14', :user => 'root', :password => 'Tdfa8254', :subnet => '2a03:94e0:1411', :additional_ips => []},
    {:ip => '185.125.168.15', :user => 'root', :password => 'Zunq2163', :subnet => '2a03:94e0:1412', :additional_ips => []},
    {:ip => '185.125.168.16', :user => 'root', :password => 'Ktdp3031', :subnet => '2a03:94e0:1414', :additional_ips => []},
=end
    {:ip => '185.125.168.17', :user => 'root', :password => 'Vfhu9258', :subnet => '2a03:94e0:1415', :additional_ips => []},
    {:ip => '185.125.168.18', :user => 'root', :password => 'Bexc5807', :subnet => '2a03:94e0:1416', :additional_ips => []},
    {:ip => '185.125.168.19', :user => 'root', :password => 'Pcse6634', :subnet => '2a03:94e0:1418', :additional_ips => []},
    {:ip => '185.125.168.13', :user => 'root', :password => 'Xqjp2759', :subnet => '2a03:94e0:1410', :additional_ips => []},
]
