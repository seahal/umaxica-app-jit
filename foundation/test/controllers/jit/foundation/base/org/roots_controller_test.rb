# typed: false
# frozen_string_literal: true

    require "test_helper"

    module Base::Org
      class RootsControllerTest < ActionDispatch::IntegrationTest
        include RootThemeCookieHelper

        FOUNDATION_BASE_ORG_URL = ENV.fetch("FOUNDATION_BASE_ORG_URL", ENV.fetch("BACK_STAFF_URL", "back-staff.example.com"))

        test "should redirect to FOUNDATION_BASE_ORG_URL" do
          get foundation.base_org_root_url

          assert_response :success
        end

        test "renders layout contract" do
          get foundation.base_org_root_url

          assert_response :success
          assert_layout_contract
        end

        test "generates sha3-384 token digest on root" do
          get foundation.base_org_root_url

          assert_response :success
          assert_equal 48, OrgPreference.order(:created_at).last.token_digest.bytesize
        end

        test "sets theme cookie" do
          assert_theme_cookie_for(
            host: "org.localhost",
            path: :base_org_root_path,
            label: "core org root",
            ri: "jp",
          )
        end
      end
    end
  end
end
