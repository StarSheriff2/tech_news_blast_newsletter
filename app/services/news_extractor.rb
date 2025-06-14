require "open-uri"
require "nokogiri"
require "addressable/uri"
require "date"
require "capybara"
require "selenium-webdriver"
require "webdrivers"

class NewsExtractor
  MIN_SIBLINGS             = 4
  MAX_RECURSION            = 6
  SHORT_TITLE              = 15
  SECTION_DEPTH_THRESHOLD  = 2
  BLACKLIST_CLASSES        = %w[nav footer sidebar menu header]
  FALLBACK_SELECTORS       = [
    "article",
    '[itemtype="http://schema.org/NewsArticle"]',
    '[itemtype="https://schema.org/NewsArticle"]',
    # "[class*='story']",
    ".news", ".post", ".teaser", ".listing-item", ".entry"
  ].freeze

  include CapybaraHelpers
  # selectors for date elements
  # DATE_SELECTORS = [
  #   "time[datetime]",
  #   ".date", ".dateline", ".published", ".timestamp"
  # ].freeze
  # attr_reader :url

  def initialize(url)
    @url         = url
    @domain      = URI.parse(url).yield_self { |u| "#{u.scheme}://#{u.host}" }
  end

  # Public method to run extraction
  def extract
    doc = fetch_direct || fetch_headless
    [] unless doc

    []
    # clusters = build_clusters(doc)
    # scored  = score_and_filter_clusters(clusters)
    # nodes   = pick_best_cluster(scored) || doc.css(FALLBACK_SELECTORS.join(","))
    # nodes.uniq.map { |node| extract_from_node(node) }.compact
  end

  private

  def fetch_direct
    html = URI.open(@url, "User-Agent" => "Ruby/#{RUBY_VERSION}") { |f| f.read }
    Nokogiri::HTML(html)
  rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED, Net::OpenTimeout
    nil
  end

  def fetch_headless
    session = Capybara::Session.new(:selenium_chrome_headless_stealth)
    session.visit(@url)
    # # Optional: wait for body content to settle
    # wait_for_stable_dom(session, timeout: 15)
    # Wait until DOM stabilizes (for SPAs or slow-rendering pages)
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

    html = session.html
    if html.strip.size < 5000 # arbitrary threshold
      puts "Warning: HTML looks incomplete"
    end

    Nokogiri::HTML(session.html)
  rescue => e
    Rails.logger.error("Headless fetch failed: #{e.message}")
    warn "Headless fetch failed: #{e.message}"
    nil
  end

  def extract_from_node(node)
    link_elem = node.at_css("a[href]") or return
    href      = link_elem["href"]
    link      = Addressable::URI.join(@url, href).to_s rescue href

    # title: prefer heading, then link text
    if (h = node.at_css("h1,h2,h3"))
      title = h.text.strip
    else
      title = link_elem.text.strip
    end
    return nil if title.empty?

    # date same as before
    if (t = node.at_css("time[datetime]"))
      date = t["datetime"]
    else
      date = node.at_css("time, .date, .timestamp, .pubdate, .dateline")&.text&.strip
    end

    { title: title, link: link, date: date }
  end
end
