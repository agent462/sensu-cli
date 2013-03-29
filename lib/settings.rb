require 'json'

module SensuCli
  class Settings

    def self.load_file
      settings = {}
      file = '../settings.json'
      if File.readable?(file)
        begin
          settings = JSON.parse(File.open(file, 'r').read, :symbolize_names => true)
        rescue JSON::ParserError => e
          puts "The config file must be valid json. #{e}"
        end
      else
        puts "The config file does not exist or is not readable. #{e}"
      end
    end

  end
end
