# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_org_in_sessions_show_url
    assert_response :success
  end

  test "should get update" do
    get sign_org_in_sessions_update_url
    assert_response :success
  end
end
