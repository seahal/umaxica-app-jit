# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"

    class Sign::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
      end

      test "should get show" do
        get sign_org_preference_url(ri: "jp")

        assert_response :success
        assert_select "a[href=?]", edit_sign_org_preference_region_path(ri: "jp")
      end
    end
  end
end
