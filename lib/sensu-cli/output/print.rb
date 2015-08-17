module SensuCli
  module Output
    module Print
      def print
        return no_values if self.output.empty?
        if self.output.is_a?(Hash)
          self.output.each do |key, value|
            puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
          end
        elsif self.output.is_a?(Array)
          self.output.each do |item|
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
    end
  end
end


        # case endpoint
        # when 'events'
        #   template = File.read(File.expand_path(File.join(File.dirname(__FILE__), 'templates/event.erb')))
        #   renderer = Erubis::Eruby.new(template)
        #   res.each do |event|
        #     puts renderer.result(event)
        #   end
        #   return
        # end
