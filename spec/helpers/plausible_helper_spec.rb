# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlausibleProxyRails::Helper, type: :helper do
  before do
    PlausibleProxyRails.configure do |config|
      config.enabled = true
      config.domain = "example.com"
      config.proxy_path = "/ins"
    end
  end

  after do
    PlausibleProxyRails.instance_variable_set(:@configuration, nil)
  end

  describe "#plausible_tag" do
    subject(:result) { helper.plausible_tag }

    it "renders a deferred script tag" do
      expect(result).to include('defer="defer"')
    end

    it "points to the proxy script path" do
      expect(result).to include('src="/ins/script.js"')
    end

    it "sets the data-domain attribute" do
      expect(result).to include('data-domain="example.com"')
    end

    it "sets the data-api attribute" do
      expect(result).to include('data-api="/ins/event"')
    end

    context "when disabled" do
      before { PlausibleProxyRails.configuration.enabled = false }

      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "when domain is missing" do
      before { PlausibleProxyRails.configuration.domain = nil }

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
