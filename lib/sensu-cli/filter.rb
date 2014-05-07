module SensuCli
  class Filter
    attr_reader :filter

    def initialize(filter_data)
      filter_split(filter_data)
    end

    def filter_split(filter)
      @filter = filter.sub(' ', '').split(',')
    end

    def match?(data)
      data.to_s.include? filter[1]
    end

    def inspect_hash(data)
      data.any? do |key, value|
        if value.is_a?(Array)
          match?(value) if key == filter[0]
        elsif value.is_a?(Hash)
          process(value)
        else
          match?(value) if key == filter[0]
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
