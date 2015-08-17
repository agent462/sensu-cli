require 'json'
# require 'rainbow/ext/string'
require 'rest-client'

module SensuCli
  module Client
    class Http
      attr_accessor :opts, :output, :response
      # opts[:proxy_address],
      # opts[:proxy_port])

      def http_request(opts)
        self.response = RestClient::Request.new(
          :method => opts[:method],
          :proxy => "#{opts[:proxy_address]}:#{opts[:port]}",
          :user => opts[:user],
          :password => opts[:password],
          :url => opts[:path].to_s,
          :headers => { 'api-proxy' => 'true' },
          :payload => opts[:payload],
          :timeout => 10,
          :open_timeout => 10,
          :veryify_ssl => OpenSSL::SSL::VERIFY_NONE # add config option to disable
        ).execute
        self.output = JSON.parse(response)
        rescue => e
          SensuCli::die(1, "An HTTP error occurred.  Check your settings. #{e}".color(:red))
      end
    end
  end
end
