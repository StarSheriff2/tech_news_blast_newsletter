module Articles
  module Summarizing
    class SingleArticleSummarizer < ApplicationService
      def call(text_information)
        @prompt ="#{Prompts::SINGLE_ARTICLE_SUMMARIZER} #{text_information}"

        # TODO: Handle api error responses and create specs for these services
        summarize!
        success @summary
      end

      private

      def connection
        @connection ||=  Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil))
      end

      def summarize!
        @summary = Groq::Chat::Completions::Prompt.call!(@prompt, connection)
      end
    end
  end
end
