# frozen_string_literal: true

require "test_helper"
require "json"

module Sign
  module Org
    class DefaultUrlOptionsTest < ActionDispatch::IntegrationTest
      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options includes preference parameters from cookie" do
        # Set preference cookie by making an actual request
        patch sign_org_preference_region_url, params: { region: "US", language: "EN", timezone: "Etc/UTC" }

        # Make another request that triggers redirect
        patch sign_org_preference_region_url, params: { region: "US" }

        # Verify redirect includes URL parameters from cookie
        assert_redirected_to edit_sign_org_preference_region_url(lx: "en", ri: "us", tz: "utc")
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options falls back to defaults when cookie is not present" do
        # No cookie set - should use default values
        get sign_org_preference_url

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
        patch sign_org_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }
        assert_redirected_to edit_sign_org_preference_region_url(lx: "ja", ri: "jp", tz: "jst")

        follow_redirect!
        assert_response :success

        # Change to English/US preferences
        patch sign_org_preference_region_url, params: { region: "US", language: "EN", timezone: "Etc/UTC" }
        assert_redirected_to edit_sign_org_preference_region_url(lx: "en", ri: "us", tz: "utc")

        # Verify session was updated
        assert_equal "EN", session[:language]
        assert_equal "US", session[:region]
        assert_equal "Etc/UTC", session[:timezone]
      end
      # rubocop:enable Minitest/MultipleAssertions

      test "default_url_options handles malformed cookie gracefully" do
        # Set invalid cookie by manipulating the raw cookie jar
        cookies[:root_app_preferences] = "invalid json"

        # Should not raise error and fall back to defaults
        get sign_org_preference_url

        assert_response :success
      end

      test "default_url_options handles non-hash cookie value gracefully" do
        # Set non-hash value by manipulating the raw cookie jar
        cookies[:root_app_preferences] = "just a string"

        # Should not raise error and fall back to defaults
        get sign_org_preference_url

        assert_response :success
      end

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options preserves theme parameter in cookie but not in URL" do
        # Set preference cookie by making actual requests
        patch sign_org_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }

        # Make another request
        patch sign_org_preference_region_url, params: { region: "JP" }

        # URL should not include theme parameter (ct)
        assert_redirected_to edit_sign_org_preference_region_url(lx: "ja", ri: "jp", tz: "jst")
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options applies to all redirects within preference namespace" do
        # Set preferences
        patch sign_org_preference_region_url, params: { region: "US", language: "EN" }

        # Navigate to cookie preferences
        get edit_sign_org_preference_cookie_url

        assert_response :success

        # Update cookie preferences and check redirect
        patch sign_org_preference_cookie_url, params: { accept_functional_cookies: "1" }

        # Should redirect with URL parameters
        assert_redirected_to edit_sign_org_preference_cookie_url(lx: "en", ri: "us", tz: "jst")
      end
      # rubocop:enable Minitest/MultipleAssertions

      # rubocop:disable Minitest/MultipleAssertions
      test "default_url_options handles partial cookie data" do
        # Set only language preference
        patch sign_org_preference_region_url, params: { language: "EN" }

        # Make another request with only region
        patch sign_org_preference_region_url, params: { region: "US" }

        # Should use cookie value for lx and ri, default for tz
        assert_redirected_to edit_sign_org_preference_region_url(lx: "en", ri: "us", tz: "jst")
      end
      # rubocop:enable Minitest/MultipleAssertions
    end
  end
end
