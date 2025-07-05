require "yaml"
require "json"

module LLMOutputParser
  class << self
    def parse_yaml_output(yaml_string)
      cleaned = clean_yaml(yaml_string)
      YAML.safe_load(cleaned, permitted_classes: [ Date, Time, Symbol ], aliases: true)
    rescue Psych::SyntaxError => e
      Rails.logger.warn("YAML parsing failed: #{e.message}")
      []
    end

    private

    def clean_yaml(yaml_string)
      yaml_string
        .gsub(/```yaml|```/, "")         # Remove markdown code block fences
        .gsub(/[“”]/, '"')               # Replace smart quotes with straight quotes
        .gsub(/[‘’]/, "'")               # Replace smart apostrophes
        .sub(/^.*?(-\s)/m, '\1')         # Remove anything before the first "- " list item
        .strip
    end
  end
end
