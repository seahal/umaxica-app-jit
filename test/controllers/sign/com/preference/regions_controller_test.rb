# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module Com
    module Preference
      class RegionsControllerTest < ActionDispatch::IntegrationTest
        include PreferenceJwtHelper

        fixtures :users, :user_telephone_statuses, :com_preferences

        setup do
          @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
          @user = users(:one)
          @user.user_telephones.create!(
            number: "+819012340002",
            user_telephone_status_id: UserTelephoneStatus::VERIFIED,
          )
          host! @host
        end

        test "PATCH update syncs region to com preference" do
          preference = com_preferences(:one)
          ComPreferenceRegion.create!(preference: preference, option_id: ComPreferenceRegionOption::JP)
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
                  headers: as_user_headers(@user, host: @host)
          end

          assert_redirected_to edit_sign_com_preference_region_url(ri: "us")

          preference.reload

          assert_equal ComPreferenceRegionOption::US, preference.com_preference_region.option_id
        end
      end
    end
  end
end
