module PlausibleProxyRails
  class Configuration
    attr_accessor :enabled, :domain, :proxy_path, :script_url

    def initialize
      @enabled = false
      @proxy_path = "/ins"
      @script_url = "https://plausible.io/js/script.js"
    end

    def enabled?
      enabled && domain.present?
    end
  end
end
