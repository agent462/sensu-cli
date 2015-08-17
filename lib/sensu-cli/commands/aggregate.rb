module SensuCli
  module Commands
    class Aggregate < SensuCli::Client::Http
      include SensuCli::Output::Format
      attr_accessor :cli, :request_method, :path

      def initialize(command, cli)
        self.cli = cli
        self.request_method = :get
        send(command)
      end

      def list
        self.path = '/aggregates'
      end

      def show
        self.path = "/aggregates/#{cli[:fields][:check]}"
      end

      # def test
      #   self.path = "/aggregates/#{cli[:fields][:check]}/#{cli[:fields][:issued]}"
      # end

      def delete
        self.path = "/aggregates/#{cli[:fields][:id]}"
        self.request_method = :delete
      end
    end
  end
end

    #   path << pagination(cli)
