# typed: false
# frozen_string_literal: true

require "test_helper"

module Apex
  module App
    module Preference
      class CookiesControllerTest < ActionDispatch::IntegrationTest
        fixtures :users, :user_preferences

        setup do
          @host = ENV.fetch("APEX_SERVICE_URL", "app.localhost")
          @user = users(:one)
          host! @host
        end

        test "PATCH update returns updated preference payload and syncs consent" do
          patch apex_app_preference_cookie_path,
                params: {
                  preference_cookie: {
                    consented: true,
                    functional: true,
                    performant: true,
                    targetable: false,
                  },
                },
                headers: as_user_headers(@user, host: @host),
                as: :json

          assert_response :ok
          assert response.parsed_body.dig("preference", "consented")
          assert response.parsed_body.dig("preference", "functional")
          assert_includes response.headers["Set-Cookie"].to_s, "#{::Auth::Base::ACCESS_COOKIE_KEY}="

          @user.user_preference.reload

          assert @user.user_preference.consented
          assert @user.user_preference.functional
          assert @user.user_preference.performant
          assert_not @user.user_preference.targetable
        end
      end
    end
  end
end
