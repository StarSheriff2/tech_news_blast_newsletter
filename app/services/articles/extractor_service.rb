require "open-uri"

class Articles::ExtractorService < ApplicationService
  CUTOFFS =  [
    /Related (articles|stories)/i,
    /^More:/,
    /^Read more/i,
    /^Subscribe/i,
    /©/,
    /All rights reserved/i
  ].freeze

  def call(url)
    @url = url
    @doc = Nokogiri::HTML(URI.open(url))

    success extract_text_and_format
  end

  private

  def extract_text_and_format
    relevant_tags = extract_relevant_tags(find_article)
    clean_article(relevant_tags)
  end

  def find_article
    candidates = score_article_candidates

    candidates.max_by { |c| c[:score] }[:node]
  end

  def score_article_candidates
    filtered =  filter_dom_nodes
    filtered.map do |node|
      text = node.css("p").map(&:text).join(" ")
      score = text.length + (node.css("p").size * 100) # weigh paragraph count
      { node: node, score: score }
    end
  end

  def filter_dom_nodes
    keywords = %w[article content main post body story]
    @doc.css("div, section").select do |node|
      cls = node["class"].to_s.downcase
      keywords.any? { |k| cls.include?(k) }
    end
  end

  private

  def extract_relevant_tags(article_element)
    article_element.css("p, h2, h3")
  end

  def clean_article(relevant_tags)
    paragraphs = relevant_tags.map(&:text)
    cut_index    = paragraphs.index { | p | CUTOFFS.any? { | rx | p =~ rx } }
    article_text = paragraphs[0..(cut_index ? cut_index - 1 : -1)].join("")
    cut_index    = article_text.index(/\s{3,}/)
    article_text[0..(cut_index ? cut_index - 1 : -1)]
  end
end
