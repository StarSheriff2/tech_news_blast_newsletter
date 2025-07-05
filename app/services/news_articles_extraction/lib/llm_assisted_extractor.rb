module NewsArticlesExtraction
  module Lib
    class LlmAssistedExtractor < ApplicationService
      def call(url)
        @prompt ="#{Prompts.articles_extractor} '#{url}'"

        extract!
        success @result
      end

      private

      def connection
        @connection ||=  Groq::Openai::V1::GroqApi.new(api_key: ENV.fetch("GROQ_API_KEY", nil))
      end

      def extract!
        response = Groq::Chat::Completions::GroqPromptService.call!(@prompt, connection)
        @result = response.payload[:body][:choices][0][:message][:content]
      end
    end
  end
end
