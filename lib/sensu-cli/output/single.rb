module SensuCli
  module Output
    module Single
      def single(endpoint = nil)
        return no_values if self.output.empty?
        case endpoint
        when 'events'
          self.output = event_data(self.output)
        end
        keys = self.output.map { |item| item.keys }.flatten.uniq.sort

        # Remove fields with spaces (breaks awkage)
        keys.select! do |key|
          self.output.none? { |item| item[key].to_s.include?(' ') }
        end

        # Find max value lengths
        value_lengths = {}
        keys.each do |key|
          max_value_length = self.output.map { |item| item[key].to_s.length }.max
          value_lengths[key] = [max_value_length, key.length].max
        end

        # Print header
        lengths = keys.map { |key| "%-#{value_lengths[key]}s" }.join(' ')
        puts Kernel.format(lengths, *keys)

        # Print value rows
        self.output.each do |item|
          if item.is_a?(Hash)
            values = keys.map { |key| item[key] }
            puts Kernel.format(lengths, *values)
          else
            puts item.to_s.color(:cyan)
          end
        end
      end
    end
  end
end
