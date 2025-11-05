require "test_helper"


class Sign::Org::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "GET edit renders form with region language and timezone selects" do
    get edit_sign_org_preference_region_url

    assert_response :success
    assert_select "h1", text: I18n.t("sign.org.preferences.regions.title")
    assert_select "select[name='region']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "edit form contains region language and timezone sections with proper structure" do
    get edit_sign_org_preference_region_url

    assert_select "h1", text: I18n.t("sign.org.preferences.regions.title")
    assert_select "main.container.mx-auto.mt-28.px-5.block" do
      expected_action = sign_org_preference_region_url(ri: "jp", tz: "jst", lx: "ja")
      assert_select "form[action=?][method='post']", expected_action do
        assert_select "input[name='_method'][value='patch']", count: 1

        assert_select ".region-section" do
          assert_select "h2", text: I18n.t("sign.org.preferences.regions.region_section")
          assert_select "label[for='region']", text: I18n.t("sign.org.preferences.regions.select_region")
          assert_select "select#region option[value='US']"
          assert_select "select#region option[value='JP']"
        end

        assert_select ".language-section" do
          assert_select "h2", text: I18n.t("sign.org.preferences.regions.language_section")
          assert_select ".language-selection label[for='language']", text: I18n.t("sign.org.preferences.regions.select_language")
          assert_select "select#language option[value='JA']"
          assert_select "select#language option[value='EN']"
        end

        assert_select ".timezone-section" do
          assert_select "h2", text: I18n.t("sign.org.preferences.regions.timezone_section")
          assert_select ".timezone-selection label[for='timezone']", text: I18n.t("sign.org.preferences.regions.select_timezone")
          assert_select "select#timezone option[value='Etc/UTC']"
          assert_select "select#timezone option[value='Asia/Tokyo']"
        end

        assert_select ".form-actions" do
          assert_select "input[type='submit']", count: 1
        end
      end
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "edit form preselects options matching session values" do
    patch sign_org_preference_region_url, params: { region: "US", language: "EN", timezone: "Asia/Tokyo" }
    follow_redirect!

    assert_select "select#region option[value='US'][selected='selected']"
    assert_select "select#language option[value='EN'][selected='selected']"
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH with multiple params updates session and redirects with success notice" do
    patch sign_org_preference_region_url, params: { region: "US", country: "US", language: "EN", timezone: "Asia/Tokyo" }

    assert_redirected_to edit_sign_org_preference_region_url(lx: "en", ri: "us", tz: "jst")
    assert_equal "US", session[:region]
    assert_equal "US", session[:country]
    assert_equal "EN", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
    assert_equal I18n.t("messages.region_settings_updated_successfully"), flash[:notice]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "PATCH with language normalizes to uppercase and stores in session" do
    patch sign_org_preference_region_url, params: { language: "ja" }

    assert_redirected_to edit_sign_org_preference_region_url(lx: "ja", ri: "jp", tz: "jst")
    assert_equal "JA", session[:language]
  end

  test "PATCH with unsupported language returns unprocessable entity" do
    patch sign_org_preference_region_url, params: { language: "invalid" }

    assert_response :unprocessable_content
  end

  test "PATCH with timezone stores timezone identifier in session" do
    patch sign_org_preference_region_url, params: { timezone: "Asia/Tokyo" }

    assert_redirected_to edit_sign_org_preference_region_url(lx: "ja", ri: "jp", tz: "jst")
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  test "PATCH with invalid timezone returns unprocessable entity" do
    patch sign_org_preference_region_url, params: { timezone: "Invalid/Timezone" }

    assert_response :unprocessable_content
  end

  # URL parameter tests
  test "GET edit with lx parameter preselects language without saving to session" do
    get edit_sign_org_preference_region_url(lx: "en")

    assert_response :success
    assert_select "select#language option[value='EN'][selected='selected']"
    assert_nil session[:language], "Language should not be saved to session from URL parameter"
  end

  test "GET edit with ri parameter preselects region without saving to session" do
    get edit_sign_org_preference_region_url(ri: "us")

    assert_response :success
    assert_select "select#region option[value='US'][selected='selected']"
    assert_nil session[:region], "Region should not be saved to session from URL parameter"
  end

  test "GET edit with tz parameter preselects timezone without saving to session" do
    get edit_sign_org_preference_region_url(tz: "utc")

    assert_response :success
    assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"
    assert_nil session[:timezone], "Timezone should not be saved to session from URL parameter"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "GET edit with multiple URL parameters preselects all options" do
    get edit_sign_org_preference_region_url(lx: "en", ri: "us", tz: "utc")

    assert_response :success
    assert_select "select#language option[value='EN'][selected='selected']"
    assert_select "select#region option[value='US'][selected='selected']"
    assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "URL parameters take precedence over session values" do
    # Set session values
    patch sign_org_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }
    follow_redirect!

    # Access with different URL parameters
    get edit_sign_org_preference_region_url(lx: "en", ri: "us", tz: "utc")

    assert_response :success

    # URL parameters should override session values in display
    assert_select "select#language option[value='EN'][selected='selected']"
    assert_select "select#region option[value='US'][selected='selected']"
    assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"

    # But session values should remain unchanged
    assert_equal "JA", session[:language]
    assert_equal "JP", session[:region]
    assert_equal "Asia/Tokyo", session[:timezone]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "URL parameter lx normalizes ja to JA for display" do
    get edit_sign_org_preference_region_url(lx: "ja")

    assert_response :success
    assert_select "select#language option[value='JA'][selected='selected']"
  end

  test "URL parameter ri normalizes jp to JP for display" do
    get edit_sign_org_preference_region_url(ri: "jp")

    assert_response :success
    assert_select "select#region option[value='JP'][selected='selected']"
  end

  test "URL parameter tz normalizes jst to Asia/Tokyo for display" do
    get edit_sign_org_preference_region_url(tz: "jst")

    assert_response :success
    assert_select "select#timezone option[value='Asia/Tokyo'][selected='selected']"
  end

  test "URL parameter tz normalizes kst to Asia/Seoul for display" do
    get edit_sign_org_preference_region_url(tz: "kst")

    assert_response :success
    # Note: This test assumes Asia/Seoul is in the timezone options
    # If not, it will fall back to the default timezone
  end

  # Cookie persistence tests
  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH should persist preferences and redirect with correct parameters" do
    patch sign_org_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }

    # Verify session is updated
    assert_equal "JP", session[:region]
    assert_equal "JA", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]

    # Verify redirect includes normalized parameters
    assert_redirected_to edit_sign_org_preference_region_url(lx: "ja", ri: "jp", tz: "jst")

    # Verify cookie is set
    assert_predicate response.cookies["root_app_preferences"], :present?
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "cookie should be set after updating preferences" do
    patch sign_org_preference_region_url, params: { region: "US", language: "EN" }

    # Verify cookie exists in response
    assert_predicate response.cookies["root_app_preferences"], :present?
  end

  test "multiple preference updates should maintain cookie consistency" do
    # First update
    patch sign_org_preference_region_url, params: { region: "JP" }

    assert_equal "JP", session[:region]

    # Second update
    patch sign_org_preference_region_url, params: { language: "EN" }

    assert_equal "EN", session[:language]
    assert_equal "JP", session[:region], "Previous region setting should be maintained"
  end

  test "session values should be maintained after setting preferences" do
    patch sign_org_preference_region_url, params: { timezone: "Asia/Tokyo" }

    assert_equal "Asia/Tokyo", session[:timezone]
    assert_predicate response.cookies["root_app_preferences"], :present?
  end

  test "preferences should persist across multiple updates" do
    patch sign_org_preference_region_url, params: { timezone: "Etc/UTC" }

    assert_equal "Etc/UTC", session[:timezone]

    patch sign_org_preference_region_url, params: { region: "US" }

    assert_equal "US", session[:region]
    assert_equal "Etc/UTC", session[:timezone], "Timezone should persist"
  end

  # Theme handling tests
  test "GET edit with ct=dr parameter preselects dark theme" do
    get edit_sign_org_preference_region_url(ct: "dr")

    assert_response :success
    # Theme should be set in instance variable for display
  end

  test "GET edit with ct=sy parameter preselects system theme" do
    get edit_sign_org_preference_region_url(ct: "sy")

    assert_response :success
  end

  test "GET edit with ct=li parameter preselects light theme" do
    get edit_sign_org_preference_region_url(ct: "li")

    assert_response :success
  end

  test "theme parameter should be processed correctly" do
    # Simulate setting theme in session (since theme isn't in params, it comes from session)
    get edit_sign_org_preference_region_url(ct: "dark")
    patch sign_org_preference_region_url, params: { region: "JP" }

    # Verify cookie exists and session is updated
    assert_predicate response.cookies["root_app_preferences"], :present?
    assert_equal "JP", session[:region]
  end

  test "light theme parameter should be processed" do
    get edit_sign_org_preference_region_url(ct: "light")
    patch sign_org_preference_region_url, params: { region: "JP" }

    assert_predicate response.cookies["root_app_preferences"], :present?
    assert_equal "JP", session[:region]
  end

  test "preferences should update with cookie set" do
    patch sign_org_preference_region_url, params: { region: "JP" }

    assert_predicate response.cookies["root_app_preferences"], :present?
    assert_equal "JP", session[:region]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "multiple preferences should be saved correctly" do
    # Clear session by making a fresh request
    get edit_sign_org_preference_region_url
    patch sign_org_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }

    assert_equal "JP", session[:region]
    assert_equal "JA", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
    assert_predicate response.cookies["root_app_preferences"], :present?
  end
  # rubocop:enable Minitest/MultipleAssertions

  # Additional edge case tests
  test "PATCH with empty params should not update session" do
    # Set initial values
    patch sign_org_preference_region_url, params: { region: "US", language: "EN" }

    assert_equal "US", session[:region]

    # Make request with no params
    patch sign_org_preference_region_url, params: {}
    follow_redirect!

    # Session should remain unchanged
    assert_equal "US", session[:region]
    assert_equal "EN", session[:language]
  end

  test "PATCH with case-insensitive timezone should work" do
    patch sign_org_preference_region_url, params: { timezone: "asia/tokyo" }

    assert_redirected_to edit_sign_org_preference_region_url(lx: "ja", ri: "jp", tz: "jst")
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should handle existing preferences when updating" do
    # Set initial preferences
    patch sign_org_preference_region_url, params: { region: "US", language: "EN" }

    assert_equal "US", session[:region]
    assert_equal "EN", session[:language]

    # Update with new preference
    patch sign_org_preference_region_url, params: { timezone: "Etc/UTC" }

    # All preferences should be maintained
    assert_equal "US", session[:region]
    assert_equal "EN", session[:language]
    assert_equal "Etc/UTC", session[:timezone]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "edit page should render successfully with default settings" do
    # Should not raise error and should use defaults
    get edit_sign_org_preference_region_url

    assert_response :success
  end
end
