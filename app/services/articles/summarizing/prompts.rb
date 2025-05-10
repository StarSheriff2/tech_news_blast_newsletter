module Articles
  module Summarizing
    module Prompts
      SINGLE_ARTICLE_SUMMARIZER = "Summarize the following text by 90%, while keeping the key ideas, events,
and dates. The text will always be about technology, tech market, and other related content.
Take into consideration the text source, author, date and content type.
The content type can be an article, news, rss feed, essay or even a transcription of a podcast, video, talk, interview, discourse, etc....
I am sharing with you everything in the following format: article text, author, content type, content title, date it was published, source,
media type, and website name. The summary will be used later
on by another summarizer, who will take different article summaries and summarize them into a single text, condensing all the information
into a cohesive text that will be used for a daily email blast newsletter.".freeze
    end
  end
end
