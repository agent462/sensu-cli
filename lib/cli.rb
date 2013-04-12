require 'trollop'

module SensuCli
  class Cli
    SUB_COMMANDS = %w(info client check event stash aggregate silence resolve)
    CLIENT_COMMANDS = %w(list show delete history)
    CHECK_COMMANDS = %w(list show request)
    EVENT_COMMANDS = %w(list show delete)
    STASH_COMMANDS = %w(list show delete)
    AGG_COMMANDS = %w(list show)
    SIL_COMMANDS = %w(client)
    RES_COMMANDS = %w(client)
    INFO_COMMANDS = ""

    CLIENT_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Client Commands **
          sensu client list
          sensu client show NODE
          sensu client delete NODE
          sensu client history NODE\n\r
        EOS
    INFO_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Info Commands **
          sensu info\n\r
        EOS
    CHECK_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Check Commands **
          sensu check list
          sensu check show CHECK
          sensu check request\n\r
        EOS
    EVENT_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Event Commands **
          sensu event list
          sensu event show NODE (OPTIONS)
          sensu event delete NODE CHECK\n\r
        EOS
    STASH_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Stash Commands **
          sensu stash list
          sensu stash show STASHPATH
          sensu stash delete STASHPATH\n\r
        EOS
    AGG_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Aggregate Commands **
          sensu aggregate list
          sensu aggregate show CHECK
          sensu aggregate delete CHECK\n\r
        EOS
    SIL_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Silence Commands **
          sensu silence client (OPTIONS)\n\r
        EOS
    RES_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Resolve Commands **
          sensu resolve client check\n\r
        EOS
    def global
      global_opts = Trollop::Parser.new do
        version "Sensu CLI 0.0.3"
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
          #          SENSU
          #
        EOS
        banner "\n\rAvailable subcommands: (for details, sensu SUB-COMMAND --help)\n\r"
        banner AGG_BANNER
        banner CHECK_BANNER
        banner CLIENT_BANNER
        banner EVENT_BANNER
        banner INFO_BANNER
        banner SIL_BANNER
        banner STASH_BANNER
        banner RES_BANNER
        stop_on SUB_COMMANDS
      end

      opts = Trollop::with_standard_exception_handling global_opts do
        raise Trollop::HelpNeeded if ARGV.empty? # show help screen
        global_opts.parse ARGV
      end

      cmd = ARGV.shift
      @command = ARGV.shift
      #@item = ARGV.shift
      cmd_opts = case cmd
      when 'client'
        client
      when 'info'
        info
      when 'check'
        check
      when 'event'
        event
      when 'stash'
        stash
      when 'aggregate'
        agg
      when 'silence'
        silence
      when 'resolve'
        resolve
      else
        explode(global_opts)
      end
    end

    def explode(opts)
      explode = Trollop::with_standard_exception_handling opts do
        raise Trollop::HelpNeeded # show help screen
      end
    end

    def deep_merge(hash_one, hash_two)
      hash_one.merge(hash_two) {|key, hash_one_item, hash_two_item| deep_merge(hash_one_item, hash_two_item)}
    end

    def parser(cli)
      opts = Trollop::Parser.new do
        banner Cli.const_get("#{cli}_BANNER")
        stop_on Cli.const_get("#{cli}_COMMANDS")
      end
    end

    def is_list(item,opts)
      if item == nil && @command != 'list'
          explode(opts)
      end
    end

    def need_help
    end

    def client
      opts = parser("CLIENT")
      item = ARGV.shift
      is_list(item,opts)
      case @command
      when 'list'
        p = Trollop::options
        cli = {:command => 'clients', :method => 'Get', :fields => p}
      when 'delete'
        p = Trollop::options
        deep_merge({:command => 'clients', :method => 'Delete', :fields => {:name => item}},{:fields => p})
      when 'show'
        p = Trollop::options
        deep_merge({:command => 'clients', :method => 'Get', :fields => {:name => item}},{:fields => p})
      when 'history'
        p = Trollop::options
        deep_merge({:command => 'clients', :method => 'Get', :fields => {:name => item, :history => true}},{:fields => p})
      else
        explode(opts)
      end
    end

    def info
      opts = parser("INFO")
      cli = {:command => 'info', :method => 'Get'}
    end

    def check
      opts = parser("CHECK")
      item = ARGV.shift
      is_list(item,opts)
      case @command
      when 'list'
        p = Trollop::options
        cli = {:command => 'checks', :method => 'Get', :fields => p}
      when 'show'
        p = Trollop::options
        deep_merge({:command => 'checks', :method => 'Get', :fields => {:name => item}},{:fields => p})
      when 'request'
      else
        explode(opts)
      end
    end

    def event
      opts = parser("EVENT")
      #is_list(item,opts)
      case @command
      when 'list'
        p = Trollop::options
        cli = {:command => 'events', :method => 'Get', :fields => p}
      when 'show'
        p = Trollop::options do
          opt :check, "Returns the check associated with the client", :short => "k", :type => :string
        end
        item = ARGV.shift
        deep_merge({:command => 'events', :method => 'Get', :fields => {:client => item}},{:fields => p})
      when 'delete'
        p = Trollop::options
        item = ARGV.shift
        check = ARGV.shift
        if check  == nil
          explode(opts)
        end
        deep_merge({:command => 'events', :method => 'Delete', :fields => {:client => item, :check => check}},{:fields => p})
      else
        explode(opts)
      end
    end

    def stash
      opts = parser("STASH")
      item = ARGV.shift
      is_list(item,opts)
      case @command
      when 'list'
        p = Trollop::options
        cli = {:command => 'stashes', :method => 'Get', :fields => p}
      when 'show'
        p = Trollop::options
        deep_merge({:command => 'stashes', :method => 'Get', :fields => {:path => item}},{:fields => p})
      when 'delete'
        p = Trollop::options
        deep_merge({:command => 'stashes', :method => 'Delete', :fields => {:path => item}},{:fields => p})
      else
        explode(opts)
      end
    end

    def agg
      opts = parser("AGG")
      item = ARGV.shift
      is_list(item,opts)
      case @command
      when 'list'
        p = Trollop::options
        cli = {:command => 'aggregates', :method => 'Get', :fields => p}
      when 'show'
        p = Trollop::options
        deep_merge({:command => 'aggregates', :method => 'Get', :fields => {:check => item}},{:fields => p})
      when 'delete'
        p = Trollop::options
        deep_merge({:command => 'aggregates', :method => 'Delete', :fields => {:check => item}},{:fields => p})
      else
        explode(opts)
      end
    end

    def silence
      opts = parser("SIL")
      item = ARGV.shift
      case @command
      when 'client'
        p = Trollop::options do
          opt :check, "The check to silence (requires --client)", :short => 'k', :type => :string
        end
        deep_merge({:command => 'silence', :method => 'Post', :fields => {:client => item}},{:fields => p})
      else
        explode(opts)
      end
    end

    def resolve
      opts = parser("RES")
      item = ARGV.shift
      case @command
      when 'client'
        p = Trollop::options
        check = ARGV.shift
        if check  == nil
          explode(opts)
        end
        deep_merge({:command => 'resolve', :method => 'Post', :fields => {:client => item, :check => check}},{:fields => p})
      else
        explode(opts)
      end
    end

  end
end
