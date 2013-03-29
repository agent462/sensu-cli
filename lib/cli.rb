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
          sensu client (options)\r
          sensu check (options)\r
          sensu stash (options)\r
          sensu status (options)\r

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
            opt :name, "returns a client", :short => "n", :type => :string
          end
          p.merge!({:command => cmd})
        when "checks"
          p = Trollop::options do
            opt :name, "The check name to look up.", :short => "n", :type => :string
          end
          p.merge!({:command => cmd})
        when "info"
          p = {:command => cmd}
        when "events"
          p = Trollop::options do
            opt :client, "returns the list of current events for a client", :short => "c", :type => :string
          end
          p = {:command => cmd}
        when "stashes"
          p = Trollop::options do
            opt :path, "The stash path to look up", :short => "p", :type => :string
          end
          p = {:command => cmd}
        else
          explode = Trollop::with_standard_exception_handling global_opts do
            raise Trollop::HelpNeeded # show help screen
          end
        end
      p ? p : opts
    end

  end
end
