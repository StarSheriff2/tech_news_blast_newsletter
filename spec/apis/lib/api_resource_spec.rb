require 'rails_helper'

RSpec.describe Lib::ApiResource do
  let(:client) { double('Client') } # Mocked client object
  let(:api_resource) { described_class.new(client) } # Instance of the ApiResource

  describe '#initialize' do
    it 'assigns the client' do
      expect(api_resource.client).to eq(client)
    end
  end

  describe '#request' do
    it 'delegates the request to the client with the given arguments' do
      # Test arguments
      args = {
        http_method: :post,
        endpoint: "/test/endpoint",
        params: { key: "value" }
      }

      # Expect the client's `request` method to receive the args
      expect(client).to receive(:request).with(args)

      # Use reflection to test the private method
      api_resource.send(:request, **args)
    end
  end
end
