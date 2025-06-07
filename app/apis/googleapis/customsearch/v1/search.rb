require "faraday"

module Googleapis
  module Customsearch
    module V1
        class Search < Lib::ApiResource
          def execute(query)
            request(
              http_method: :get,
              params: {
                q: query
              }
            )
          end
        end
    end
  end
end
