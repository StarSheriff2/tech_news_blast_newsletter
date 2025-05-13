require_relative "client_spec"
require_relative "resources/chat_spec"

module Groq
  module Openai
    module V1
      class GroqApi
        def initialize(api_key:)
          @client = Client.new(api_key: api_key)
        end

        def chat
          Resources::Chat.new(@client)
        end
      end
    end
  end
end
