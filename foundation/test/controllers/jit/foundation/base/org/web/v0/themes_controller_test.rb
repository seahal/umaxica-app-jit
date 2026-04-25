# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Base::Org::Web::V0::ThemesControllerTest < ActionDispatch::IntegrationTest
      include PreferenceJwtHelper

      setup do
        _ = Preference::Base # ensure autoload of JwtConfiguration/Token defined in same file
        @host = ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
        host! @host
      end

      test "GET show without access jwt returns default theme sy" do
        cookies.delete(Preference::CookieName.access)

        get foundation.base_org_web_v0_theme_path, as: :json

        assert_response :ok
        assert_equal "sy", response.parsed_body["theme"]
      end

      test "GET show returns theme from preference jwt" do
        token = encode_preference_jwt(
          preferences: { "ct" => "dr" },
          host: @host,
          public_id: "pref-org-public-id",
        )
        cookies[Preference::CookieName.access] = token

        with_preference_jwt_keys(host: @host) do
          get foundation.base_org_web_v0_theme_path, as: :json
        end

        assert_response :ok
        assert_equal "dr", response.parsed_body["theme"]
      end

      test "PATCH update sets theme cookie and returns updated theme" do
        token = encode_preference_jwt(
          preferences: { "ct" => "dr" },
          host: @host,
          public_id: "pref-org-public-id",
        )
        cookies[Preference::CookieName.access] = token

        with_preference_jwt_keys(host: @host) do
          patch foundation.base_org_web_v0_theme_path, params: { theme: "light" }, as: :json
        end

        assert_response :ok
        assert_equal "li", response.parsed_body["theme"]
        set_cookie = response.headers["Set-Cookie"].to_s

        assert_includes set_cookie, "ct=li"
      end
    end
  end
end
