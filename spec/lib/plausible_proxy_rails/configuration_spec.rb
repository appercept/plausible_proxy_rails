# frozen_string_literal: true

require "spec_helper"
require "plausible_proxy_rails/configuration"

RSpec.describe PlausibleProxyRails::Configuration do
  subject(:configuration) { described_class.new }

  describe "defaults" do
    it "is not enabled" do
      expect(configuration.enabled).to be false
    end

    it "has no domain" do
      expect(configuration.domain).to be_nil
    end

    it "defaults proxy_path to /ins" do
      expect(configuration.proxy_path).to eq("/ins")
    end

    it "defaults script_url to the base Plausible script" do
      expect(configuration.script_url).to eq("https://plausible.io/js/script.js")
    end
  end

  describe "#enabled?" do
    it "returns false when enabled is false" do
      configuration.enabled = false
      configuration.domain = "example.com"

      expect(configuration).not_to be_enabled
    end

    it "returns false when domain is nil" do
      configuration.enabled = true
      configuration.domain = nil

      expect(configuration).not_to be_enabled
    end

    it "returns false when domain is blank" do
      configuration.enabled = true
      configuration.domain = ""

      expect(configuration).not_to be_enabled
    end

    it "returns true when enabled and domain is present" do
      configuration.enabled = true
      configuration.domain = "example.com"

      expect(configuration).to be_enabled
    end
  end
end
