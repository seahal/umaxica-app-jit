# frozen_string_literal: true

# Load environment
require_relative "config/environment"

# Set env vars as in test_helper (just to be sure, though they should be set by ENV)
ENV["APEX_CORPORATE_URL"] ||= "com.localhost"

include Rails.application.routes.url_helpers

begin
  puts I18n.t("debug_url.generating")
  url = apex_com_preference_url
  puts I18n.t("debug_url.generated", url: url.inspect)
rescue => e
  puts I18n.t("debug_url.error", class: e.class, message: e.message)
  puts e.backtrace
end
