module SensuCli
  module Commands
    class Socket < SensuCli::Client::Socket
      attr_accessor :cli

      def initialize(command, cli)
        self.cli = cli
        send(command)
      end

      def create
        format_message(cli[:fields])
        send_udp_message
      end

      def raw
        message = cli[:raw]
        send_udp_message
      end
    end
  end
end
