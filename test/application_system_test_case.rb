# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # if ENV["CAPYBARA_SERVER_PORT"]
  #   served_by host: "api", port: ENV["CAPYBARA_SERVER_PORT"]
  #
  #   driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
  #     browser: :remote,
  #     url: "http://#{ENV['SELENIUM_HOST']}:4444"
  #   }
  # else
  #   driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  # end
  #
  url = ENV.fetch("SELENIUM_REMOTE_URL", nil)
  options = if url
              { browser: :remote, url: url }
            else
              { browser: :chrome }
            end
  driven_by :selenium, using: :headless_chrome, options: options
end
