require "test_helper"

class Top::App::Preference::LocalesControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "GET edit renders form with language and timezone selects" do
    get edit_top_app_preference_locale_url

    assert_response :success
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "edit form preselects language matching session value" do
    patch top_app_preference_locale_url, params: { language: "EN" }
    follow_redirect!

    assert_select "select#language option[value='en'][selected='selected']"
  end

  test "edit form preselects timezone matching session value" do
    patch top_app_preference_locale_url, params: { timezone: "Asia/Tokyo" }
    follow_redirect!

    assert_select "select#timezone option[value='Asia/Tokyo'][selected='selected']"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH with language and timezone updates session and redirects" do
    patch top_app_preference_locale_url, params: { language: "EN", timezone: "Asia/Tokyo" }

    assert_redirected_to edit_top_app_preference_locale_url(lx: "en", tz: "asia/tokyo")
    assert_equal "EN", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "PATCH with language normalizes to uppercase and stores in session" do
    patch top_app_preference_locale_url, params: { language: "ja" }

    assert_response :redirect
    assert_equal "JA", session[:language]
  end

  test "PATCH with unsupported language returns unprocessable entity" do
    patch top_app_preference_locale_url, params: { language: "invalid" }

    assert_response :unprocessable_content
  end

  test "PATCH with timezone stores timezone identifier in session" do
    patch top_app_preference_locale_url, params: { timezone: "Asia/Tokyo" }

    assert_redirected_to edit_top_app_preference_locale_url(lx: "ja", tz: "asia/tokyo")
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  test "PATCH with invalid timezone returns unprocessable entity" do
    patch top_app_preference_locale_url, params: { timezone: "Invalid/Timezone" }

    assert_response :unprocessable_content
  end

  # URL parameter tests
  test "GET edit with lx parameter preselects language without saving to session" do
    get edit_top_app_preference_locale_url(lx: "en")

    assert_response :success
    assert_select "select#language option[value='en'][selected='selected']"
    assert_nil session[:language], "Language should not be saved to session from URL parameter"
  end

  test "GET edit with tz parameter preselects timezone without saving to session" do
    get edit_top_app_preference_locale_url(tz: "utc")

    assert_response :success
    assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"
    assert_nil session[:timezone], "Timezone should not be saved to session from URL parameter"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "GET edit with multiple URL parameters preselects all options" do
    get edit_top_app_preference_locale_url(lx: "en", tz: "utc")

    assert_response :success
    assert_select "select#language option[value='en'][selected='selected']"
    assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "URL parameters take precedence over session values" do
    # Set session values
    patch top_app_preference_locale_url, params: { language: "JA", timezone: "Asia/Tokyo" }
    follow_redirect!

    # Access with different URL parameters
    get edit_top_app_preference_locale_url(lx: "en", tz: "utc")

    assert_response :success

    # URL parameters should override session values in display
    assert_select "select#language option[value='en'][selected='selected']"
    assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"

    # But session values should remain unchanged
    assert_equal "JA", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "URL parameter lx normalizes ja to lowercase for display" do
    get edit_top_app_preference_locale_url(lx: "ja")

    assert_response :success
    assert_select "select#language option[value='ja'][selected='selected']"
  end

  test "URL parameter tz normalizes jst to Asia/Tokyo for display" do
    get edit_top_app_preference_locale_url(tz: "jst")

    assert_response :success
    assert_select "select#timezone option[value='Asia/Tokyo'][selected='selected']"
  end

  # Cookie persistence tests
  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH should persist preferences and redirect with correct parameters" do
    patch top_app_preference_locale_url, params: { language: "JA", timezone: "Asia/Tokyo" }

    # Verify session is updated
    assert_equal "JA", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]

    # Verify redirect includes normalized parameters
    assert_redirected_to edit_top_app_preference_locale_url(lx: "ja", tz: "asia/tokyo")

    # Verify cookie is set
    assert_predicate response.cookies["root_app_preferences"], :present?
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "cookie should be set after updating preferences" do
    patch top_app_preference_locale_url, params: { language: "EN" }

    # Verify cookie exists in response
    assert_predicate response.cookies["root_app_preferences"], :present?
  end

  test "multiple preference updates should maintain cookie consistency" do
    # First update
    patch top_app_preference_locale_url, params: { language: "EN" }

    assert_equal "EN", session[:language]

    # Second update
    patch top_app_preference_locale_url, params: { timezone: "Etc/UTC" }

    assert_equal "Etc/UTC", session[:timezone]
    assert_equal "EN", session[:language], "Previous language setting should be maintained"
  end

  test "PATCH with case-insensitive timezone should work" do
    patch top_app_preference_locale_url, params: { timezone: "asia/tokyo" }

    assert_redirected_to edit_top_app_preference_locale_url(lx: "ja", tz: "asia/tokyo")
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  test "PATCH with empty params should not update session" do
    # Set initial value
    patch top_app_preference_locale_url, params: { language: "EN" }

    assert_equal "EN", session[:language]

    # Make request with no params
    patch top_app_preference_locale_url, params: {}
    follow_redirect!

    # Session should remain unchanged
    assert_equal "EN", session[:language]
  end

  test "edit page should render successfully with default settings" do
    # Should not raise error and should use defaults
    get edit_top_app_preference_locale_url

    assert_response :success
  end
end
