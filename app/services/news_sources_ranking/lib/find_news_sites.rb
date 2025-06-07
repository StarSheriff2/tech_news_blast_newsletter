module NewsSourcesRanking
  module Lib
    class FindNewsSites < ApplicationService
      def call(query)
        @prompt = query
        @options = { params: QueryParams.params }

        summarize!
        success @summary
      end

      private

      def connection
        @connection ||= Googleapis::Customsearch::V1::Search.new(options)
      end

      def search!
        response = Groq::Chat::Completions::Prompt.call!(@prompt, connection)
        @summary = response.payload[:body][:choices][0][:message][:content]
      end
    end
  end
end
