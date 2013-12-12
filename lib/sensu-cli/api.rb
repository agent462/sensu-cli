require 'net/https'
require 'json'
require 'rainbow'

module SensuCli
  class Api

    def request(opts)
      http = Net::HTTP.new(opts[:host], opts[:port])
      http.read_timeout = opts[:read_timeout]
      http.open_timeout = opts[:open_timeout]
      if opts[:ssl]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      proxy_header = { 'api-proxy' => 'true' }
      case opts[:method]
      when 'Get'
        req =  Net::HTTP::Get.new(opts[:path], initheader = proxy_header)
      when 'Delete'
        req =  Net::HTTP::Delete.new(opts[:path], initheader = proxy_header)
      when 'Post'
        req =  Net::HTTP::Post.new(opts[:path], initheader = proxy_header.merge!({ 'Content-Type' => 'application/json' }))
        req.body = opts[:payload]
      end
      req.basic_auth(opts[:user], opts[:password]) if opts[:user] && opts[:password]
      begin
        http.request(req)
      rescue Timeout::Error
        puts 'HTTP request has timed out.'.color(:red)
        exit
      rescue StandardError => e
        puts "An HTTP error occurred.  Check your settings. #{e}".color(:red)
        exit
      end
    end

    def response(code, body, command = nil)
      case code
      when '200'
        JSON.parse(body)
      when '201'
        puts 'The stash has been created.' if command == 'stashes' || command == 'silence'
      when '202'
        puts 'The item was submitted for processing.'
      when '204'
        puts 'Sensu is healthy' if command == 'health'
        puts 'The item was successfully deleted.' if command == 'aggregates' || command == 'stashes'
      when '400'
        puts 'The payload is malformed.'.color(:red)
      when '401'
        puts 'The request requires user authentication.'.color(:red)
      when '404'
        puts 'The item did not exist.'.color(:cyan)
      else
        if command == 'health'
          puts 'Sensu is not healthy.'.color(:red)
        else
          puts "There was an error while trying to complete your request. Response code: #{code}".color(:red)
        end
      end
    end

  end
end
