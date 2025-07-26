require "yaml"
require "json"

module LLMOutputParser
  class << self
    def parse_yaml_output(yaml_string)
      cleaned = clean_yaml(yaml_string)
      YAML.safe_load(cleaned, permitted_classes: [ Date, Time, Symbol ], aliases: true)
    rescue Psych::SyntaxError => e
      Rails.logger.warn("YAML parsing failed: #{e.message}")
      raise e
    end

    private

    def clean_yaml(yaml_string)
      cleaned = yaml_string
                  .gsub(/```yaml|```/, "")         # Remove markdown code block fences
                  .gsub(/[“”]/, '"')               # Replace smart quotes with straight quotes
                  .gsub(/[‘’]/, "'")               # Replace smart apostrophes
                  .gsub(/\bnull\b/, "null")        # Normalize `null` values
                  .gsub(/\t/, "  ")                # Fix indentation by replacing tabs with spaces
                  .gsub(/^\xEF\xBB\xBF/, "")       # Remove invalid characters like BOM (Byte Order Mark)
                  .sub(/^.*?(-\s)/m, '\1')         # Remove anything before the first "- " list item
                  .strip

      Rails.logger.info("Cleaned YAML:
#{cleaned}")
      cleaned
    end
  end
end
