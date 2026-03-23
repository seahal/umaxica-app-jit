# typed: false
# frozen_string_literal: true

require "test_helper"

module Apex
  module App
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        fixtures :users, :user_preferences

        setup do
          @host = ENV.fetch("APEX_SERVICE_URL", "app.localhost")
          @user = users(:one)
          host! @host
        end

        test "PATCH update returns updated preference payload and syncs auth preference" do
          patch apex_app_preference_theme_path,
                params: { preference_colortheme: { option_id: "dr" } },
                headers: as_user_headers(@user, host: @host),
                as: :json

          assert_response :ok
          assert_equal "dr", response.parsed_body.dig("preference", "ct")
          assert_equal "ja", response.parsed_body.dig("preference", "lx")
          assert_includes response.headers["Set-Cookie"].to_s, "#{::Auth::Base::ACCESS_COOKIE_KEY}="

          @user.user_preference.reload

          assert_equal "dr", @user.user_preference.theme
        end
      end
    end
  end
end
