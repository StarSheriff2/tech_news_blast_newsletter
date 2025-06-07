require "faraday"

module Groq
  module Openai
    module V1
      module Resources
        class Chat < Lib::ApiResource
            def completions(prompt)
              request(
                http_method: :post,
                endpoint: "chat/completions",
                params: {
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
