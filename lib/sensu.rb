#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require "net/https"
require 'json'
require 'settings'
require 'cli'
require 'rainbow'

module SensuCli
  class Core
    #
    # CLI can be anything assuming you can pass these paramaters
    #
    # cli = {
    #   :command => 'client',
    #   :method => 'Get',
    #   :flags => {:name => 'ntp-check',
    #              :path => '/keepalive/i-asesew',
    #              :client => 'i-23412412',
    #              :check => 'ntp-check'}
    # }

    def initialize
      cli = Cli.opts
      @settings = Settings.load_file
      request(cli)
    end

    def request(cli)
      case cli[:command]
      when 'clients'
        if cli[:fields][:name]
          @api = {:path => "/client/#{cli[:fields][:name]}"}
        else
          @api = {:path => '/clients'}
        end
      when 'info'
        @api = {:path => '/info'}
      when 'stashes'
        if cli[:fields][:path]
          @api = {:path => "/stashes/#{cli[:fields][:path]}"}
        else
          @api = {:path => '/stashes'}
        end
      when 'checks'
        if cli[:fields][:name] && cli[:fields][:check]
          @api = {:path => "/check/#{cli[:fields][:name]}/#{cli[:fields][:check]}"}
        elsif cli[:fields][:name]
          @api = {:path => "/check/#{cli[:fields][:name]}"}
        else
          @api = {:path => '/checks'}
        end
      when 'events'
        if cli[:fields][:client] && cli[:fields][:check]
          @api = {:path => "/events/#{cli[:fields][:client]}/#{cli[:fields][:check]}"}
        elsif cli[:fields][:client]
          @api = {:path => "/events/#{cli[:fields][:client]}"}
        else
          @api = {:path => "/events"}
        end
      end
      @api.merge!({:method => cli[:method]})
      pretty(api(@settings))
    end

    def api_request(opts={})
      http = Net::HTTP.new(opts[:host], opts[:port])
      http.read_timeout = 15
      http.open_timeout = 5
      if opts[:ssl]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      case opts[:method]
      when 'Get'
        req =  Net::HTTP::Get.new(opts[:path])
      when 'Delete'
        req =  Net::HTTP::Delete.new(opts[:path])
      when 'Post'
        req =  Net::HTTP::Post.new(opts[:path])
        req.set_form_data({"key" => "value"})
      end
      begin
        http.request(req)
      rescue Timeout::Error
        puts "HTTP connection timed out".color(:red)
        exit
      end
    end

    def api(settings)
      opts = {
        :ssl => settings[:ssl],
        :host => settings[:host],
        :port => settings[:port],
        :path => @api[:path],
        :method => @api[:method]
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
