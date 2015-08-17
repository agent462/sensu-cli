module SensuCli
  module Commands
    class Client < SensuCli::Client::Http
      include SensuCli::Output::Format

      attr_accessor :path, :request_method, :node

      def initialize(command, node = nil)
        self.request_method = :get
        self.node = node
        self.path = '/clients'
        send(command)
      end

      def list
        self.path = '/clients'
      end

      def show
        self.path = "/clients/#{node}"
      end

      def delete
        self.path = "/clients/#{node}"
        self.request_method = :delete
      end

      def history
        self.path = "/clients/#{node}/history"
      end

      def create
        self.path = '/clients'
        self.request_method = :post
        payload = nil
      end

#   {
#     "name": "gateway-router",
#     "address": "192.168.0.1",
#     "subscriptions": [
#         "network",
#         "snmp"
#     ],
#     "environment": "production"
# }

    end
  end
end
    #   path << pagination(cli)
