# frozen_string_literal: true

require "test_helper"

class Help::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get help_app_preference_url
    assert_response :success
  end
end
