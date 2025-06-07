module NewsSourcesRanking
  module Lib
    class FindNewsSites < ApplicationService
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
        response = Googleapis::CustomSearch::Search.call!(@query, connection)
        @summary = response.payload
      end
    end
  end
end
