module SensuCli
  module Commands
    class Info < SensuCli::Client::Http
      include SensuCli::Output::Format

      attr_accessor :path, :request_method

      def initialize(command)
        send(command)
      end

      def format_support
        %w[json print]
      end

      def info
        self.path = '/info'
        self.request_method = :get
      end
    end
  end
end
