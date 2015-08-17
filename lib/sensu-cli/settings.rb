require 'fileutils'
require 'mixlib/config'
require 'rainbow/ext/string'

module SensuCli
  class Settings

    def determine
      SETTINGSFILES.each do |file|
        SensuCli::Config.from_file(file) if File.readable?(file)
      end
      return Config if Config.host
      create
    end

    def create
      FileUtils.mkdir_p(SETTINGSDIRECTORY) unless File.directory?(SETTINGSDIRECTORY)
      FileUtils.cp(File.join(File.dirname(__FILE__), '../../settings.example.rb'), "#{SETTINGSDIRECTORY}/settings.rb")
      SensuCli::die(0, "We created the configuration file for you at #{file}.  You can also place this in /etc/sensu/sensu-cli/settings.rb. Edit the settings as needed.".color(:red))
    end
  end

  class Config
    extend(Mixlib::Config)
  end
end
