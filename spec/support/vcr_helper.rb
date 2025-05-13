require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :faraday

  # saves the log of a call, it will log debug output to a file,
  # useful to troubleshoot what VCR is doing
  config.debug_logger = File.open('vcr.log', 'w')

  # filter sensitive data so it is censored when saved
  config.filter_sensitive_data('<< REDACTED >>') do |interaction|
    interaction.request.headers['Authorization'].first
  end
end
