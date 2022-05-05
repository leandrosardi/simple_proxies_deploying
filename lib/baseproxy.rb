
# TODO: move all the modules and classes regarding proxies from stealth_browser_automation to simple_proxies_deploying
# TODO: make stealth_browser_automation and extension of simple_proxies_deploying

module BlackStack
    module BaseProxy

      # 
      # Create a new connectio to `whatismyip.akamai.com` and grab the external IP address of the proxy.
      # Raise an exception of I receive a `502 Bad Gateway` in the response
      # 
      # references: 
      # - https://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html#method-c-Proxy
      # - https://stackoverflow.com/questions/10043046/ruby-proxy-authentication-get-post-with-openuri-or-net-http
      def self.test(net_remote_ip, port, username=null, password=null, max_retries=3)
        url = 'ipv6.icanhazip.com/'
        #url = 'whatismyip.akamai.com'
        try = 0
        while true
          print '.'
          try+=1
          begin
            Net::HTTP::Proxy(net_remote_ip, port, username, password).start(url) do |http|
              res = http.get('/').body
              if res =~ /502 Bad Gateway/
                  raise SimpleProxiesDeployingException.new(50, "#{net_remote_ip}:#{port}@#{username}:#{password}")
              else
                  return true
              end
            end   
          rescue => e
            raise e if try > max_retries #SimpleProxiesDeployingException.new(51, "#{proxy_str}: #{e.to_s}")
          end
        end while true
      end # def test


      #
      # creates new connection to google.com using +Faraday+ lib. Uses CGI::Cookie class
      # to parse the cookie returned in the response. It then checks for the presense of
      # "NID" cookie set by Google. If the cookie exists, proxy server is working just fine.
      #
      # references: 
      # - https://github.com/apoorvparijat/proxy-test
      # - https://github.com/lostisland/faraday
      # 
      def self.test2(proxy_str, max_retries=3)
        f = Faraday.new(:proxy => { :uri => "http://" + proxy_str})
        res = f.get "http://api64.ipify.org?format=json"
        parsed = JSON.parse(res.body)
        if parsed.has_key?('ip')
          return true
          # TODO: push the ip address to the database, in order to trace if any external IP changed.
        else
          raise 'no ip found in response from ipify.org.'
        end
      end # def self.test2(proxy_str)
    end # module BaseProxy
end # module BlackStack