# frozen_string_literal: true

require "test_helper"

module Sign::App::In
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_app_in_passkey_url(ri: "jp")

      assert_response :success
    end
  end
end
