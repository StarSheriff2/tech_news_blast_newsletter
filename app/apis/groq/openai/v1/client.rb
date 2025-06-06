require "faraday"

module Groq
  module Openai
    module V1
          class Client
            include ApiClientConcern

            self.base_url = "https://api.groq.com/openai/v1"

            private

            def setup_custom_middlewares(config)
              config.request :authorization, :Bearer, api_key
              super
            end
          end
    end
  end
end
