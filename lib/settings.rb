require 'fileutils'
require 'mixlib/config'

module SensuCli

  class Settings
    def self.check_settings(directory,file)
      if !File.readable?(file)
        if File.directory?(directory)
          FileUtils.cp(File.join(File.dirname(__FILE__),"../settings.example.rb"), file)
          puts "We created the configuration file for you at #{file}.  Edit the settings as needed.".color(:red)
        else
          FileUtils.mkdir(directory)
          FileUtils.cp(File.join(File.dirname(__FILE__),"../settings.example.rb"), file)
          puts "The settings file and directory did not exist. We created it for you #{file}. Edit the settings as needed.".color(:red)
        end
        exit
      end
    end
  end

  class Config
    extend(Mixlib::Config)
  end

end
