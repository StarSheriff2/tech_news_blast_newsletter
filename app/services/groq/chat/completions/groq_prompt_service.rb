module Groq
  module Chat
    module Completions
      class GroqPromptService < ApplicationService
        def call(prompt, client)
          @prompt = prompt
          @client = client

          response = @client.chat.completions(@prompt)
          success response
        end
      end
    end
  end
end
