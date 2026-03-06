# frozen_string_literal: true

require "spec_helper"
require "plausible_proxy_rails"

RSpec.describe PlausibleProxyRails do
  after do
    described_class.instance_variable_set(:@configuration, nil)
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(PlausibleProxyRails::Configuration)
    end

    it "memoizes the configuration" do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      described_class.configure do |config|
        config.domain = "example.com"
      end

      expect(described_class.configuration.domain).to eq("example.com")
    end
  end
end
