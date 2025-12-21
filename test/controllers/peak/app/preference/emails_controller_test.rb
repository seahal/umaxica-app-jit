# frozen_string_literal: true

require "test_helper"

# Note: This controller exists but has no route defined (no edit_peak_app_preference_email_url)
# The controller uses PreferenceRegions concern but routes are not configured
# Skipping tests until routes are configured
class Peak::App::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  # Tests would go here once routes are configured
end
