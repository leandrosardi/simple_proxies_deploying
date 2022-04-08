
# TODO: move all the modules and classes regarding proxies from stealth_browser_automation to simple_proxies_deploying
# TODO: make stealth_browser_automation and extension of simple_proxies_deploying

module BlackStack
    module BaseProxy
      ##
      # creates new connection to google.com using +Faraday+ lib. Uses CGI::Cookie class
      # to parse the cookie returned in the response. It then checks for the presense of
      # "NID" cookie set by Google. If the cookie exists, proxy server is working just fine.
      #
      # references: 
      # - https://github.com/apoorvparijat/proxy-test
      # - https://github.com/lostisland/faraday
      # 
      ##
      # creates new connection to google.com using +Faraday+ lib. Uses CGI::Cookie class
      # to parse the cookie returned in the response. It then checks for the presense of
      # "NID" cookie set by Google. If the cookie exists, proxy server is working just fine.
      #
      # references: 
      # - https://github.com/apoorvparijat/proxy-test
      # - https://github.com/lostisland/faraday
      # 
      def self.test2(proxy_str, max_retries=3)
        try = 0
        while true
          print '.'
          try+=1
          begin
            f = Faraday.new(:proxy => { :uri => "http://" + proxy_str})
            response = f.get "http://www.google.com"
            cookie = CGI::Cookie.parse(response.headers["set-cookie"])
            if cookie["NID"].empty?
              raise SimpleProxiesDeployingException.new(50, proxy_str)
            else
              return true
            end
          rescue => e
            raise e if try > max_retries #SimpleProxiesDeployingException.new(51, "#{proxy_str}: #{e.to_s}")
          end
        end while true
      end # def self.test(proxy_str)
    end # module BaseProxy
end # module BlackStack