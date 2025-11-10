# frozen_string_literal: true

require "test_helper"

class Bff::App::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "GET edit renders successfully" do
    get edit_bff_app_preference_email_url(id: 1)

    assert_response :success
  end

  test "GET edit renders form with region language and timezone selects" do
    get edit_bff_app_preference_email_url(id: 1)

    assert_response :success
    assert_select "select[name='region']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end

  test "PATCH with language normalizes to uppercase and stores in session" do
    patch bff_app_preference_email_url(id: 1), params: { language: "ja" }

    assert_response :redirect
    assert_equal "JA", session[:language]
  end

  test "PATCH with timezone stores timezone identifier in session" do
    patch bff_app_preference_email_url(id: 1), params: { timezone: "Asia/Tokyo" }

    assert_response :redirect
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  test "PATCH with unsupported language returns unprocessable entity" do
    patch bff_app_preference_email_url(id: 1), params: { language: "invalid" }

    assert_response :unprocessable_content
  end

  test "PATCH with invalid timezone returns unprocessable entity" do
    patch bff_app_preference_email_url(id: 1), params: { timezone: "Invalid/Timezone" }

    assert_response :unprocessable_content
  end

  test "PATCH with multiple params updates session and redirects" do
    patch bff_app_preference_email_url(id: 1), params: { region: "US", language: "EN", timezone: "Asia/Tokyo" }

    assert_response :redirect
    assert_equal "US", session[:region]
    assert_equal "EN", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
  end
end
