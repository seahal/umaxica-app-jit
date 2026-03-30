# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  test "should get show" do
    get sign_app_preference_url(ri: "jp")

    assert_response :success
    assert_select "a[href=?]", edit_sign_app_preference_email_path(ri: "jp")
  end
end
