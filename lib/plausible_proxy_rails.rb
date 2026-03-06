require "plausible_proxy_rails/engine"
require "plausible_proxy_rails/version"

module PlausibleProxyRails
  autoload :Configuration, "plausible_proxy_rails/configuration"
  autoload :Helper, "plausible_proxy_rails/helper"
  autoload :Middleware, "plausible_proxy_rails/middleware"

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
