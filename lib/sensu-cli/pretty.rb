require 'rainbow'
require 'hirb'
require 'json'

module SensuCli
  class Pretty
    class << self

      def print(res)
        if !res.empty?
          if res.is_a?(Hash)
            res.each do |key, value|
              puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
            end
          elsif res.is_a?(Array)
            res.each do |item|
              puts '-------'.color(:yellow)
              if item.is_a?(Hash)
                item.each do |key, value|
                  puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
                end
              else
                puts item.to_s.color(:cyan)
              end
            end
          end
        else
          self.no_values
        end
      end

      def json(res)
        puts JSON.pretty_generate(res)
      end

      def count(res)
        res.is_a?(Hash) ? count = res.length : count = res.count
        puts "#{count} total items".color(:yellow) if count
      end

      def clean(thing)
        thing = thing.gsub("\n", '/\n') if thing.is_a?(String)
        thing
      end

      def no_values
        puts 'no values for this request'.color(:cyan)
      end

      def single(res)
        if !res.empty?
          if res.is_a?(Array)
            keys = res.map { |item| item.keys }.flatten.uniq.sort

            # Remove fields with spaces (breaks awkage)
            keys.select! do |key|
              res.none? { |item| item[key].to_s.include?(' ') }
            end

            # Find max value lengths
            value_lengths = {}
            keys.each do |key|
              max_value_length = res.map { |item| item[key].to_s.length }.max
              value_lengths[key] = [max_value_length, key.length].max
            end

            # Print header
            format = keys.map { |key| "%-#{value_lengths[key]}s" }.join(' ')
            puts sprintf(format, *keys)

            # Print value rows
            res.each do |item|
              if item.is_a?(Hash)
                values = keys.map { |key| item[key] }
                format = keys.map { |key| "%-#{value_lengths[key]}s" }.join(' ')
                puts sprintf(format, *values)
              else
                puts item.to_s.color(:cyan)
              end
            end
          end
        else
          self.no_values
        end
      end

      def parse_fields(fields)
        fields.split(',')
      end

      def table(res, endpoint, fields = nil)
        if !res.empty?
          if res.is_a?(Array)
            terminal_size = Hirb::Util.detect_terminal_size
            if endpoint == 'events'
              keys = %w[check client status flapping occurrences handlers issued output]
            else
              if fields
                keys = self.parse_fields(fields)
              else
                keys = res.map { |item| item.keys }.flatten.uniq
              end
            end
            puts Hirb::Helpers::AutoTable.render(res, { :max_width => terminal_size[0], :fields => keys })
          end
        else
          self.no_values
        end
      end

    end
  end
end
