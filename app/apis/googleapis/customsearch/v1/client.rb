require "faraday"

module Googleapis
  module Customsearch
    module V1
      class Client
        include ApiClientConcern

        self.base_url = "https://customsearch.googleapis.com/customsearch/v1"

        private

        def setup_custom_middlewares(config)
          super
        end
      end
    end
  end
end
