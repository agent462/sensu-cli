require 'sensu-cli/client/http'
require 'sensu-cli/client/socket'

module SensuCli
  class Entry
    attr_accessor :cli, :format

    def setup
      settings
      self.cli = Cli.new.global
      process(send(cli[:command]))
    end

    def settings
      settings = SensuCli::Settings.new.determine
      Rainbow.enabled = Config.pretty_colors == false ? false : true
    end

    def aggregate
      require 'sensu-cli/commands/aggregate'
      SensuCli::Commands::Aggregate.new(cli[:subcommand], cli)
    end

    def check
      require 'sensu-cli/commands/check'
      SensuCli::Commands::Check.new(cli[:subcommand], cli)
    end

    def client
      require 'sensu-cli/commands/client'
      SensuCli::Commands::Client.new(cli[:subcommand], cli[:fields][:name])
    end

    def event
      require 'sensu-cli/commands/event'
      SensuCli::Commands::Event.new(cli[:subcommand], cli[:fields][:name])
    end

    def health
    end

    def info
      require 'sensu-cli/commands/info'
      SensuCli::Commands::Info.new(cli[:subcommand])
    end

    def resolve
      require 'sensu-cli/commands/resolve'
      SensuCli::Commands::Resolve.new(cli[:subcommand], cli)
    end

    def silence
      require 'sensu-cli/commands/silence'
      SensuCli::Commands::Silence.new(cli[:subcommand], cli)
    end

    def socket
      require 'sensu-cli/commands/socket'
      SensuCli::Commands::Socket.new(cli[:subcommand], cli)
    end

    def stash
      require 'sensu-cli/commands/stash'
      SensuCli::Commands::Stash.new(cli[:subcommand], cli)
    end

    def set_format_type
      case cli[:fields][:format]
      when 'json'
        self.format = :json
      when 'single'
        self.format = :single
      when 'table'
        self.format = :table
      else
        self.format = :print
      end
    end

    def process(command)
      set_format_type
      command.http_request( :path => "http://127.0.0.1:4567#{command.path}",
                            :method => command.request_method,
                            :payload => (command.payload if command.respond_to?(:payload))
      )
      command.format(format)
    end

    def method_missing(method_name, *_args)
      puts "Command: #{method_name} does not exist."
    end

  end
end
