module Articles
  module Summarizing
    class SingleArticleSummarizer < ApplicationService
      def call(text_information)
        @connection = Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil))

        prompt ="#{Prompts::SINGLE_ARTICLE_SUMMARIZER} #{text_information}"
        success Groq::Chat::Completions::Prompt.call(prompt, @connection)
      end
    end
  end
end
