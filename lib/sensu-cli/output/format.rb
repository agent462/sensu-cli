require_relative 'json'
require_relative 'print'
require_relative 'filter'
require_relative 'table'
require_relative 'single'

module SensuCli
  module Output
    module Format
      include SensuCli::Output::Json
      include SensuCli::Output::Print
      include SensuCli::Output::Filter
      include SensuCli::Output::Table
      include SensuCli::Output::Single

      def format(type)
        send(type.to_s)
      end

      def no_values
        puts 'There are no values for this request'.color(:cyan)
      end
    end
  end
end
