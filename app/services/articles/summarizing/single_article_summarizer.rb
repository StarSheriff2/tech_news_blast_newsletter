module Articles
  module Summarizing
    class SingleArticleSummarizer < ApplicationService
      def call(text_information)
        @prompt ="#{Prompts::SINGLE_ARTICLE_SUMMARIZER} #{text_information}"

        summary = summarize!
        success summary
      end

      private

      def connection
        @connection ||=  Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil))
      end

      def summarize!
        Groq::Chat::Completions::Prompt.call!(@prompt, connection)
      end
    end
  end
end
