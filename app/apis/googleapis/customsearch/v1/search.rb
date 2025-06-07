require "faraday"

module Googleapis
  module Customsearch
    module V1
        class Search < Base
          def execute
            request(
              http_method: :get
            )
          end
        end
    end
  end
end
