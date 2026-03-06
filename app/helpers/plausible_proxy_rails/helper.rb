module PlausibleProxyRails
  module Helper
    def plausible_tag
      config = PlausibleProxyRails.configuration
      return unless config.enabled?

      tag.script(
        nil,
        src: "#{config.proxy_path}/script.js",
        defer: true,
        data: {
          domain: config.domain,
          api: "#{config.proxy_path}/event"
        }
      )
    end
  end
end
