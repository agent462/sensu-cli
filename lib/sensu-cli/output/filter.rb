module SensuCli
  module Output
    module Filter
      attr_reader :filter

      # def initialize(filter_data)
      #   filter_split(filter_data)
      # end

      def filter(filter_data)
        put "here"
        filter_split(filter_data)
        self.output = process(self.output)
      end

      def filter_split(filter)
        self.filter = filter.sub(' ', '').split(',')
      end

      def match?(data)
        data.to_s.include? filter[1]
      end

      def inspect_hash(data)
        data.any? do |key, value|
          if value.is_a?(Array)
            match?(value) if key == filter.first
          elsif value.is_a?(Hash)
            process(value)
          else
            match?(value) if key == filter.first
          end
        end
      end

      def process(data)
        if data.is_a?(Array)
          data.select do |value|
            process(value)
          end
        elsif data.is_a?(Hash)
          inspect_hash(data)
        end
      end
    end
  end
end
