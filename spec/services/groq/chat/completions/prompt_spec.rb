require 'rails_helper'
require 'support/vcr_helper'

RSpec.describe Groq::Chat::Completions::Prompt, type: :service do
  subject(:service) { described_class.new }
  let(:prompt) { "Tell me who is considered the father of LLMs." }
  let(:client) { Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil)) }

  describe '#call' do
    context 'when the call is successful' do
      it 'returns an 200 status code' do
        result = VCR.use_cassette("successful chat completions prompt".parameterize.underscore) do
          service.call(prompt, client)
        end

        expect(result.payload[:status]).to eq 200
        expect(result.payload[:body].keys).to eq([ :id, :object, :created, :model, :choices, :usage, :usage_breakdown, :system_fingerprint, :x_groq ])
      end
    end
  end
end
