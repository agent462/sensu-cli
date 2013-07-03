module SensuCli
  class Base

    def setup
      clis = Cli.new
      cli = clis.global
      @format = cli[:fields][:format] || 'long'
      settings
      api_path(cli)
      make_call
    end

    def settings
      directory = "#{Dir.home}/.sensu"
      file = "#{directory}/settings.rb"
      alt = '/etc/sensu/sensu-cli/settings.rb'
      settings = Settings.new
      if settings.is_file?(file)
        SensuCli::Config.from_file(file)
      elsif settings.is_file?(alt)
        SensuCli::Config.from_file(alt)
      else
        settings.create(directory, file)
      end
    end

    def api_path(cli)
      p = PathCreator.new
      p.respond_to?(cli[:command]) ? path = p.send(cli[:command], cli) : (puts 'Something Bad Happened'; exit)
      @api = { :path => path[:path], :method => cli[:method], :command => cli[:command], :payload => (path[:payload] || false) }
    end

    def make_call
      opts = {
        :path => @api[:path],
        :method => @api[:method],
        :payload => @api[:payload],
        :host => Config.host,
        :port => Config.port,
        :ssl => Config.ssl || false,
        :user => Config.user || nil,
        :password => Config.password || nil
      }
      api = Api.new
      res = api.request(opts)
      msg = api.response(res.code, res.body, @api[:command])
      if res.code != '200'
        exit
      elsif @format == 'single'
        Pretty.table(msg)
      else
        Pretty.print(msg)
      end
      Pretty.count(msg)
    end

  end
end
