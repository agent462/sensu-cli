module SensuCli
  module Commands
      class Event < SensuCli::Client::Http
      include SensuCli::Output::Format

      attr_accessor :cli, :path, :request_method

      def initialize(command, cli)
        self.cli = cli
        self.request_method = :get
        send(command)
      end

      def list
        self.path = '/events'
      end

      def show
        self.path = "/events/#{cli[:fields][:client]}"
      end

      # def show_client_check
      #   self.path = "/events/#{cli[:fields][:client]}/#{cli[:fields][:check]}"
      # end

      # def resolve
      # end

      def delete
        self.path = "/events/#{cli[:fields][:client]}/#{cli[:fields][:check]}"
        self.request_method = :delete
      end
    end
  end
end
