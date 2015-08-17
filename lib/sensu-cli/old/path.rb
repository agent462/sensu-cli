module SensuCli
  class PathCreator
    def clients(cli)
      path = '/clients'
      path << "/#{cli[:fields][:name]}" if cli[:fields][:name]
      path << '/history' if cli[:fields][:history]
      path << pagination(cli)
      respond(path)
    end

    def info(*)
      path = '/info'
      respond(path)
    end

    def health(cli)
      path = "/health?consumers=#{cli[:fields][:consumers]}&messages=#{cli[:fields][:messages]}"
      respond(path)
    end

    def stashes(cli)
      if cli[:fields][:create]
        e = Editor.new
        payload = e.create_stash(cli[:fields][:create_path]).to_json
      end
      path = '/stashes'
      path << "/#{cli[:fields][:path]}" if cli[:fields][:path]
      path << pagination(cli)
      respond(path, payload)
    end

    def checks(cli)
      if cli[:fields][:name]
        path = "/check/#{cli[:fields][:name]}"
      elsif cli[:fields][:subscribers]
        payload = { :check => cli[:fields][:check], :subscribers => cli[:fields][:subscribers] }.to_json
        path = '/request'
      else
        path = '/checks'
      end
      respond(path, payload)
    end

    def events(cli)
      path = '/events'
      path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      respond(path)
    end

    def resolve(cli)
      payload = { :client => cli[:fields][:client], :check => cli[:fields][:check] }.to_json
      path = '/resolve'
      respond(path, payload)
    end

    def silence(cli)
      content = { :timestamp => Time.now.to_i }
      content.merge!(:owner => cli[:fields][:owner]) if cli[:fields][:owner]
      content.merge!(:reason => cli[:fields][:reason]) if cli[:fields][:reason]
      payload = { :content =>  content }
      payload.merge!(:expire => cli[:fields][:expire].to_i) if cli[:fields][:expire]
      silence_path = 'silence'
      silence_path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
      silence_path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      payload = payload.merge!(:path => silence_path).to_json
      respond('/stashes', payload)
    end

    def aggregates(cli)
      path = '/aggregates'
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      path << "/#{cli[:fields][:id]}" if cli[:fields][:id]
      path << pagination(cli)
      respond(path)
    end

    def pagination(cli)
      if cli[:fields].key?(:limit) && cli[:fields].key?(:offset)
        "?limit=#{cli[:fields][:limit]}&offset=#{cli[:fields][:offset]}"
      elsif cli[:fields].key?(:limit)
        "?limit=#{cli[:fields][:limit]}"
      else
        ''
      end
    end

    def method_missing(method_name, *_args)
      puts "Path method: #{method_name} does not exist. "
    end

    def respond(path, payload = false)
      { :path => "#{Config.api_endpoint}#{path}", :payload => payload }
    end
  end
end
