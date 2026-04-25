# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module Org
    module Preference
      module Region
        class TimezonesControllerTest < ActionDispatch::IntegrationTest
          fixtures :staffs, :staff_preferences

          setup do
            @host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
            @staff = staffs(:one)
            host! @host
          end

          test "PATCH update syncs timezone to staff preference" do
            patch sign_org_preference_region_timezone_path,
                  params: { preference_timezone: { option_id: OrgPreferenceTimezoneOption::ETC_UTC } },
                  headers: as_staff_headers(@staff, host: @host)

            assert_redirected_to edit_sign_org_preference_region_timezone_url

            @staff.staff_preference.reload

            assert_equal "Etc/UTC", @staff.staff_preference.timezone
          end

          test "GET edit returns unauthorized when refresh token is invalid" do
            get edit_sign_org_preference_region_timezone_path(ri: "jp"),
                headers: as_staff_headers(@staff, host: @host),
                env: {
                  "HTTP_COOKIE" => "#{::Preference::CookieName.refresh}=bogus",
                }

            assert_response :unauthorized
          end
        end
      end
    end
  end
end
