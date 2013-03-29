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
      res = api(@settings)
      if cli[:command] === "stashes"
        pretty_stashes(res)
      else
        pretty(res)
      end
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
      JSON.parse(api_request(opts).body)
    end

    def pretty(res)
      res.each do |item|
        puts "----"
        item.each do |key,value|
          puts "#{key}:  ".color(:cyan) + "#{value}".color(:green)
        end
      end
    end

    def pretty_stashes(res)
      res.each do |item|
        puts item.color(:cyan)
      end
    end

  end
end
