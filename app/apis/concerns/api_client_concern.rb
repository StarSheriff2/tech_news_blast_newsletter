module ApiClientConcern
  extend ActiveSupport::Concern

  included do
    attr_reader :api_key, :adapter

    class_attribute :base_url
  end

  def initialize(api_key:, adapter: Faraday.default_adapter, stubs: nil)
    @api_key = api_key
    @adapter = adapter
    @stubs = stubs
  end

  def request(http_method:, endpoint:, body: {})
    client.public_send(http_method, endpoint, body).then do |response|
      {
        status: response.status,
        body: response.body
      }
    end
  rescue Faraday::Error => e
    raise ApiError.new(
      message: e.message,
      faraday_error_class: e.class
    )
  end

  private

  # Shared client logic, with a hook for customization
  def client
    @client ||= begin
                  Faraday.new(url: self.class.base_url, **default_options) do |config|
                    setup_shared_middlewares(config)
                    setup_custom_middlewares(config) # Hook for subclasses
                  end
                end
  end

  # Default options for Faraday
  def default_options
    {
      request: {
        open_timeout: 10,
        read_timeout: 10
      }
    }
  end

  # Shared middlewares that apply to all API clients
  def setup_shared_middlewares(config)
    config.request :json
    config.response :json, parser_options: { symbolize_names: true }
    config.response :raise_error
    config.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug
  end

  # This method should be overridden by subclasses to define API-specific behavior
  def setup_custom_middlewares(config)
    # By default, this does nothing. Subclasses can add their middlewares here.
    config.adapter adapter, @stubs
  end
end
