require 'trollop'
require 'rainbow'

module SensuCli
  class Cli

    SUB_COMMANDS = %w(info clients checks events stashes)

    def self.opts

      global_opts = Trollop::Parser.new do
        version "Sensu CLI 0.0.1"
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
        banner <<-EOS.gsub(/^ {10}/, '')
          Available subcommands: (for details, sensu SUB-COMMAND --help)

          ** Sensu Commands **
          sensu clients (options)\r
          sensu checks (options)\r
          sensu stash (options)\r
          sensu info (options)\r
          sensu events (options)\r
          sensu stashes (options)\r

        EOS
        banner <<-EOS.gsub(/^ {10}/, '').color(:cyan)

          Example Usage: sensu clients --name NODE
          For help use: sensu SUB-COMMAND --help
        EOS
        stop_on SUB_COMMANDS
      end

      opts = Trollop::with_standard_exception_handling global_opts do
        global_opts.parse ARGV
        raise Trollop::HelpNeeded if ARGV.empty? # show help screen
      end

      cmd = ARGV.shift # get the subcommand
      cli ={}
      cmd_opts = case cmd
        when "clients"
          p = Trollop::options do
            opt :name, "Client name to return", :short => "n", :type => :string
            opt :delete, "Delete the client given by --name", :short => "d", :type => :boolean
          end
          Trollop::die :delete, "Delete depends on the name option --name ( -n )".color(:red) if p[:delete] && !p[:name]
          p[:delete] ? cli.merge!({:method => 'Delete'}) : cli.merge!({:method => 'Get'})
          cli.merge!({:command => cmd})
        when "checks"
          p = Trollop::options do
            opt :name, "Check name to return", :short => "n", :type => :string
          end
          cli.merge!({:command => cmd, :method => 'Get'})
        when "info"
          p = Trollop::options
          cli.merge!({:command => cmd, :method => 'Get'})
        when "events"
          p = Trollop::options do
            opt :client, "Returns the list of current events for a client", :short => "c", :type => :string
            opt :check, "Returns the check associated with the client", :short => "k", :type => :string
            opt :delete, "Delete an event given by --client and --check", :short => "d", :type => :boolean
          end
          Trollop::die :check, "Check depends on the client option --client ( -c )".color(:red) if p[:check] && !p[:client]
          Trollop::die :delete, "Delete depends on the client option --client ( -c ) and the check option --check ( -k )".color(:red) if p[:delete] && !p[:client] && !p[:check]
          if p[:delete]
            cli.merge!({:method => 'Delete'})
          else
            cli.merge!({:method => 'Get'})
          end
          cli.merge!({:command => cmd})
        when "stashes"
          p = Trollop::options do
            opt :path, "The stash path to look up", :short => "p", :type => :string
            #opt :create, "The stash to create", :short => "C", :type => :string
            opt :delete, "Delete a stash given by --path", :short => "d", :type => :boolean
          end
          if p[:create]
            cli.merge!({:method => 'Post'})
          elsif p[:delete]
            cli.merge!({:method => 'Delete'})
          else
            cli.merge!({:method => 'Get'})
          end
          cli.merge!({:command => cmd})
        # when "silence"
        #   p = Trollop::options do
        #     opt :client, "The client to silence", :short => "c", :type => :string
        #     opt :check, "The check to silence (requires --client)", :short => 'k', :type => :string
        #   end
        #   cli.merge!({:command => cmd, :method => 'Post'})
        # when "resolve"
        #   p = Trollop::options do
        #     opt :client, "The client to silence", :short => "c", :type => :string
        #     opt :check, "The check to silence (requires --client)", :short => 'k', :type => :string
        #   end
        #   Trollop::die :check, "Check depends on the client option --client ( -c )".color(:red) if p[:check] && !p[:client]
        #   cli.merge!({:command => cmd, :method => 'Post'})
        else
          explode = Trollop::with_standard_exception_handling global_opts do
            raise Trollop::HelpNeeded # show help screen
          end
        end
        cli.merge!({:fields => p})
        cli
    end

  end
end
