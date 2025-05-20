module Articles
  module Summarizing
    module Prompts
      # This constant defines the prompt for summarizing a single article. It provides detailed instructions
      # for summarizing the text while retaining key information and preparing it for further summarization.
      def self.single_article_summarizer
        Rails.application.credentials.prompts.single_article_summarizer
      end
    end
  end
end
