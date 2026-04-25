# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"

    module Sign
      module Org
        module Preference
          class RegionsControllerTest < ActionDispatch::IntegrationTest
            fixtures :staffs, :staff_preferences

            setup do
              @host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
              @staff = staffs(:one)
              host! @host
            end

            test "PATCH update syncs region to staff preference" do
              patch sign_org_preference_region_path,
                    params: { preference_region: { option_id: "us" } },
                    headers: as_staff_headers(@staff, host: @host)

              assert_redirected_to edit_sign_org_preference_region_url(ri: "us")

              @staff.staff_preference.reload

              assert_equal "us", @staff.staff_preference.region
            end

            test "access refresh token mismatch clears cookies and returns 401" do
              # Create two different preferences
              preference1 = OrgPreference.create!(
                public_id: "test_pref_#{SecureRandom.hex(4)}",
                status_id: OrgPreferenceStatus::NOTHING,
                expires_at: 400.days.from_now,
              )
              preference2 = OrgPreference.create!(
                public_id: "test_pref_#{SecureRandom.hex(4)}",
                status_id: OrgPreferenceStatus::NOTHING,
                expires_at: 400.days.from_now,
              )

              # Create tokens for different preferences
              access_token = ::Preference::Token.encode(
                { "ri" => "jp" },
                host: @host,
                preference_type: "OrgPreference",
                public_id: preference1.public_id,
                jti: SecureRandom.uuid,
              )

              refresh_token_value = "#{preference2.public_id}.#{SecureRandom.hex(16)}"

              # Request with mismatched tokens
              get edit_sign_org_preference_region_path(ri: "jp"),
                  headers: as_staff_headers(@staff, host: @host),
                  env: { "HTTP_COOKIE" => "#{::Preference::CookieName.access}=#{access_token}; " \
                                          "#{::Preference::CookieName.refresh}=#{refresh_token_value}" }

              assert_response :unauthorized

              # Verify cookies are cleared
              set_cookie = response.headers["Set-Cookie"]
              cookie_lines = set_cookie.is_a?(Array) ? set_cookie : set_cookie.to_s.split("\n")

              assert cookie_lines.any? { |line|
                line.include?("#{::Preference::CookieName.refresh}=") && line.include?("max-age=0")
              }, "refresh cookie should be cleared"
            end
          end
        end
      end
    end
  end
end
