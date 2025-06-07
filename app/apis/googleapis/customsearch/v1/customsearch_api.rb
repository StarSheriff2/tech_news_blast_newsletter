require_relative "client"

module Googleapis
  module Customsearch
    module V1
      class CustomsearchApi
        def initialize(options:)
          @client = Client.new(options: options)
        end

        def search
          Search.new(@client)
        end
      end
    end
  end
end
