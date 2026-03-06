# frozen_string_literal: true

require "spec_helper"
require "rack"
require "webmock"
require "plausible_proxy_rails"

WebMock.enable!

RSpec.describe PlausibleProxyRails::Middleware do
  subject(:response) { request.get(path, headers) }

  let(:downstream_app) { ->(_env) { [200, {"content-type" => "text/html"}, ["downstream"]] } }
  let(:middleware) { described_class.new(downstream_app) }
  let(:request) { Rack::MockRequest.new(middleware) }
  let(:headers) { {} }
  let(:script_url) { "https://plausible.io/js/script.hash.outbound-links.js" }

  before do
    PlausibleProxyRails.configure do |config|
      config.enabled = true
      config.domain = "example.com"
      config.proxy_path = "/ins"
      config.script_url = script_url
    end
  end

  after do
    PlausibleProxyRails.instance_variable_set(:@configuration, nil)
    WebMock.reset!
  end

  describe "GET /ins/script.js" do
    let(:path) { "/ins/script.js" }
    let(:script_body) { "!function(){console.log('plausible')}()" }

    before do
      WebMock::API.stub_request(:get, script_url)
        .to_return(
          status: 200,
          body: script_body,
          headers: {"content-type" => "application/javascript"}
        )
    end

    it "returns the script from plausible.io" do
      expect(response.body).to eq(script_body)
    end

    it "returns a JavaScript content type" do
      expect(response["content-type"]).to eq("application/javascript")
    end

    it "returns a cache-control header" do
      expect(response["cache-control"]).to eq("public, max-age=3600")
    end

    it "caches the script on subsequent requests" do
      request.get(path)
      request.get(path)

      expect(WebMock).to have_requested(:get, script_url).once
    end
  end

  describe "POST /ins/event" do
    subject(:response) { request.post(path, input: event_body, **headers) }

    let(:path) { "/ins/event" }
    let(:event_body) { '{"name":"pageview","url":"https://example.com"}' }
    let(:headers) do
      {
        "HTTP_USER_AGENT" => "Mozilla/5.0",
        "REMOTE_ADDR" => "1.2.3.4",
        "CONTENT_TYPE" => "application/json"
      }
    end

    before do
      WebMock::API.stub_request(:post, "https://plausible.io/api/event")
        .to_return(status: 202, body: "ok", headers: {"content-type" => "text/plain"})
    end

    it "returns the upstream status code" do
      expect(response.status).to eq(202)
    end

    it "returns the upstream body" do
      expect(response.body).to eq("ok")
    end

    it "forwards the request body to plausible.io" do
      response

      expect(WebMock).to have_requested(:post, "https://plausible.io/api/event")
        .with(body: event_body)
    end

    it "forwards the User-Agent header" do
      response

      expect(WebMock).to have_requested(:post, "https://plausible.io/api/event")
        .with(headers: {"User-Agent" => "Mozilla/5.0"})
    end

    it "falls back to REMOTE_ADDR when X-Forwarded-For is absent" do
      response

      expect(WebMock).to have_requested(:post, "https://plausible.io/api/event")
        .with(headers: {"X-Forwarded-For" => "1.2.3.4"})
    end

    context "when X-Forwarded-For is present" do
      let(:headers) do
        {
          "HTTP_USER_AGENT" => "Mozilla/5.0",
          "HTTP_X_FORWARDED_FOR" => "203.0.113.50, 10.0.0.1",
          "REMOTE_ADDR" => "127.0.0.1",
          "CONTENT_TYPE" => "application/json"
        }
      end

      it "uses X-Forwarded-For instead of REMOTE_ADDR" do
        response

        expect(WebMock).to have_requested(:post, "https://plausible.io/api/event")
          .with(headers: {"X-Forwarded-For" => "203.0.113.50, 10.0.0.1"})
      end
    end

    it "forwards the Content-Type header" do
      response

      expect(WebMock).to have_requested(:post, "https://plausible.io/api/event")
        .with(headers: {"Content-Type" => "application/json"})
    end

    context "with a self-hosted script_url" do
      let(:script_url) { "https://analytics.example.com/js/script.js" }

      before do
        WebMock.reset!
        WebMock::API.stub_request(:post, "https://analytics.example.com/api/event")
          .to_return(status: 202, body: "ok", headers: {"content-type" => "text/plain"})
      end

      it "forwards events to the self-hosted instance" do
        response

        expect(WebMock).to have_requested(:post, "https://analytics.example.com/api/event")
          .with(body: event_body)
      end
    end
  end

  describe "non-matching paths" do
    let(:path) { "/other" }

    it "passes the request to the downstream app" do
      expect(response.body).to eq("downstream")
    end

    it "returns the downstream status" do
      expect(response.status).to eq(200)
    end
  end

  describe "custom proxy_path" do
    let(:path) { "/analytics/script.js" }
    let(:script_body) { "plausible()" }

    before do
      PlausibleProxyRails.configuration.proxy_path = "/analytics"

      WebMock::API.stub_request(:get, script_url)
        .to_return(
          status: 200,
          body: script_body,
          headers: {"content-type" => "application/javascript"}
        )
    end

    it "uses the configured proxy path" do
      expect(response.body).to eq(script_body)
    end
  end
end
