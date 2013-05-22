module SensuCli
  class PathCreator

    def clients(cli)
      path = "/clients"
      path << "/#{cli[:fields][:name]}" if cli[:fields][:name]
      path << "/history" if cli[:fields][:history]
      path << pagination(cli)
      respond(path)
    end

    def info(cli)
      path = "/info"
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
      path = "/stashes"
      path << "/#{cli[:fields][:path]}" if cli[:fields][:path]
      path << pagination(cli)
      respond(path,payload)
    end

    def checks(cli)
      if cli[:fields][:name]
        path = "/check/#{cli[:fields][:name]}"
      elsif cli[:fields][:subscribers]
        payload = {:check => cli[:fields][:check],:subscribers => cli[:fields][:subscribers]}.to_json
        path = "/check/request"
      else
        path = "/checks"
      end
      respond(path,payload)
    end

    def events(cli)
      path = "/events"
      path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      respond(path)
    end

    def resolve(cli)
      payload = {:client => cli[:fields][:client], :check => cli[:fields][:check]}.to_json
      path = "/event/resolve"
      respond(path,payload)
    end

    def silence(cli)
      payload = {:timestamp => Time.now.to_i}
      payload.merge!({:reason => cli[:fields][:reason]}) if cli[:fields][:reason]
      if cli[:fields][:expires]
        expires = Time.now.to_i + (cli[:fields][:expires] * 60)
        payload.merge!({:expires => expires})
      end
      payload = payload.to_json
      path = "/stashes/silence"
      path << "/#{cli[:fields][:client]}" if cli[:fields][:client]
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      respond(path,payload)
    end

    def aggregates(cli)
      path = "/aggregates"
      path << "/#{cli[:fields][:check]}" if cli[:fields][:check]
      path << "/#{cli[:fields][:id]}" if cli[:fields][:id]
      path << pagination(cli)
      respond(path)
    end

    def pagination(cli)
      if cli[:fields].has_key?(:limit) && cli[:fields].has_key?(:offset)
        page = "?limit=#{cli[:fields][:limit]}&offset=#{cli[:fields][:offset]}"
      elsif cli[:fields].has_key?(:limit)
        page = "?limit=#{cli[:fields][:limit]}"
      else
        page = ""
      end
    end

    def respond(path,payload=false)
      {:path => path, :payload => payload}
    end

  end
end
