module Googleapis
  module CustomSearch
    class Search < ApplicationService
      # API_KEY = ENV["GOOGLE_API_KEY"]
      # CX = ENV["GOOGLE_CX_ID"]

      def call(query, client)
        @query = query
        @client = client

        response = @client.search(@query)
        success response
      end
    end
  end
end
