Gem::Specification.new do |s|
  s.name        = 'simple_proxies_deploying'
  s.version     = '1.1.2'
  s.date        = '2022-04-04'
  s.summary     = "Install, monitor, and check configurations of proxy servers."
  s.description = "Find documentation here: https://github.com/leandrosardi/simple_proxies_deploying."
  s.authors     = ["Leandro Daniel Sardi"]
  s.email       = 'leandro.sardi@expandedventure.com'
  s.files       = [
    "lib/simple_proxies_deploying.rb",
    "lib/remotehost.rb",
    "lib/simpleproxiesdeployingexception.rb",
  ]
  s.homepage    = 'https://rubygems.org/gems/simple_proxies_deploying'
  s.license     = 'MIT'
  s.add_runtime_dependency 'net-ssh', '~> 4.1.0', '>= 4.1.0'
  s.add_runtime_dependency 'faraday', '~> 0.9.2', '>= 0.9.2'
  s.add_runtime_dependency 'websocket', '~> 1.2.8', '>= 1.2.8'
  s.add_runtime_dependency 'json', '~> 1.8.1', '>= 1.8.1'
  s.add_runtime_dependency 'blackstack_commons', '~> 1.1.50', '>= 1.1.50'
  s.add_runtime_dependency 'simple_command_line_parser', '~> 1.1.2', '>= 1.1.2'
  s.add_runtime_dependency 'simple_cloud_logging', '~> 1.1.28', '>= 1.1.28'
end
