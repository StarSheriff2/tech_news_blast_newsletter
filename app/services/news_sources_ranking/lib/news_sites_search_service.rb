module NewsSourcesRanking
  module Lib
    class NewsSitesSearchService < ApplicationService
      def call(query)
        @query = query
        @options = { params: QueryParams.params }

        search!
        success @summary
      end

      private

      def connection
        @connection ||= Googleapis::Customsearch::V1::CustomsearchApi.new(options: @options)
      end

      def search!
        response = Googleapis::CustomSearch::GoogleSearchService.call!(@query, connection)
        @summary = response.payload
      end
    end
  end
end
