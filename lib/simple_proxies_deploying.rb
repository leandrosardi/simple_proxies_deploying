require 'net/ssh'
require 'faraday'
require 'blackstack_commons'
require 'simple_cloud_logging'
require 'simple_command_line_parser'

# TODO: design the proxy server managment as an addon of SimpleHostMonitoring

# matching ipv6 addresses with standard notation (not compact. not mixed.)
MATCH_PORT_IN_3PROXY_CONF = /\-p[0-9][0-9][0-9][0-9]/ 

# Regular expressions to match IPv6 addresses in the 3proxy config file.
# reference: https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch08s17.html
#
# TODO: Research: which ipv6 notation use the 3cproxy configuration file? Is it standard or mixed or compresed?
#
MATCH_IPV6_STANDARD = /(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}/i 
MATCH_IPV6_64_SUBNET_STANDARD = /^[A-F0-9]{1,4}:[A-F0-9]{1,4}:[A-F0-9]{1,4}:[A-F0-9]{1,4}/i # TODO: this is not supporting leading zeros

# 
DEFAULT_PROXY_PORT_FROM = 4000
DEFAULT_PROXY_PORT_TO = 4499
DEFAULT_PROXY_PORTS_BATCH_SIZE = 50

# 
require_relative './simpleproxiesdeployingexception.rb'
require_relative './baseproxy.rb'
require_relative './remotehost.rb'