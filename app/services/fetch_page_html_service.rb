require "open3"
require "nokogiri"

class FetchPageHtmlService
  def initialize(url)
    @url = url
  end

  def call
    html = run_python_script(@url)
    return nil unless html

    parse_with_nokogiri(html)
  end

  private

  def run_python_script(url)
    script_path = Rails.root.join("lib", "scrapers", "fetch_page_html.py")
    escaped_script = Shellwords.escape(script_path.to_s)
    escaped_url = Shellwords.escape(url)

    stdout, stderr, status = Open3.capture3("python3 #{escaped_script} #{escaped_url}")

    unless status.success?
      Rails.logger.error("Python script error: #{stderr}")
      return nil
    end

    stdout
  end

  def parse_with_nokogiri(html)
    doc = Nokogiri::HTML(html)
    doc.at("title")&.text # Example: return page title
  end
end
