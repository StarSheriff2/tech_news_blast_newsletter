module NewsArticlesExtraction
  require "open-uri"
  require "nokogiri"
  require "addressable/uri"
  require "date"
  require "capybara"
  require "selenium-webdriver"
  require "webdrivers"

  class Extractor
    Article = Struct.new(:title, :author, :published_at, :url, :location, :source, keyword_init: true)

    def initialize(url)
      @url = url
    end

    def call
      programmatic_extraction || llm_assisted_extraction
    rescue StandardError => e
      Rails.logger.error("[NewsExtractor] Failed to scrape: #{e.message}")
      []
    end

    private

    def programmatic_extraction
      doc = fetch_direct(@url) || fetch_headless(@url)
      return unless doc

      article_nodes = doc.css('article, [class*="story"], [class*="article"], [class*="post"], [class*="entry"]')
      articles      = []
        article_nodes.each do | article |
        url = absolute_url(extract_href(article))
        next unless url

        articles <<
          {
            title:        extract_title(article).blank? ? title_from_url(url) : extract_title(article),
            author:       extract_generic(article, '[class*="author"], .byline, .contributor'),
            published_at: extract_time(article),
            url:          url,
            location:     extract_location(article),
            source:       extract_source(@url)
          }
      end

      articles.compact.uniq { | a | a[:url] }.map { | data | Article.new(**data) }

      return nil if articles.length < 6

      articles
    end

    def llm_assisted_extraction
      # TODO: Implement a retry in case the LLM output can't be parsed
      # TODO: Implement a more robust way to exrtact dates ffrom the article, like in
      # https://www.reuters.com/technology/ where it is in the url
      raw_llm_output = Lib::LlmAssistedExtractor.call(@url).payload
      raw_llm_output.blank? ? [] : LLMOutputParser.parse_yaml_output(raw_llm_output)
    end

    def fetch_direct(url)
      html = URI.open(url, "User-Agent" => "Ruby Scraper").read
      Nokogiri::HTML(html)
    rescue
      nil
    end

    def fetch_headless(url)
      session = Capybara::Session.new(:selenium_chrome_headless_stealth)
      session.visit(url)
      stabilize_dom(session)
      Nokogiri::HTML(session.html)
    rescue => e
      Rails.logger.error("Headless fetch failed: #{e.message}")
      warn "Headless fetch failed: #{e.message}"
      nil
    end

    def stabilize_dom(session)
      last_size = nil
      stable_count = 0
      10.times do
        current_size = session.evaluate_script("document.body.innerHTML.length")
        if current_size == last_size
          stable_count += 1
        else
          stable_count = 0
        end
        break if stable_count >= 3
        last_size = current_size
        sleep 0.5
      end
    end

    def extract_title(article)
      node = article.at_css('h1, h2, h3, .title, .headline, [class*="title"]')
      clean_text(node&.text)
    end

    def extract_generic(article, selector)
      node = article.at_css(selector)
      clean_text(node&.text)
    end

    def extract_time(article)
      node = article.at_css('time[datetime], time, .date, [class*="time"], [class*="date"]')
      node&.[]("datetime") || clean_text(node&.text)
    end

    def extract_location(article)
      node = article.at_css('[class*="location"], .dateline, .place')
      clean_text(node&.text)
    end

    def extract_href(article)
      article.css("a[href]").map { |a| a["href"] }
             .find { |href| href&.start_with?("/") || href&.start_with?("http") }
    end

    def absolute_url(href)
      return unless href
      href.start_with?("http") ? href : URI.join(@url, href).to_s
    rescue
      nil
    end

    def title_from_url(url)
      return unless url
      slug = URI.parse(url).path.split("/").reject(&:empty?).last
      return unless slug
      slug.gsub("-", " ").capitalize
    rescue
      nil
    end

    def extract_source(url)
      uri = URI.parse(url)
      host = uri.host.sub(/^www\./, "")
      host.split(".")[0].capitalize + " News"
    rescue
      nil
    end

    def clean_text(text)
      text&.gsub("\n", "")&.strip
    end
  end
end
