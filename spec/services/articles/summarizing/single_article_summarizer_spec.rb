require 'rails_helper'
require "yaml"

RSpec.describe Articles::Summarizing::SingleArticleSummarizer, type: :service do
  subject(:service) { described_class.new }

  describe '#call' do
    context 'when the call is successful' do
      it "returns a successful summary for the default article" do
        text = "some article "
        response_mock = double(payload:  { body:  { choices: [ { message: { content: 'This is the summary' } } ] } })

        # Stub external Groq call
        allow(Groq::Chat::Completions::Prompt).to receive(:call!)
                                                    .with(anything, anything)
                                                    .and_return(response_mock)

        result = service.call(text)

        expect(result).to be_success
        expect(result.payload).to eq("This is the summary")
      end
    end
  end
end
