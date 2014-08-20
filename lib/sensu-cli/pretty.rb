require 'rainbow/ext/string'
require 'hirb'
require 'json'
require 'erubis'

module SensuCli
  class Pretty
    class << self
      def print(res, endpoint = nil)
        return no_values if res.empty?
        case endpoint
        when 'events'
          template = File.read(File.expand_path(File.join(File.dirname(__FILE__), 'templates/event.erb')))
          renderer = Erubis::Eruby.new(template)
          res.each do |event|
            puts renderer.result(event)
          end
          return
        end
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

      def single(res, endpoint = nil)
        return no_values if res.empty?
        case endpoint
        when 'events'
          res = event_data(res)
        end
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
        lengths = keys.map { |key| "%-#{value_lengths[key]}s" }.join(' ')
        puts format(lengths, *keys)

        # Print value rows
        res.each do |item|
          if item.is_a?(Hash)
            values = keys.map { |key| item[key] }
            puts format(lengths, *values)
          else
            puts item.to_s.color(:cyan)
          end
        end
      end

      def parse_fields(fields)
        fields.split(',')
      end

      def event_data(res)
        events = []
        res.each do |event|
          events << {
            'client' => event['client']['name'],
            'address' => event['client']['address'],
            'check' => event['check']['name'],
            'interval' => event['check']['interval'],
            'occurrences' => event['occurrences'],
            'status' => event['check']['status'],
            'handlers' => event['check']['handlers'],
            'issued' => event['check']['issued'],
            'executed' => event['check']['executed'],
            'output' => event['check']['output'].rstrip
          }
        end
        events
      end

      def table(res, endpoint = nil, fields = nil)
        return no_values if res.empty?
        case endpoint
        when 'events'
          keys = %w(check client address interval occurrences status handlers issued executed output)
          render_table(event_data(res), keys)
        else
          if fields
            keys = parse_fields(fields)
          else
            keys = res.map { |item| item.keys }.flatten.uniq
          end
          render_table(res, keys)
        end
      end

      def render_table(data, keys)
        terminal_size = Hirb::Util.detect_terminal_size
        puts Hirb::Helpers::AutoTable.render(data, :max_width => terminal_size[0], :fields => keys)
      end
    end
  end
end
