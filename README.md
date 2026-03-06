# Plausible Proxy Rails

[![CI](https://github.com/appercept/plausible_proxy_rails/actions/workflows/ci.yml/badge.svg)](https://github.com/appercept/plausible_proxy_rails/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/plausible_proxy_rails.svg)](https://rubygems.org/gems/plausible_proxy_rails)

A Rails Engine that proxies [Plausible Analytics](https://plausible.io) requests through your application server, so visitors never connect to a third-party domain. This means analytics work even when third-party scripts are blocked, and you don't need `plausible.io` in your Content Security Policy.

## How It Works

The gem inserts Rack middleware that intercepts two routes under a configurable proxy path (default: `/ins`):

| Request              | What happens                                                                                   |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| `GET /ins/script.js` | Fetches the Plausible script, caches it for 1 hour, and serves it from your domain             |
| `POST /ins/event`    | Forwards the analytics event payload to the Plausible API with the visitor's IP and User-Agent |

All other requests pass through to your application untouched.

## Installation

Add to your Gemfile:

```ruby
gem "plausible_proxy_rails"
```

Then run `bundle install`.

## Configuration

Create an initializer:

```ruby
# config/initializers/plausible.rb
PlausibleProxyRails.configure do |config|
  config.enabled = Rails.env.production?
  config.domain = "yoursite.com"
end
```

### Options

| Option       | Default                               | Description                                                                                                                          |
| ------------ | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `enabled`    | `false`                               | Enable the proxy middleware                                                                                                          |
| `domain`     | `nil`                                 | Your site's domain as registered in Plausible (required)                                                                             |
| `proxy_path` | `"/ins"`                              | URL path prefix for the proxy endpoints                                                                                              |
| `script_url` | `"https://plausible.io/js/script.js"` | Plausible script URL — change this to use [script extensions](https://plausible.io/docs/script-extensions) or a self-hosted instance |

The middleware is only activated when `enabled` is `true` **and** `domain` is present.

## Usage

Add the script tag to your layout:

```erb
<%# app/views/layouts/application.html.erb %>
<head>
  <%= plausible_tag %>
</head>
```

When the proxy is disabled (e.g., in development), `plausible_tag` returns `nil` and nothing is rendered.

## Self-Hosted Plausible

If you run a [self-hosted Plausible instance](https://plausible.io/docs/self-hosting), point `script_url` at your server. The event API endpoint is derived from the same host automatically:

```ruby
PlausibleProxyRails.configure do |config|
  config.enabled = true
  config.domain = "yoursite.com"
  config.script_url = "https://analytics.yoursite.com/js/script.js"
end
```

## Plausible Script Options

Plausible provides a site-specific script URL (found in your Plausible account under Site Settings > Site Installation) that looks like `https://plausible.io/js/pa-XXXXXXXXX.js`. This bundles your enabled features automatically. You can also use the generic `https://plausible.io/js/script.js` with [script extensions](https://plausible.io/docs/script-extensions). Either format works with this gem — set your preferred URL as `script_url`:

```ruby
# Site-specific script
config.script_url = "https://plausible.io/js/pa-XXXXXXXXX.js"

# Or generic script with extensions
config.script_url = "https://plausible.io/js/script.file-downloads.outbound-links.js"
```

See the [Plausible docs](https://plausible.io/docs/plausible-script) for more on script options.

## Why Not Proxy at the Web Server Level?

Plausible's [proxy guides](https://plausible.io/docs/proxy/introduction) cover NGINX, Caddy, and others. But plenty of Rails apps run on Heroku, Render, or Fly.io where you don't control the web server config. This gem handles it at the app layer instead — add the gem, configure it, done. The proxy setup travels with your app and works the same everywhere.

If you're already proxying through NGINX, you don't need this.

## Requirements

- Ruby >= 3.2
- Rails >= 7.0

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/appercept/plausible_proxy_rails). See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

This project is intended to be a safe, welcoming space for collaboration. Please follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
