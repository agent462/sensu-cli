require 'socket'

module SensuCli
  module Client
    class Socket
      def send_udp_message(messages)
        udp = UDPSocket.new
        messages.each do |message|
          udp.send(message, 0, '127.0.0.1', 3030)
        end
      end
    end
  end
end
