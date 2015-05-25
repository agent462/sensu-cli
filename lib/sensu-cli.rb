require 'sensu-cli/settings'
require 'sensu-cli/cli'
require 'sensu-cli/editor'
require 'sensu-cli/pretty'
require 'sensu-cli/path.rb'
require 'sensu-cli/api.rb'
require 'sensu-cli/base.rb'
require 'sensu-cli/version.rb'
require 'sensu-cli/filter.rb'
require 'sensu-cli/client/socket.rb'

module SensuCli
  def self.die(code = 0, msg = nil)
    at_exit { puts msg }
    Kernel.exit(code)
  end
end
