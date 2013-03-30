require 'json'
require 'fileutils'

module SensuCli
  class Settings

    def self.load_file
      directory = "#{Dir.home}/.sensu"
      file = "#{directory}/settings.json"
      settings = {}
      if File.readable?(file)
        begin
          settings = JSON.parse(File.open(file, 'r').read, :symbolize_names => true)
        rescue JSON::ParserError => e
          puts "The config file must be valid json. #{e}".color(:red)
          exit
        end
      else
        if File.directory?(directory)
          FileUtils.cp("../settings.example.json", file)
          puts "We created the configuration file for you at #{file}.  Edit the settings as needed.".color(:red)
        else
          FileUtils.mkdir(directory)
          FileUtils.cp("../settings.example.json", file)
          puts "The settings file and directory did not exist. We created it for you #{file}. Edit the settings as needed.".color(:red)
        end
        exit
      end
    end

  end
end
