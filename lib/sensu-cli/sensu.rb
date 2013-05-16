require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'net/https'
require 'json'
require 'sensu-cli/settings'
require 'sensu-cli/cli'
require 'sensu-cli/editor'
require 'rainbow'

module SensuCli
  class Core

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
      self.respond_to?(@command) ? path = send(@command, cli) : (puts "Something Bad Happened";exit)
      @api = {:path => path, :method => cli[:method], :command => cli[:command], :payload => (@payload || false)}
    end

    def clients(cli)
      path = "/clients"
      path << "/#{cli[:fields][:name]}" if cli[:fields][:name]
      path << "/history" if cli[:fields][:history]
      path << pagination(cli)
    end

    def info(cli)
      path = "/info"
    end

    def health(cli)
      path = "/health?consumers=#{cli[:fields][:consumers]}&messages=#{cli[:fields][:messages]}"
    end

    def stashes(cli)
      if cli[:fields][:create]
        e = Editor.new
        @payload = e.create_stash(cli[:fields][:create_path]).to_json
      end
      path = "/stashes"
      path << "/#{cli[:fields][:path]}" if cli[:fields][:path]
      path << pagination(cli)
    end

    def checks(cli)
      if cli[:fields][:name]
        path = "/check/#{cli[:fields][:name]}"
      elsif cli[:fields][:subscribers]
        @payload = {:check => cli[:fields][:check],:subscribers => cli[:fields][:subscribers]}.to_json
        path = "/check/request"
      else
        path = "/checks"
      end
    end

    def events(cli)
      path = "/events"
      path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      path
    end

    def resolve(cli)
      @payload = {:client => cli[:fields][:client], :check => cli[:fields][:check]}.to_json
      path = "/event/resolve"
    end

    def silence(cli)
      payload = {:timestamp => Time.now.to_i}
      payload.merge!({:reason => cli[:fields][:reason]}) if cli[:fields][:reason]
      if cli[:fields][:expires]
        expires = Time.now.to_i + (cli[:fields][:expires] * 60)
        payload.merge!({:expires => expires})
      end
      @payload = payload.to_json
      path = "/stashes/silence"
      path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      path
    end

    def aggregates(cli)
      path = "/aggregates"
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      path << "/#{cli[:fields][:id]}" if cli[:fields][:id]
      path << pagination(cli)
    end

    def pagination(cli)
      if cli[:fields].has_key?(:limit) && cli[:fields].has_key?(:offset)
        page = "?limit=#{cli[:fields][:limit]}&offset=#{cli[:fields][:offset]}"
      elsif cli[:fields].has_key?(:limit)
        page = "?limit=#{cli[:fields][:limit]}"
      else
        page = ""
      end
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
      res.code != '200' ? exit : pretty(msg)
      count(msg)
    end

    def response_codes(code,body)
      case code
      when '200'
        JSON.parse(body)
      when '201'
        puts "The stash has been created." if @command == "stashes"
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
              puts item.to_s.color(:cyan)
            end
          end
        end
      else
        puts "no values for this request".color(:cyan)
      end
    end

    def count(res)
      res.is_a?(Hash) ? count = res.length : count = res.count
      puts "#{count} total items".color(:yellow) if count
    end

  end
end
