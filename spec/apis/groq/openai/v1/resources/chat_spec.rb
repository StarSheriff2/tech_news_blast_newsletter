require 'rails_helper'

RSpec.describe Groq::Openai::V1::Resources::Chat do
  let(:client) { double('Client') } # Mock client
  let(:chat) { described_class.new(client) } # Instance of Chat
  let(:prompt) { "Hello, AI!" } # Example prompt

  describe "#completions" do
    it "sends a POST request with the correct parameters" do
      # Expected request parameters
      expected_params = {
        http_method: :post,
        endpoint: "chat/completions",
        params: {
          model: "llama-3.3-70b-versatile",
          messages: [
                   {
                     role: "user",
                     content: prompt
                   }
                 ]
        }
      }

      # Expectation: the `request` method is called with the correct arguments
      expect(chat).to receive(:request).with(expected_params)

      # Call the method
      chat.completions(prompt)
    end
  end
end
