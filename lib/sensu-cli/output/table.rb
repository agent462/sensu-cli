require 'hirb'

module SensuCli
  module Output
    module Table
      def table(endpoint = nil, fields = nil)
        return no_values if self.output.empty?
        case endpoint
        when 'events'
          keys = %w(check client address interval occurrences status handlers issued executed output)
          render_table(event_data(self.output), keys)
        else
          if fields
            keys = parse_fields(fields)
          else
            keys = self.output.map { |item| item.keys }.flatten.uniq
          end
          render_table(self.output, keys)
        end
      end

      def render_table(data, keys)
        terminal_size = Hirb::Util.detect_terminal_size
        puts Hirb::Helpers::AutoTable.render(data, :max_width => terminal_size[0], :fields => keys)
      end
    end
  end
end
