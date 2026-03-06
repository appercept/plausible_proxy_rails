require_relative "lib/plausible_proxy_rails/version"

Gem::Specification.new do |spec|
  spec.name = "plausible_proxy_rails"
  spec.version = PlausibleProxyRails::VERSION
  spec.authors = ["Richard Hatherall"]
  spec.email = ["richard@appercept.com"]
  spec.homepage = "https://github.com/appercept/plausible_proxy_rails"
  spec.summary = "Privacy-preserving Plausible Analytics proxy for Rails"
  spec.description = "A Rails Engine that proxies Plausible Analytics requests through your application server, " \
    "improving visitor privacy and removing the need for third-party CSP exceptions."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0"
end
