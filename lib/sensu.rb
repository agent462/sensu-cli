require 'rubygems' if RUBY_VERSION < '1.9.0'
require "net/https"
require 'json'
require 'settings'
require 'cli'
require 'rainbow'

module SensuCli
  class Core
    #
    # CLI can be anything assuming you can pass these paramaters
    # Field names were derived from the sensu source/documentation.
    # cli = {
    #   :command => 'client',
    #   :method => 'Get',
    #   :flags => {:name => 'ntp-check',
    #              :path => '/keepalive/i-asesew',
    #              :client => 'i-23412412',
    #              :check => 'ntp-check'}
    # }

    def initialize
      clis = Cli.new
      cli = clis.global
      puts cli.inspect
      directory = "#{Dir.home}/.sensu"
      file = "#{directory}/settings.rb"
      Settings.check_settings(directory,file)
      SensuCli::Config.from_file(file)
      request(cli)
    end

    def request(cli)
      case cli[:command]
      when 'clients'
        path = "/clients" << (cli[:fields][:name] ? "/#{cli[:fields][:name]}" : "") << (cli[:fields][:history] ? "/history" : "")
      when 'info'
        path = "/info"
      when 'stashes'
        path = "/stashes" << (cli[:fields][:path] ? "/#{cli[:fields][:path]}" : "")
      when 'checks'
        cli[:fields][:name] ? (path = "/check/#{cli[:fields][:name]}" << (cli[:fields][:check] ? "/#{cli[:fields][:check]}" : "")) : (path = "/checks")
      when 'events'
        path = "/events"
        cli[:fields][:client] ? path << "/#{cli[:fields][:client]}" : ""
        cli[:fields][:check] ? path << "/#{cli[:fields][:check]}" : ""
      when 'resolve'
        payload = {:client => cli[:fields][:client], :check => cli[:fields][:check]}.to_json
        path = "/event/resolve"
      when 'silence'
        payload = {:timestamp => Time.now.to_i}.to_json
        path = "/stashes/silence"
        cli[:fields][:client] ? path << "/#{cli[:fields][:client]}" : ""
        cli[:fields][:check] ? path << "/#{cli[:fields][:check]}" : ""
      when 'aggregates'
        path = "/aggregates" << (cli[:fields][:check] ? "/#{cli[:fields][:check]}" : "")
      end
      @api = {:path => path, :method => cli[:method], :command => cli[:command], :payload => (payload || nil)}
      api
    end

    def http_request
      http = Net::HTTP.new(Config.host, Config.port)
      http.read_timeout = 15
      http.open_timeout = 5
      if Config.ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      case @api[:method]
      when 'Get'
        req =  Net::HTTP::Get.new(@api[:path])
      when 'Delete'
        req =  Net::HTTP::Delete.new(@api[:path])
      when 'Post'
        req =  Net::HTTP::Post.new(@api[:path],initheader = {'Content-Type' =>'application/json'})
        req.body = @api[:payload]
      end
      begin
        http.request(req)
      rescue Timeout::Error
        puts "HTTP request has timed out.".color(:red)
        exit
      rescue StandardError => e
        puts "An HTTP error occurred.  Check your settings. #{e}".color(:red)
        exit
      end
    end

    def api
      res = http_request
      msg = response_codes(res)
      if res.code != '200'
        exit
      else
        pretty(msg)
      end
    end

    def response_codes(res)
      case res.code
      when '200'
        JSON.parse(res.body)
      when '201'
        puts "The stash has been created."
      when '202'
        puts "The item was submitted for processing."
      when '204'
        puts "The item was successfully deleted."
      when '400'
        puts "The payload is malformed".color(:red)
      when '404'
        puts "The #{@api[:command]} did not exist".color(:cyan)
      else
        puts "There was an error while trying to complete your request. Response code: #{res.code}".color(:red)
      end
    end

    def pretty(res)
      if !res.empty?
        if res.is_a?(Hash)
          res.each do |key,value|
            puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
          end
        elsif res.is_a?(Array)
          res.each do |item|
            puts "-------".color(:yellow)
            if item.is_a?(Hash)
              item.each do |key,value|
                puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
              end
            else
              puts item.color(:cyan)
            end
          end
        end
      else
        puts "no values for this request".color(:cyan)
      end
    end

  end
end
