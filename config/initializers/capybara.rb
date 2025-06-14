# require "capybara/cuprite"

# Capybara.register_driver :cuprite_real_profile do |app|
#   Capybara::Cuprite::Driver.new(
#     app,
#     browser_path: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
#     logger: STDERR,
#     timeout: 60,
#     window_size: [ 1200, 800 ],
#     browser_options: {
#       'no-sandbox': nil,
#       'disable-gpu': nil,
#       'user-agent': "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/115 Safari/537.36"
#     },
#     inspector: true,
#     headless: false,
#     user_data_dir: "/path/to/your/chrome/profile",
#     skip_image_loading: true,
#     js_errors: false
#   )
# end
# Capybara.javascript_driver = :cuprite_real_profile
#

require "webdrivers"
Webdrivers::Chromedriver.required_version = "137.0.7151.70"
require "selenium-webdriver"
require "capybara"

# Register standard Chrome driver (non-headless)
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome for Testing" # optional
  options.add_argument("--disable-blink-features=AutomationControlled")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Register headless version
Capybara.register_driver :selenium_chrome_headless_stealth do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.binary = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome for Testing" # optional
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")
  options.add_argument("--remote-debugging-port=9222")

  # Fake user agent (realistic and common)
  options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Safari/537.36")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Set the defaults
Capybara.default_driver = :selenium_chrome_headless_stealth
Capybara.javascript_driver = :selenium_chrome_headless_stealth
Capybara.default_max_wait_time = 20
