require 'trollop'
require 'rainbow'

module SensuCli
  class Cli

    SUB_COMMANDS = %w(info clients checks check events event stashes)

    def self.opts

      global_opts = Trollop::Parser.new do
        version "Sensu CLI 0.0.1"
        banner <<-EOS.gsub(/^ {10}/, '')
          #
          # Welcome to the sensu-cli.
          #


          Available subcommands: (for details, sensu SUB-COMMAND --help)

          ** Sensu Commands **
          sensu clients (options)\r
          sensu checks (options)\r
          sensu stash (options)\r
          sensu status (options)\r
          sensu info (options)\r
          sensu events (options)\r
          sensu stashes (options)\r

        EOS
        banner <<-EOS.gsub(/^ {10}/, '').color(:cyan)

          Example Usage: sensu client (stuff goes here)
          For help use: sensu SUB-COMMAND --help
        EOS
        stop_on SUB_COMMANDS
      end

      opts = Trollop::with_standard_exception_handling global_opts do
        global_opts.parse ARGV
        raise Trollop::HelpNeeded if ARGV.empty? # show help screen
      end

      cmd = ARGV.shift # get the subcommand
      cmd_opts = case cmd
        when "clients"
          p = Trollop::options do
            opt :name, "Client name to return", :short => "n", :type => :string
            opt :delete, "Client name to return", :short => "d", :type => :boolean
          end
          p.merge!({:command => cmd})
        when "checks"
          p = Trollop::options do
            opt :name, "Check name to return", :short => "n", :type => :string
          end
          p.merge!({:command => cmd})
        when "info"
          p = Trollop::options
          p.merge!({:command => cmd})
        when "events"
          p = Trollop::options do
            opt :client, "Returns the list of current events for a client", :short => "c", :type => :string
          end
          p.merge!({:command => cmd})
        when "stashes"
          p = Trollop::options do
            opt :path, "The stash path to look up", :short => "p", :type => :string
          end
          p.merge!({:command => cmd})
        else
          explode = Trollop::with_standard_exception_handling global_opts do
            raise Trollop::HelpNeeded # show help screen
          end
        end
      p ? p : opts
    end

  end
end
