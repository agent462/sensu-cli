module SensuCli
  def self.die(code = 0, msg = nil)
    at_exit { puts msg }
    Kernel.exit(code)
  end
  require_relative 'sensu-cli/constants'
  require_relative 'sensu-cli/output/format'
  require_relative 'sensu-cli/output/filter'
  require_relative 'sensu-cli/entry'
  require_relative 'sensu-cli/settings'
  require_relative 'sensu-cli/cli'
  require_relative 'sensu-cli/editor'
  require_relative 'sensu-cli/version'
  require_relative 'sensu-cli/client/socket'
end
