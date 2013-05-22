require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'net/https'
require 'json'
require 'sensu-cli/settings'
require 'sensu-cli/cli'
require 'sensu-cli/editor'
require 'sensu-cli/pretty'
require 'sensu-cli/path.rb'
require 'rainbow'

module SensuCli
  class Base

    def setup
      clis = Cli.new
      cli = clis.global
      settings
      @command = cli[:command]
      api_path(cli)
      make_call
    end

    def settings
      directory = "#{Dir.home}/.sensu"
      file = "#{directory}/settings.rb"
      alt = "/etc/sensu/sensu-cli/settings.rb"
      settings = Settings.new
      if settings.is_file?(file)
        SensuCli::Config.from_file(file)
      elsif settings.is_file?(alt)
        SensuCli::Config.from_file(alt)
      else
        settings.create(directory,file)
      end
    end

    def api_path(cli)
      p = PathCreator.new
      p.respond_to?(@command) ? path = p.send(@command, cli) : (puts "Something Bad Happened";exit)
      @api = {:path => path[:path], :method => cli[:method], :command => cli[:command], :payload => (path[:payload] || false)}
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
        req =  Net::HTTP::Post.new(@api[:path],initheader = {'Content-Type' => 'application/json'})
        req.body = @api[:payload]
      end
      req.basic_auth(Config.user, Config.password) if Config.user && Config.password
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

    def make_call
      res = http_request
      msg = response_codes(res.code,res.body)
      res.code != '200' ? exit : Pretty.print(msg)
      Pretty.count(msg)
    end

    def response_codes(code,body)
      case code
      when '200'
        JSON.parse(body)
      when '201'
        puts "The stash has been created." if @command == "stashes" || @command == "silence"
      when '202'
        puts "The item was submitted for processing."
      when '204'
        puts "Sensu is healthy" if @command == 'health'
        puts "The item was successfully deleted." if @command == 'aggregates' || @command == 'stashes'
      when '400'
        puts "The payload is malformed.".color(:red)
      when '401'
        puts "The request requires user authentication.".color(:red)
      when '404'
        puts "The item did not exist.".color(:cyan)
      else
        (@command == 'health') ? (puts "Sensu is not healthy.".color(:red)) : (puts "There was an error while trying to complete your request. Response code: #{code}".color(:red))
      end
    end

  end
end
