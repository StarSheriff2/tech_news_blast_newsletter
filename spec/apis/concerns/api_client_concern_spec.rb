require 'rails_helper'
require 'faraday'

RSpec.describe ApiClientConcern, type: :module do
  # Define a dummy client class to include the concern
  before do
    stub_const('TestApiClient', Class.new)
    TestApiClient.include(ApiClientConcern)
    TestApiClient.base_url = "https://api.example.com/v1"
  end

  after do
    # Raises an error if any of the stubbed calls have not been made for each example
    stubs.verify_stubbed_calls
  end

  let(:api_key) { "test_api_key" }
  let(:adapter) { :test }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  let(:test_client) { TestApiClient.new(api_key: api_key, adapter: adapter, stubs: stubs) }

  describe '#initialize' do
    it 'initializes with api_key, adapter, and stubs' do
      expect(test_client.api_key).to eq(api_key)
      expect(test_client.adapter).to eq(adapter)
    end
  end

  describe '#request' do
    let(:response_body) { { message: "success" }.to_json }

    it 'sends a request and returns the response' do
      stubs.get('/test_endpoint') { [ 200, {}, response_body ] }

      result = test_client.request(http_method: :get, endpoint: "/test_endpoint")
      expect(result[:status]).to eq(200)
      expect(result[:body]).to eq(response_body)
    end

    it 'raises an ApiError for Faraday errors' do
      stubs.get('/test_endpoint') { raise Faraday::TimeoutError, "Timeout" }

      expect {
        test_client.request(http_method: :get, endpoint: "/test_endpoint")
      }.to raise_error(ApiError, /Timeout/)
    end

    it 'handles 404 error' do
      stubs.get('/test_endpoint') do
        [
          404,
          { 'Content-Type': 'application/javascript' },
          '{}'
        ]
      end

      expect {
        test_client.request(http_method: :get, endpoint: "/test_endpoint")
      }.to raise_error(ApiError, /the server responded with status 404/) do |error|
        expect(error.faraday_error_class).to eq Faraday::ResourceNotFound
      end
    end

    it 'handles exception' do
      stubs.get("/test_endpoint") do
        raise Faraday::ConnectionFailed
      end

      expect {
        test_client.request(http_method: :get, endpoint: "/test_endpoint")
      }.to raise_error(ApiError) do |error|
        expect(error.faraday_error_class).to eq Faraday::ConnectionFailed
      end
    end
  end

  describe '#client' do
    it 'creates a Faraday client with the correct base URL' do
      client = test_client.send(:client)
      expect(client.url_prefix.to_s).to eq("https://api.example.com/v1")
    end

    it 'uses shared middlewares' do
      client = test_client.send(:client)

      # Check that shared middlewares are added and ordered
      expect(client.builder.handlers).to include(
                                           Faraday::Request::Json, # Shared middleware
                                           Faraday::Response::RaiseError, # Shared middleware
                                           Faraday::Response::Logger # Shared middleware
                                         )
    end

    it 'allows subclasses to override setup_custom_middlewares' do
      # Define a subclass that overrides setup_custom_middlewares
      stub_const('CustomApiClient', Class.new(TestApiClient))
      CustomApiClient.class_eval do
        private

        def setup_custom_middlewares(config)
          config.request :url_encoded
        end
      end

      custom_client = CustomApiClient.new(api_key: api_key)
      client = custom_client.send(:client)

      expect(client.builder.handlers).to include(Faraday::Request::UrlEncoded)
    end
  end
end
