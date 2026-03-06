module PlausibleProxyRails
  class Engine < ::Rails::Engine
    initializer "plausible_proxy_rails.middleware" do |app|
      if PlausibleProxyRails.configuration.enabled?
        app.middleware.use PlausibleProxyRails::Middleware
      end
    end

    initializer "plausible_proxy_rails.helpers" do
      ActiveSupport.on_load(:action_view) do
        include PlausibleProxyRails::Helper
      end
    end
  end
end
