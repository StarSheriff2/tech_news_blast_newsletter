module ApiClientConcern
  extend ActiveSupport::Concern

  included do
    attr_reader :api_key, :adapter

    class_attribute :base_url, :options
  end

  def initialize(api_key: nil, adapter: Faraday.default_adapter, stubs: nil, options: {})
    @api_key = api_key
    @adapter = adapter
    @stubs = stubs
    @options = default_options.merge(options)
  end

  # Note: Params refers to either query params or body params
  def request(http_method:, endpoint: nil, params: nil, headers: nil)
    client.public_send(http_method, endpoint, params, headers).then do |response|
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
                  Faraday.new(url: self.class.base_url, **@options) do |config|
                    setup_shared_middlewares(config)
                    setup_custom_middlewares(config) # Hook for subclasses
                  end
                end
  end

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
