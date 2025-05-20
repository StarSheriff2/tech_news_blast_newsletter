module Articles
  module Summarizing
    class SingleArticleSummarizer < ApplicationService
      def call(text_information)
        @prompt ="#{Prompts.single_article_summarizer} #{text_information}"

        summarize!
        success @summary
      end

      private

      def connection
        @connection ||=  Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil))
      end

      def summarize!
        response = Groq::Chat::Completions::Prompt.call!(@prompt, connection)
        @summary = response.payload[:body][:choices][0][:message][:content]
      end
    end
  end
end
