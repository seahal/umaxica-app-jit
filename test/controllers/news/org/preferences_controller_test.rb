# frozen_string_literal: true

require "test_helper"

class News::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get news_org_preference_url
    assert_response :success
  end
end
