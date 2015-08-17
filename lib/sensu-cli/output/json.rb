require 'json'

module SensuCli
  module Output
    module Json
      def json
        puts JSON.pretty_generate(self.output)
      end
    end
  end
end
