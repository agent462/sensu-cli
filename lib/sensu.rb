#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require "net/https"
require 'json'
require 'settings'
require 'cli'
require 'rainbow'

module SensuCli
  class Core

    def initialize
      cli = Cli.opts
      @settings = Settings.load_file
      request(cli)
    end

    def request(cli)
      case cli[:command]
      when 'clients'
        if cli[:name]
          @api = {:path => "/client/#{cli[:name]}"}
        else
          @api = {:path => '/clients'}
        end
      when 'info'
        @api = {:path => '/info'}
      when 'stashes'
        if cli[:path]
          @api = {:path => "/stashes/#{cli[:path]}"}
        else
          @api = {:path => '/stashes'}
        end
      when 'checks'
        if cli[:name]
          @api = {:path => "/check/#{cli[:name]}"}
        else
          @api = {:path => '/checks'}
        end
      when 'events'
        if cli[:client]
          @api = {:path => "/events/#{cli[:client]}"}
        else
          @api = {:path => "/events"}
        end
      end
      pretty(api(@settings))
    end

    def api_request(opts={})
      o = {}.merge(opts)

      http = Net::HTTP.new(o[:host], o[:port])
      if o[:ssl]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req =  Net::HTTP::Get.new(o[:path])
      http.request(req)
    end

    def api(settings)
      opts = {
        :ssl => settings[:ssl],
        :host => settings[:host],
        :port => settings[:port],
        :path => @api[:path]
      }
      res = api_request(opts)
      if res.code === '200'
        JSON.parse(res.body)
      else
        res = ""
      end
    end

    def pretty(res)
      if !res.empty?
        res.each do |item|
          puts "----"
          if item.is_a?(Hash)
            item.each do |key,value|
              puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
            end
          elsif item.is_a?(Array)
              item.each do |key|
                puts "#{key}:  ".color(:cyan)
              end
          else
            puts item.color(:cyan)
          end
        end
      else
        puts "no values for this request".color(:cyan)
      end
    end

  end
end
