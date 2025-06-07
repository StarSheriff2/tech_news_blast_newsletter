module Googleapis
  module CustomSearch
    class GoogleSearchService < ApplicationService
      def call(query, client)
        @query = query
        @client = client

        response = @client.search.execute(@query)
        success response
      end
    end
  end
end
