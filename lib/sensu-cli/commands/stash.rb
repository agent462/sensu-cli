module SensuCli
  module Commands
    class Stash < SensuCli::Client::Http
      include SensuCli::Output::Format
      attr_accessor :cli, :path, :request_method, :payload

      def initialize(command, cli)
        self.cli = cli
        self.request_method = :get
        send(command)
      end

      def list
        self.path = "/stashes"
      end

      def show
        self.path = "/stashes/#{cli[:fields][:path]}"
      end

      def delete
        self.path = "/stashes/#{cli[:fields][:path]}"
        self.request_method = :delete
      end

      def create
        e = Editor.new
        payload = e.create_stash(cli[:fields][:create_path]).to_json
      end

    end
  end
end

#   path << pagination(cli)
