# frozen_string_literal: true

require "test_helper"
require "json"

module Sign
  module App
    class DefaultUrlOptionsTest < ActionDispatch::IntegrationTest
      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options includes preference parameters from cookie" do
        # Set preference cookie
        preference_data = { "lx" => "en", "ri" => "us", "tz" => "utc", "ct" => "dr" }
        cookies.signed[:root_app_preferences] = preference_data.to_json

        # Make request that triggers redirect
        patch sign_app_preference_region_url, params: { region: "US" }

        # Verify redirect includes URL parameters from cookie
        assert_redirected_to edit_sign_app_preference_region_url(lx: "en", ri: "us", tz: "utc")
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options falls back to defaults when cookie is not present" do
        # No cookie set - should use default values
        get sign_app_preference_url

        assert_response :success

        # Check that links in the page include default parameters
        assert_select "a[href*='lx=ja']", minimum: 1
        assert_select "a[href*='ri=jp']", minimum: 1
        assert_select "a[href*='tz=jst']", minimum: 1
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options updates after preference change" do
        # Initially set to Japanese preferences
        patch sign_app_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }
        assert_redirected_to edit_sign_app_preference_region_url(lx: "ja", ri: "jp", tz: "asia/tokyo")

        follow_redirect!
        assert_response :success

        # Change to English/US preferences
        patch sign_app_preference_region_url, params: { region: "US", language: "EN", timezone: "Etc/UTC" }
        assert_redirected_to edit_sign_app_preference_region_url(lx: "en", ri: "us", tz: "etc/utc")

        # Verify cookie was updated with new preferences
        cookie_data = JSON.parse(cookies.signed[:root_app_preferences])
        assert_equal "en", cookie_data["lx"]
        assert_equal "us", cookie_data["ri"]
        assert_equal "utc", cookie_data["tz"]
      end
      # rubocop:enable Minitest/MultipleAssertions

      test "default_url_options handles malformed cookie gracefully" do
        # Set invalid JSON in cookie
        cookies.signed[:root_app_preferences] = "invalid json"

        # Should not raise error and fall back to defaults
        get sign_app_preference_url

        assert_response :success
      end

      test "default_url_options handles non-hash cookie value gracefully" do
        # Set non-hash value in cookie
        cookies.signed[:root_app_preferences] = "just a string"

        # Should not raise error and fall back to defaults
        get sign_app_preference_url

        assert_response :success
      end

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options preserves theme parameter in cookie but not in URL" do
        # Set preference cookie with theme
        preference_data = { "lx" => "ja", "ri" => "jp", "tz" => "jst", "ct" => "dr" }
        cookies.signed[:root_app_preferences] = preference_data.to_json

        # Make request
        patch sign_app_preference_region_url, params: { region: "JP" }

        # URL should not include theme parameter (ct)
        assert_redirected_to edit_sign_app_preference_region_url(lx: "ja", ri: "jp", tz: "jst")

        # But cookie should still contain theme
        cookie_data = JSON.parse(cookies.signed[:root_app_preferences])
        assert_equal "dr", cookie_data["ct"]
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options applies to all redirects within preference namespace" do
        # Set preferences
        patch sign_app_preference_region_url, params: { region: "US", language: "EN" }

        # Navigate to cookie preferences
        get edit_sign_app_preference_cookie_url

        assert_response :success

        # Update cookie preferences and check redirect
        patch sign_app_preference_cookie_url, params: { accept_functional_cookies: "1" }

        # Should redirect with URL parameters
        assert_redirected_to edit_sign_app_preference_cookie_url(lx: "en", ri: "us", tz: "jst")
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options handles partial cookie data" do
        # Set cookie with only some preference values
        preference_data = { "lx" => "en" }
        cookies.signed[:root_app_preferences] = preference_data.to_json

        patch sign_app_preference_region_url, params: { region: "US" }

        # Should use cookie value for lx, defaults for ri and tz
        assert_redirected_to edit_sign_app_preference_region_url(lx: "en", ri: "jp", tz: "jst")
      end
      # rubocop:enable Minitest/MultipleAssertions
    end
  end
end
