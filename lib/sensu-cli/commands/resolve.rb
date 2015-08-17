module SensuCli
  module Commands
    class Resolve < SensuCli::Client::Http
      include SensuCli::Output::Format
      attr_accessor :path, :request_method, :cli, :payload

      def initialize(command, cli)
        self.cli = cli
        send(command)
      end

      def resolve
        self.path = '/resolve'
        self.request_method = :post
        self.payload = {
          :client => cli[:fields][:client],
          :check => cli[:fields][:check]
        }.to_json
      end
    end
  end
end
