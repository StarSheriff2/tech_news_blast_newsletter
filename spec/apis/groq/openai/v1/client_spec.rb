# spec/apis/groq/openai/v1/client_spec.rb
require 'rails_helper'
require 'faraday'

RSpec.describe Groq::Openai::V1::Client do
  let(:api_key) { "test_api_key" }
  let(:adapter) { :test }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) { described_class.new(api_key: api_key, adapter: adapter, stubs: stubs) }

  describe "#initialize" do
    it "sets the api_key and adapter" do
      expect(client.api_key).to eq(api_key)
      expect(client.adapter).to eq(adapter)
    end
  end

  describe "#request" do
    let(:endpoint) { "/test_endpoint" }
    let(:http_method) { :get }
    let(:body) { { key: "value" } }

    context "when the request is successful" do
      before do
        stubs.get(endpoint) do |env|
          expect(env.url.path).to eq(endpoint)
          expect(env.method).to eq(http_method)
          [ 200, { "Content-Type" => "application/json" }, { success: true }.to_json ]
        end
      end

      it "returns the response status and body" do
        response = client.request(http_method: http_method, endpoint: endpoint, body: body)
        expect(response[:status]).to eq(200)
        expect(response[:body]).to eq({ success: true })
      end
    end

    context "when the request raises an error" do
      before do
        stubs.get(endpoint) { raise Faraday::ConnectionFailed.new("Connection error") }
      end

      it "handles the error and logs it" do
        expect { client.request(http_method: http_method, endpoint: endpoint, body: body) }.not_to raise_error
      end
    end
  end
end
