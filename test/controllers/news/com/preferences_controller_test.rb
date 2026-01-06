# frozen_string_literal: true

require "test_helper"

class News::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get news_com_preference_url
    assert_response :success
  end
end
