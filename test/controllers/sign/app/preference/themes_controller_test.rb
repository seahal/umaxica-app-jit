# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module App
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        fixtures :users, :user_preferences

        setup do
          @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
          @user = users(:one)
          host! @host
        end

        test "PATCH update returns updated preference payload and syncs auth preference" do
          patch sign_app_preference_theme_path,
                params: { preference_colortheme: { option_id: "dr" } },
                headers: as_user_headers(@user, host: @host),
                as: :json

          assert_response :ok
          assert_equal "dr", response.parsed_body.dig("preference", "ct")
          assert_equal "ja", response.parsed_body.dig("preference", "lx")
          assert_includes response.headers["Set-Cookie"].to_s, "#{::Preference::CookieName.access}="

          @user.user_preference.reload

          assert_equal "dr", @user.user_preference.theme
        end

        test "access refresh token mismatch clears cookies and returns 401" do
          # Create two different preferences
          preference1 = AppPreference.create!(
            public_id: "test_pref_#{SecureRandom.hex(4)}",
            status_id: AppPreferenceStatus::NOTHING,
            expires_at: 400.days.from_now,
          )
          preference2 = AppPreference.create!(
            public_id: "test_pref_#{SecureRandom.hex(4)}",
            status_id: AppPreferenceStatus::NOTHING,
            expires_at: 400.days.from_now,
          )

          # Create tokens for different preferences
          access_token = ::Preference::Token.encode(
            { "ri" => "jp" },
            host: @host,
            preference_type: "AppPreference",
            public_id: preference1.public_id,
            jti: SecureRandom.uuid,
          )

          refresh_token_value = "#{preference2.public_id}.#{SecureRandom.hex(16)}"

          # Request with mismatched tokens
          get edit_sign_app_preference_theme_path(ri: "jp"),
              headers: as_user_headers(@user, host: @host),
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
