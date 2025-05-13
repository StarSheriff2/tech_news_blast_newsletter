require "faraday"

module Groq
  module Openai
    module V1
      module Resources
        class Chat < Base
            def completions(prompt)
              request(
                http_method: :post,
                endpoint: "chat/completions",
                body: {
                  model: "llama-3.3-70b-versatile",
                  messages: [ {
                                role: "user",
                                content: prompt
                              } ]
                }
              )
            end
        end
      end
    end
  end
end
