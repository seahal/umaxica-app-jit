# frozen_string_literal: true

require "test_helper"

module Net
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_net_session_url
      assert_response :success
      assert_select "a[href=?]", new_net_session_email_path
      assert_select "a[href=?]", new_net_session_apple_path
      assert_select "a[href=?]", new_net_session_google_path
      assert_select "a[href=?]", new_net_session_passkey_path
      assert_select "a[href=?]", new_net_session_password_path
      assert_select "a[href=?]", new_net_registration_path
      assert_select "a[href=?]", net_root_path, count: 2
    end
  end
end
