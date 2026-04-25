# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"

    class Sign::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
      end

      test "should get show" do
        get sign_com_preference_url(ri: "jp")

        assert_response :success
        assert_select "a[href=?]", new_sign_com_preference_email_path(ri: "jp")
      end
    end
  end
end
