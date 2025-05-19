require 'rails_helper'
require 'vcr_helper'

RSpec.describe Groq::Chat::Completions::Prompt, type: :service do
  subject { described_class }
  let!(:prompt) { "Tell me who is considered the father of LLMs." }

  describe '#call' do
    context 'when the call is successful' do
      let(:client) { Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil)) }
      it 'returns an 200 status code' do
        result = VCR.use_cassette("successful chat completions prompt".parameterize.underscore) do
          subject.call(prompt, client)
        end

        expect(result.payload[:status]).to eq 200
        expect(result.payload[:body].keys).to eq([ :id, :object, :created, :model, :choices, :usage, :usage_breakdown, :system_fingerprint, :x_groq ])
      end
    end

    context 'when the call is unsuccessful' do
      let(:client) { Groq::Openai::V1::GroqApi.new(api_key: 'invalid_key') }
      it 'returns an error message' do
        result = VCR.use_cassette("unsuccessful chat completions prompt".parameterize.underscore) do
          subject.call(prompt, client)
        end

        expect(result.success).to be_falsey
        expect(result.error.class).to eq(ApiError)
        expect(result.error.message).to eq("the server responded with status 401")
      end
    end
  end
end
