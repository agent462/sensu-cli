require 'json'
require 'tempfile'

module SensuCli
  class Editor

    def create_stash(create_path)
      file = temp_file({:path => create_path, :content => {:timestamp => Time.now.to_i }})
      edit(file)
    end

    def edit(file)
      ENV['EDITOR'] ? editor = ENV['EDITOR'] : editor = 'vi'
      system("#{editor} #{file}")
      begin
        JSON.parse(File.read(file))
      rescue JSON::ParserError
        puts "The stash you created has Invalid JSON."
        exit
      end
    end

    def temp_file(template)
      file = Tempfile.new('sensu')
      file.write(JSON.pretty_generate(template))
      file.close
      file.path
    end

  end
end
