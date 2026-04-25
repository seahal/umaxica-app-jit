# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module Com
    module Preference
      class RegionsControllerTest < ActionDispatch::IntegrationTest
        include PreferenceJwtHelper

        fixtures :com_preferences

        setup do
          @host = ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
          @customer = create_verified_customer_with_email(
            email_address: "preference-#{SecureRandom.hex(4)}@example.com",
          )
          @customer.customer_telephones.create!(
            number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, "0")}",
            customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
          )
          host! @host
        end

        test "PATCH update syncs region to com preference and customer preference" do
          preference = com_preferences(:one)
          ComPreferenceRegion.create!(preference: preference, option_id: ComPreferenceRegionOption::JP)
          @customer.create_customer_preference!(
            region: "jp",
            language: "ja",
            timezone: "Asia/Tokyo",
            theme: "sy",
          )
          token = encode_preference_jwt(
            preferences: { "ri" => "jp" },
            host: @host,
            public_id: preference.public_id,
            preference_type: "ComPreference",
          )

          with_preference_jwt_keys(host: @host) do
            cookies[::Preference::CookieName.access] = token

            patch sign_com_preference_region_path,
                  params: { preference_region: { option_id: "us" } },
                  headers: as_customer_headers(@customer, host: @host)
          end

          assert_redirected_to edit_sign_com_preference_region_url(ri: "us")

          preference.reload
          @customer.customer_preference.reload

          assert_equal ComPreferenceRegionOption::US, preference.com_preference_region.option_id
          assert_equal "us", @customer.customer_preference.region
        end

        test "access refresh token mismatch clears cookies and returns 401" do
          # Create two different preferences
          preference1 = ComPreference.create!(
            public_id: "test_pref_#{SecureRandom.hex(4)}",
            status_id: ComPreferenceStatus::NOTHING,
            expires_at: 400.days.from_now,
          )
          preference2 = ComPreference.create!(
            public_id: "test_pref_#{SecureRandom.hex(4)}",
            status_id: ComPreferenceStatus::NOTHING,
            expires_at: 400.days.from_now,
          )

          # Create tokens for different preferences
          access_token = ::Preference::Token.encode(
            { "ri" => "jp" },
            host: @host,
            preference_type: "ComPreference",
            public_id: preference1.public_id,
            jti: SecureRandom.uuid,
          )

          refresh_token_value = "#{preference2.public_id}.#{SecureRandom.hex(16)}"

          # Request with mismatched tokens
          get edit_sign_com_preference_region_path(ri: "jp"),
              headers: as_customer_headers(@customer, host: @host),
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
