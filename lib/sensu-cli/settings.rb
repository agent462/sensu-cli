require 'fileutils'
require 'mixlib/config'
require 'rainbow/ext/string'

module SensuCli
  class Settings
    def file?(file)
      !File.readable?(file) ? false : true # rubocop:disable FavorUnlessOverNegatedIf
    end

    def create(directory, file)
      FileUtils.mkdir_p(directory) unless File.directory?(directory)
      FileUtils.cp(File.join(File.dirname(__FILE__), '../../settings.example.rb'), file)
      SensuCli::die(0, "We created the configuration file for you at #{file}.  You can also place this in /etc/sensu/sensu-cli. Edit the settings as needed.".color(:red))
    end
  end

  class Config
    extend(Mixlib::Config)
  end
end
