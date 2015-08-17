module SensuCli
  module Commands
    class Silence < SensuCli::Client::Http
      attr_accessor :path, :request_method, :payload, :cli
      include SensuCli::Output::Format

      def initialize(command, cli)
        self.cli = cli
        send(command)
      end

      def silence
        self.path = '/stashes'
        self.request_method = :post
        silence_path = 'silence'
        silence_path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
        silence_path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
        self.payload = {
          :content => {
            :timestamp => Time.now.to_i,
            :owner => cli[:fields][:owner],
            :reason => cli[:fields][:reason]
          },
          :expire => cli[:fields][:expire].to_i,
          :path => silence_path
        }.to_json
      end
    end
  end
end
