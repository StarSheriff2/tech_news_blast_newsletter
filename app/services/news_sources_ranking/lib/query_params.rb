module NewsSourcesRanking
  module Lib
    module QueryParams
      # This constant defines the prompt for summarizing a single article. It provides detailed instructions
      # for summarizing the text while retaining key information and preparing it for further summarization.
      def self.params
        Rails.application.credentials.google_custom_search.news_sources_ranking.params
      end
    end
  end
end
