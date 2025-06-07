require 'rails_helper'

RSpec.describe Articles::ExtractorService, type: :service do
  let(:url) { "http://example.com/article" }

  def mock_html_content(html_content)
    allow(URI).to receive(:open).with(url).and_return(StringIO.new(html_content))
  end

  describe ".call" do
    context "when extracting and formatting article text" do
      it "returns the cleaned article text" do
        html_content = <<-HTML
          <html lang="en">
            <body>
              <div class="article">
                <p>First paragraph of the article.</p>
                <p>Second paragraph of the article.</p>
                <p>Related articles</p>
              </div>
            </body>
          </html>
        HTML

        mock_html_content(html_content)
        result = described_class.call(url)

        expect(result.success?).to be true
        expect(result.payload).to eq("First paragraph of the article.Second paragraph of the article.")
      end
    end

    context "when paragraphs are preceded by 3 or more consecutive whitespace characters" do
      it "discards those paragraphs" do
        html_content_with_whitespace = <<-HTML
          <html lang="en">
            <body>
              <div class="article">
                <p>First paragraph of the article.\n\n\n</p>
                <p>Second paragraph of the article.</p>
              </div>
            </body>
          </html>
        HTML

        mock_html_content(html_content_with_whitespace)
        result = described_class.call(url)

        expect(result.success?).to be true
        expect(result.payload).to eq("First paragraph of the article.")
      end
    end
  end
end
