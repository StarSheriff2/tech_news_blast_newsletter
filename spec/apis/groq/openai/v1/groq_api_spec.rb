require 'rails_helper'

RSpec.describe Groq::Openai::V1::GroqApi do
  let(:api_key) { "test_api_key" }
  let(:groq_api) { described_class.new(api_key: api_key) }

  describe "#initialize" do
    it "initializes the client with the provided api_key" do
      client = groq_api.instance_variable_get(:@client)
      expect(client).to be_a(Groq::Openai::V1::Client)
      expect(client.api_key).to eq(api_key)
    end
  end

  describe "#chat" do
    it "returns an instance of Resources::Chat with the correct client" do
      chat_resource = groq_api.chat
      expect(chat_resource).to be_a(Groq::Openai::V1::Resources::Chat)
      client = chat_resource.instance_variable_get(:@client)
      expect(client).to be_a(Groq::Openai::V1::Client)
      expect(client.api_key).to eq(api_key)
    end
  end
end
