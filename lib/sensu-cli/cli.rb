require 'trollop'

module SensuCli
  class Cli
    SUB_COMMANDS = %w(info client check event stash aggregate silence resolve)
    CLIENT_COMMANDS = %w(list show delete history)
    CHECK_COMMANDS = %w(list show request)
    EVENT_COMMANDS = %w(list show delete)
    STASH_COMMANDS = %w(list show delete)
    AGG_COMMANDS = %w(list show)
    SIL_COMMANDS = ""
    RES_COMMANDS = ""
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
          sensu check show CHECK\n\r
        EOS
        #sensu check request CHECK SUBSCRIBERS\n\r
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
        #sensu stash create
        #apost '/stashes'
    AGG_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Aggregate Commands **
          sensu aggregate list
          sensu aggregate show CHECK\n\r
        EOS
        #sensu aggregate delete CHECK\n\r
        #aget %r{/aggregates?/([\w\.-]+)/([\w\.-]+)$} do |check_name, check_issued|
    SIL_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Silence Commands **
          sensu silence NODE (OPTIONS)\n\r
        EOS
    RES_BANNER = <<-EOS.gsub(/^ {10}/, '')
          ** Resolve Commands **
          sensu resolve NODE CHECK\n\r
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
        global_opts.parse ARGV
        raise Trollop::HelpNeeded if ARGV.empty? # show help screen
      end

      cmd = ARGV.shift
      @command = ARGV.shift
      self.respond_to?(cmd) ? send(cmd) : explode(global_opts)
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

    def is_list(opts)
      explode(opts) if ARGV.empty? && @command != 'list'
    end

    def client
      opts = parser("CLIENT")
      is_list(opts)
      p = Trollop::options
      item = ARGV.shift #the ARGV.shift needs to happen after Trollop::options to catch --help
      case @command
      when 'list'
        cli = {:command => 'clients', :method => 'Get', :fields => p}
      when 'delete'
        deep_merge({:command => 'clients', :method => 'Delete', :fields => {:name => item}},{:fields => p})
      when 'show'
        deep_merge({:command => 'clients', :method => 'Get', :fields => {:name => item}},{:fields => p})
      when 'history'
        deep_merge({:command => 'clients', :method => 'Get', :fields => {:name => item, :history => true}},{:fields => p})
      else
        explode(opts)
      end
    end

    def info
      parser("INFO")
      cli = {:command => 'info', :method => 'Get'}
    end

    def check
      opts = parser("CHECK")
      is_list(opts)
      p = Trollop::options
      item = ARGV.shift
      case @command
      when 'list'
        cli = {:command => 'checks', :method => 'Get', :fields => p}
      when 'show'
        deep_merge({:command => 'checks', :method => 'Get', :fields => {:name => item}},{:fields => p})
      when 'request'
      else
        explode(opts)
      end
    end

    def event
      opts = parser("EVENT")
      is_list(opts)
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
        explode(opts) if check == nil
        deep_merge({:command => 'events', :method => 'Delete', :fields => {:client => item, :check => check}},{:fields => p})
      else
        explode(opts)
      end
    end

    def stash
      opts = parser("STASH")
      is_list(opts)
      p = Trollop::options
      item = ARGV.shift
      case @command
      when 'list'
        cli = {:command => 'stashes', :method => 'Get', :fields => p}
      when 'show'
        deep_merge({:command => 'stashes', :method => 'Get', :fields => {:path => item}},{:fields => p})
      when 'delete'
        deep_merge({:command => 'stashes', :method => 'Delete', :fields => {:path => item}},{:fields => p})
      else
        explode(opts)
      end
    end

    def aggregate
      opts = parser("AGG")
      is_list(opts)
      p = Trollop::options
      item = ARGV.shift
      case @command
      when 'list'
        cli = {:command => 'aggregates', :method => 'Get', :fields => p}
      when 'show'
        deep_merge({:command => 'aggregates', :method => 'Get', :fields => {:check => item}},{:fields => p})
      when 'delete'
        deep_merge({:command => 'aggregates', :method => 'Delete', :fields => {:check => item}},{:fields => p})
      else
        explode(opts)
      end
    end

    def silence
      opts = parser("SIL")
      explode(opts) if @command == nil || @command == "--help"
      p = Trollop::options do
        opt :check, "The check to silence (requires --client)", :short => 'k', :type => :string
      end
      deep_merge({:command => 'silence', :method => 'Post', :fields => {:client => @command}},{:fields => p})
    end

    def resolve
      opts = parser("RES")
      p = Trollop::options
      ARGV.empty? ? explode(opts) : (check = ARGV.shift)
      deep_merge({:command => 'resolve', :method => 'Post', :fields => {:client => @command, :check => check}},{:fields => p})
    end

  end
end
