require 'json'
require 'tempfile'

module SensuCli
  class Editor

    def create_stash(create_path)
      @create_path = create_path
      file = create_file
      open(file)
    end

    def open(file)
      ENV['EDITOR'] ? editor = ENV['EDITOR'] : editor = 'vi'
      system("#{editor} #{file}")
      begin
        JSON.parse(File.read(file))
      rescue JSON::ParserError
        puts "The stash you created has Invalid JSON."
        exit
      end
    end

    def create_file
      template = {:path => @create_path, :content => {:timestamp => Time.now.to_i }}
      file = Tempfile.new('sensu')
      file.write(JSON.pretty_generate(template))
      file.close
      file.path
    end

  end
end
