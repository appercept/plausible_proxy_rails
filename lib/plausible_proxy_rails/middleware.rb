# frozen_string_literal: true

require "net/http"

module PlausibleProxyRails
  class Middleware
    CACHE_TTL = 3600 # 1 hour in seconds

    def initialize(app)
      @app = app
      @script_cache = nil
      @cached_at = nil
      @mutex = Mutex.new
    end

    def call(env)
      config = PlausibleProxyRails.configuration

      case env["PATH_INFO"]
      when "#{config.proxy_path}/script.js"
        serve_script(config)
      when "#{config.proxy_path}/event"
        forward_event(env, config)
      else
        @app.call(env)
      end
    end

    private

    def serve_script(config)
      body, headers = cached_script(config)
      [200, headers, [body]]
    end

    def cached_script(config)
      @mutex.synchronize do
        if @script_cache.nil? || (Time.now - @cached_at) > CACHE_TTL
          fetch_script(config)
        end

        [@script_cache, @cached_headers]
      end
    end

    def fetch_script(config)
      uri = URI(config.script_url)
      response = Net::HTTP.get_response(uri)

      @script_cache = response.body
      @cached_headers = {
        "content-type" => response["content-type"],
        "cache-control" => "public, max-age=3600"
      }
      @cached_at = Time.now
    end

    def forward_event(env, config)
      request = Rack::Request.new(env)
      body = request.body.read

      script_uri = URI(config.script_url)
      uri = URI("#{script_uri.scheme}://#{script_uri.host}/api/event")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      post = Net::HTTP::Post.new(uri.path)
      post["User-Agent"] = env["HTTP_USER_AGENT"]
      post["X-Forwarded-For"] = env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"]
      post["Content-Type"] = env["CONTENT_TYPE"]
      post.body = body

      response = http.request(post)
      response_headers = {"content-type" => response["content-type"]}.compact

      [response.code.to_i, response_headers, [response.body]]
    end
  end
end
