module Lib
    class ApiResource
      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      def request(**args)
        client.request(**args)
      end
    end
end
