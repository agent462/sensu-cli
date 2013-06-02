require 'rainbow'

module SensuCli
  class Pretty

    def self.print(res)
      if !res.empty?
        if res.is_a?(Hash)
          res.each do |key,value|
            puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
          end
        elsif res.is_a?(Array)
          res.each do |item|
            puts "-------".color(:yellow)
            if item.is_a?(Hash)
              item.each do |key,value|
                puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
              end
            else
              puts item.to_s.color(:cyan)
            end
          end
        end
      else
        puts "no values for this request".color(:cyan)
      end
    end

    def self.count(res)
      res.is_a?(Hash) ? count = res.length : count = res.count
      puts "#{count} total items".color(:yellow) if count
    end

  end
end
