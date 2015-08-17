module SensuCli
  module Commands
    class Health < SensuCli::Client::Http
      include SensuCli::Output::Format

      attr_accessor :cli, :path, :request_method

      def initialize(command, cli)
        self.cli = cli
        send(command)
      end

      def health
        self.path = "/health?consumers=#{cli[:fields][:consumers]}&messages=#{cli[:fields][:messages]}"
        self.request_method = :get
      end
    end
  end
end
