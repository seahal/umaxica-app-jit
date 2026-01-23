# frozen_string_literal: true

require "test_helper"

class Sign::App::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_app_in_sessions_show_url
    assert_response :success
  end

  test "should get update" do
    get sign_app_in_sessions_update_url
    assert_response :success
  end
end
