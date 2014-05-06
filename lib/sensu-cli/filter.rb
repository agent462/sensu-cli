module SensuCli
  class Filter

    def self.filter_split(filter)
      filter.sub(' ', '').split(',')
    end

    def self.filter_json(res, filter)
      filter = self.filter_split(filter)
      if !res.empty?
        res.select do |item|
          if item.key? filter[0]
            if item[filter[0]].is_a?(Array)
              item unless item[filter[0]].select { |value| value.include? filter[1] }.empty?
            else
              item if item[filter[0]].include? filter[1]
            end
          end
        end
      else
        res
      end
    end

  end
end
