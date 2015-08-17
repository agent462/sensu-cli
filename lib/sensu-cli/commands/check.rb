module SensuCli
  module Commands
    class Check < SensuCli::Client::Http
      include SensuCli::Output::Format
      attr_accessor :cli, :path, :request_method, :payload

      def initialize(command, cli)
        self.cli = cli
        self.request_method = :get
        send(command)
      end

      def list
        self.path = '/checks'
      end

      def show
        self.path = "/checks/#{cli[:fields][:name]}"
      end

      def request
        self.path = '/request'
        self.request_method = :post
        self.payload = {
          :check => cli[:fields][:check],
          :subscribers => cli[:fields][:subscribers]
        }.to_json
      end
    end
  end
end

# filter ist broken in old and new on list
