module NewsArticlesExtraction
  module Lib
    module Prompts
      # This constant defines the prompt for summarizing a single article. It provides detailed instructions
      # for summarizing the text while retaining key information and preparing it for further summarization.
      def self.articles_extractor
        Rails.application.credentials.prompts.articles_extractor
      end
    end
  end
end
