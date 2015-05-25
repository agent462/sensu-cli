require 'socket'
require 'json'

module SensuCli
  module Client
    class Socket
      attr_accessor :message

      def send_udp_message
        udp = UDPSocket.new
        udp.send(message, 0, '127.0.0.1', 3030)
        puts 'UDP Socket Message Sent'
      end

      def format_message(data)
        self.message = { 'name' => data[:name], 'output' => data[:output], 'status' => data[:status] }.to_json
      end
    end
  end
end
