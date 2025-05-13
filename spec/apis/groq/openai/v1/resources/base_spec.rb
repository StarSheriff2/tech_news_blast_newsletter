module Groq
  module Openai
    module V1
      module Resources
        class Base
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
    end
  end
end
