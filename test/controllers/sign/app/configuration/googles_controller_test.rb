# frozen_string_literal: true

require "test_helper"
require "base64"

module Sign::App::Configuration
  class GooglesControllerTest < ActionDispatch::IntegrationTest
    fixtures :users, :user_statuses

    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      @user = users(:one)
      @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
    end

    test "should get show when logged in" do
      get sign_app_configuration_google_url(ri: "jp"), headers: @headers
      assert_response :success
    end

    test "should redirect show when not logged in" do
      get sign_app_configuration_google_url(ri: "jp")
      rt = Base64.urlsafe_encode64(sign_app_configuration_google_url(ri: "jp"))
      assert_redirected_to new_sign_app_in_url(rt: rt, host: ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost"))
    end
  end
end
