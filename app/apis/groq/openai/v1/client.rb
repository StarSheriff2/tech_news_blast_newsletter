require "faraday"
require "faraday/retry"

module Groq
  module Openai
    module V1
          class Client
            include ApiClientConcern

            self.base_url = "https://api.groq.com/openai/v1"

            private

            def setup_custom_middlewares(config)
              config.request :authorization, :Bearer, api_key
              config.request :retry, max: 3, interval: 0.5, backoff_factor: 2,
                        retry_statuses: [ 429, 500, 502, 503, 504 ],
                        methods: [ :post ]
              super
            end
          end
    end
  end
end
