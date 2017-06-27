require 'trollop'
require 'sensu-cli/version'
require 'rainbow/ext/string'

module SensuCli
  class Cli # rubocop:disable ClassLength
    SUB_COMMANDS    = %w(info client check event stash aggregate silence resolve health socket)
    CLIENT_COMMANDS = %w(list show delete history)
    CHECK_COMMANDS  = %w(list show request)
    EVENT_COMMANDS  = %w(list show delete)
    STASH_COMMANDS  = %w(list show delete create)
    AGG_COMMANDS    = %w(list show delete)
    SIL_COMMANDS    = ''
    RES_COMMANDS    = ''
    INFO_COMMANDS   = ''
    HEALTH_COMMANDS = ''
    SOCKET_COMMANDS = %w(create raw)

    CLIENT_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Client Commands **
          sensu-cli client list (OPTIONS)
          sensu-cli client show NODE
          sensu-cli client delete NODE
          sensu-cli client history NODE\n\r
        EOS
    INFO_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Info Commands **
          sensu-cli info\n\r
        EOS
    HEALTH_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Health Commands **
          sensu-cli health (OPTIONS)\n\r
        EOS
    CHECK_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Check Commands **
          sensu-cli check list
          sensu-cli check show CHECK
          sensu-cli check request CHECK SUB1,SUB2\n\r
        EOS
    EVENT_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Event Commands **
          sensu-cli event list (OPTIONS)
          sensu-cli event show NODE (OPTIONS)
          sensu-cli event delete NODE CHECK\n\r
        EOS
    STASH_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Stash Commands **
          sensu-cli stash list (OPTIONS)
          sensu-cli stash show STASHPATH
          sensu-cli stash delete STASHPATH
          sensu-cli stash create PATH\n\r
        EOS
    AGG_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Aggregate Commands **
          sensu-cli aggregate list (OPTIONS)
          sensu-cli aggregate show CHECK (OPTIONS)
          sensu-cli aggregate delete CHECK\n\r
        EOS
    SIL_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Silence Commands **
          sensu-cli silence NODE (OPTIONS)\n\r
        EOS
    RES_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Resolve Commands **
          sensu-cli resolve NODE CHECK\n\r
        EOS
    SOCKET_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Socket Commands **
          sensu-cli socket create (OPTIONS)
          sensu-cli socket raw INPUT\n\r
        EOS
    def global
      global_opts = Trollop::Parser.new do
        version "sensu-cli version: #{SensuCli::VERSION}"
        banner <<-'EOS'.gsub(/^ {10}/, '')
          #
          # Welcome to the sensu-cli.
          #          ______
          #       .-'      '-.
          #     .'     __     '.
          #    /      /  \      \
          #    ------------------
          #            /\
          #           '--'
          #         SENSU-CLI
          #
        EOS
        banner "\n\rAvailable subcommands: (for details, sensu-cli SUB-COMMAND --help)\n\r"
        banner AGG_BANNER
        banner CHECK_BANNER
        banner CLIENT_BANNER
        banner EVENT_BANNER
        banner HEALTH_BANNER
        banner INFO_BANNER
        banner SIL_BANNER
        banner STASH_BANNER
        banner RES_BANNER
        banner SOCKET_BANNER
        stop_on SUB_COMMANDS
      end

      Trollop::with_standard_exception_handling global_opts do
        global_opts.parse ARGV
        raise Trollop::HelpNeeded if ARGV.empty? # show help screen
      end

      cmd = next_argv
      self.respond_to?(cmd) ? send(cmd) : explode(global_opts)
    end

    def explode(opts)
      Trollop::with_standard_exception_handling opts do
        raise Trollop::HelpNeeded # show help screen
      end
    end

    def deep_merge(hash_one, hash_two)
      hash_one.merge(hash_two) { |_key, hash_one_item, hash_two_item| deep_merge(hash_one_item, hash_two_item) }
    end

    def parser(cli)
      Trollop::Parser.new do
        banner Cli.const_get("#{cli}_BANNER")
        stop_on Cli.const_get("#{cli}_COMMANDS")
      end
    end

    def explode_if_empty(opts, command)
      explode(opts) if ARGV.empty? && command != 'list'
    end

    def next_argv
      ARGV.shift
    end

    def client # rubocop:disable MethodLength
      opts = parser('CLIENT')
      command = next_argv
      explode_if_empty(opts, command)
      case command
      when 'list'
        p = Trollop::options do
          opt :limit, 'The number if clients to return', :short => 'l', :type => :string
          opt :offset, 'The number of clients to offset before returning', :short => 'o', :type => :string
          opt :format, 'Available formats; single, table, json', :short => 'f', :type => :string
          opt :fields, 'Fields for table ouput: -F name,address,subscriptions', :short => 'F', :type => :string
          opt :filter, 'Field and value to filter on: name,graphite', :type => :string
        end
        Trollop::die :format, 'Available optional formats: single, table, json'.color(:red) if p[:format] != 'table' && p[:format] != 'single' && p[:format] != 'json' && p[:format]
        Trollop::die :fields, 'Fields must be used in conjunction with --format table'.color(:red) if p[:format] != 'table' && p[:fields]
        Trollop::die :offset, 'Offset depends on the limit option --limit ( -l )'.color(:red) if p[:offset] && !p[:limit]
        { :command => 'clients', :method => 'Get', :fields => p }
      when 'delete'
        p = Trollop::options
        item = next_argv # the ARGV.shift needs to happen after Trollop::options to catch --help
        deep_merge({ :command => 'clients', :method => 'Delete', :fields => { :name => item } }, { :fields => p })
      when 'show'
        p = Trollop::options
        item = next_argv
        deep_merge({ :command => 'clients', :method => 'Get', :fields => { :name => item } }, { :fields => p })
      when 'history'
        p = Trollop::options
        item = next_argv
        deep_merge({ :command => 'clients', :method => 'Get', :fields => { :name => item, :history => true } }, { :fields => p })
      else
        explode(opts)
      end
    end

    def info
      parser('INFO')
      p = Trollop::options
      { :command => 'info', :method => 'Get', :fields => p }
    end

    def health
      parser('HEALTH')
      p = Trollop::options do
        opt :consumers, 'The minimum number of consumers', :short => 'c', :type => :string, :required => true
        opt :messages, 'The maximum number of messages', :short => 'm', :type => :string, :required => true
      end
      { :command => 'health', :method => 'Get', :fields => p }
    end

    def check
      opts = parser('CHECK')
      command = next_argv
      explode_if_empty(opts, command)
      item = next_argv
      case command
      when 'list'
        p = Trollop::options do
          opt :filter, 'Field and value to filter on: command,procs', :type => :string
        end
        { :command => 'checks', :method => 'Get', :fields => p }
      when 'show'
        p = Trollop::options
        deep_merge({ :command => 'checks', :method => 'Get', :fields => { :name => item } }, { :fields => p })
      when 'request'
        p = Trollop::options
        ARGV.empty? ? explode(opts) : subscribers = next_argv.split(',')
        deep_merge({ :command => 'checks', :method => 'Post', :fields => { :check => item, :subscribers => subscribers } }, { :fields => p })
      else
        explode(opts)
      end
    end

    def event
      opts = parser('EVENT')
      command = next_argv
      explode_if_empty(opts, command)
      case command
      when 'list'
        p = Trollop::options do
          opt :filter, 'Field and value to filter on: client,graphite (use "name" as field for client or event name)', :type => :string
          opt :format, 'Available formats; single, table, json', :short => 'f', :type => :string
        end
        Trollop::die :format, 'Available optional formats: single, table, json'.color(:red) if p[:format] != 'table' && p[:format] != 'single' && p[:format] != 'json' && p[:format]
        { :command => 'events', :method => 'Get', :fields => p }
      when 'show'
        p = Trollop::options do
          opt :check, 'Returns the check associated with the client', :short => 'k', :type => :string
        end
        item = next_argv
        deep_merge({ :command => 'events', :method => 'Get', :fields => { :client => item } }, { :fields => p })
      when 'delete'
        p = Trollop::options
        item = next_argv
        check = next_argv
        explode(opts) if check.nil?
        deep_merge({ :command => 'events', :method => 'Delete', :fields => { :client => item, :check => check } }, { :fields => p })
      else
        explode(opts)
      end
    end

    def stash
      opts = parser('STASH')
      command = next_argv
      explode_if_empty(opts, command)
      case command
      when 'list'
        p = Trollop::options do
          opt :limit, 'The number of stashes to return', :short => 'l', :type => :string
          opt :offset, 'The number of stashes to offset before returning', :short => 'o', :type => :string
          opt :format, 'Available formats; single, table, json', :short => 'f', :type => :string
          opt :filter, 'Field and value to filter on: path,graphite', :type => :string
        end
        Trollop::die :offset, 'Offset depends on the limit option --limit ( -l )'.color(:red) if p[:offset] && !p[:limit]
        Trollop::die :format, 'Available optional formats: single, table, json'.color(:red) if p[:format] != 'table' && p[:format] != 'single' && p[:format] != 'json' && p[:format]
        { :command => 'stashes', :method => 'Get', :fields => p }
      when 'show'
        p = Trollop::options
        item = next_argv
        deep_merge({ :command => 'stashes', :method => 'Get', :fields => { :path => item } }, { :fields => p })
      when 'delete'
        p = Trollop::options
        item = next_argv
        deep_merge({ :command => 'stashes', :method => 'Delete', :fields => { :path => item } }, { :fields => p })
      when 'create'
        p = Trollop::options
        item = next_argv
        deep_merge({ :command => 'stashes', :method => 'Post', :fields => { :create => true, :create_path => item } }, { :fields => p })
      else
        explode(opts)
      end
    end

    def aggregate
      opts = parser('AGG')
      command = next_argv
      explode_if_empty(opts, command)
      case command
      when 'list'
        p = Trollop::options do
          opt :filter, 'Field and value to filter on: issued,1399505890', :type => :string
        end
        { :command => 'aggregates', :method => 'Get', :fields => p }
      when 'show'
        p = Trollop::options do
          opt :id, 'The id of the check issued.', :short => 'i', :type => :integer
          opt :limit, 'The number of aggregates to return', :short => 'l', :type => :string
          opt :offset, 'The number of aggregates to offset before returning', :short => 'o', :type => :string
          # opt :results, 'Include the check results', :short => 'r', :type => :boolean
        end
        Trollop::die :offset, 'Offset depends on the limit option --limit ( -l )'.color(:red) if p[:offset] && !p[:limit]
        item = next_argv
        deep_merge({ :command => 'aggregates', :method => 'Get', :fields => { :check => item } }, { :fields => p })
      when 'delete'
        p = Trollop::options
        item = next_argv
        deep_merge({ :command => 'aggregates', :method => 'Delete', :fields => { :check => item } }, { :fields => p })
      else
        explode(opts)
      end
    end

    def silence
      opts = parser('SIL')
      p = Trollop::options do
        opt :check, 'The check to silence', :short => 'k', :type => :string
        opt :owner, 'The owner of the stash', :short => 'o', :type => :string
        opt :reason, 'The reason this check/node is being silenced', :short => 'r', :type => :string
        opt :expire, 'The number of seconds the silenced event is valid', :short => 'e', :type => :integer
        opt :source, 'The name of the source of the silence', :short => 's', :type => :string, :default => 'sensu-cli'
      end
      command = next_argv
      explode(opts) if command.nil?
      deep_merge({ :command => 'silence', :method => 'Post', :fields => { :client => command } }, { :fields => p })
    end

    def resolve
      opts = parser('RES')
      command = next_argv
      p = Trollop::options
      ARGV.empty? ? explode(opts) : check = next_argv
      deep_merge({ :command => 'resolve', :method => 'Post', :fields => { :client => command, :check => check } }, { :fields => p })
    end

    def socket
      opts = parser('SOCKET')
      command = next_argv
      explode_if_empty(opts, command)
      case command
      when 'create'
        p = Trollop::options do
          opt :name, 'The check name to report as', :short => 'n', :type => :string, :required => true
          opt :output, 'The check result output', :short => 'o', :type => :string, :required => true
          opt :status, 'The check result exit status to indicate severity.', :short => 's', :type => :integer
          # opt :handlers, 'The check result handlers.', :type => :string
        end
        { :command => 'socket', :method => 'create', :fields => p }
      when 'raw'
        p = Trollop::options
        { :command => 'socket', :method => 'raw', :raw => next_argv }
      else
        explode(opts)
      end
    end
  end
end
