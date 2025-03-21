# frozen_string_literal: true

require "test_helper"

module Www::App
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_www_app_session_url
      assert_response :success
      # assert_select "a[href=?]", new_app_session_email_path
      # assert_select "a[href=?]", new_app_session_apple_path
      # assert_select "a[href=?]", new_app_session_google_path
      # assert_select "a[href=?]", new_app_session_passkey_path
      # assert_select "a[href=?]", new_app_session_password_path
      # assert_select "a[href=?]", new_app_registration_path
      # assert_select "a[href=?]", www_app_root_path, count: 2
    end
  end
end
