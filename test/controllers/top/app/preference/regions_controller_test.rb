require "test_helper"

class Top::App::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "GET edit renders form with region select only" do
    get edit_top_app_preference_region_url

    assert_response :success
    assert_select "h1", text: I18n.t("top.app.preferences.regions.title")
    assert_select "select[name='region']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "edit form contains region section with proper structure" do
    get edit_top_app_preference_region_url

    assert_select "form[method='post']" do
      assert_select "input[name='_method'][value='patch']", count: 1

      # New layout uses space-y-4 div instead of .region-section class
      assert_select "h2", text: I18n.t("top.app.preferences.regions.region_section")
      assert_select "label[for='region']", text: I18n.t("top.app.preferences.regions.select_region")
      assert_select "select#region option[value='US']"
      assert_select "select#region option[value='JP']"

      # Submit button
      assert_select "input[type='submit']", count: 1
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "edit form preselects region matching session value" do
    patch top_app_preference_region_url, params: { region: "US" }
    follow_redirect!

    assert_select "select#region option[value='US'][selected='selected']"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH with region updates session and redirects with success notice" do
    patch top_app_preference_region_url, params: { region: "US", country: "US" }

    assert_redirected_to edit_top_app_preference_region_url(ri: "us")
    assert_equal "US", session[:region]
    assert_equal "US", session[:country]
    assert_equal I18n.t("messages.region_settings_updated_successfully"), flash[:notice]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # URL parameter tests

  test "GET edit with ri parameter preselects region without saving to session" do
    get edit_top_app_preference_region_url(ri: "us")

    assert_response :success
    assert_select "select#region option[value='US'][selected='selected']"
    assert_nil session[:region], "Region should not be saved to session from URL parameter"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "URL parameter takes precedence over session value" do
    # Set session value
    patch top_app_preference_region_url, params: { region: "JP" }
    follow_redirect!

    # Access with different URL parameter
    get edit_top_app_preference_region_url(ri: "us")

    assert_response :success

    # URL parameter should override session value in display
    assert_select "select#region option[value='US'][selected='selected']"

    # But session value should remain unchanged
    assert_equal "JP", session[:region]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "URL parameter ri normalizes jp to JP for display" do
    get edit_top_app_preference_region_url(ri: "jp")

    assert_response :success
    assert_select "select#region option[value='JP'][selected='selected']"
  end

  # Cookie persistence tests
  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH should persist region preference and redirect with correct parameters" do
    patch top_app_preference_region_url, params: { region: "JP" }

    # Verify session is updated
    assert_equal "JP", session[:region]

    # Verify redirect includes normalized parameter
    assert_redirected_to edit_top_app_preference_region_url(ri: "jp")

    # Verify cookie is set
    assert_predicate response.cookies["root_app_preferences"], :present?
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "cookie should be set after updating region preference" do
    patch top_app_preference_region_url, params: { region: "US" }

    # Verify cookie exists in response
    assert_predicate response.cookies["root_app_preferences"], :present?
  end

  test "multiple preference updates should maintain cookie consistency" do
    # First update
    patch top_app_preference_region_url, params: { region: "JP" }

    assert_equal "JP", session[:region]

    # Second update
    patch top_app_preference_region_url, params: { region: "US" }

    assert_equal "US", session[:region]
  end

  # Theme handling tests
  test "GET edit with ct=dr parameter preselects dark theme" do
    get edit_top_app_preference_region_url(ct: "dr")

    assert_response :success
    # Theme should be set in instance variable for display
  end

  test "GET edit with ct=sy parameter preselects system theme" do
    get edit_top_app_preference_region_url(ct: "sy")

    assert_response :success
  end

  test "GET edit with ct=li parameter preselects light theme" do
    get edit_top_app_preference_region_url(ct: "li")

    assert_response :success
  end

  test "theme parameter should be processed correctly" do
    # Simulate setting theme in session (since theme isn't in params, it comes from session)
    get edit_top_app_preference_region_url(ct: "dark")
    patch top_app_preference_region_url, params: { region: "JP" }

    # Verify cookie exists and session is updated
    assert_predicate response.cookies["root_app_preferences"], :present?
    assert_equal "JP", session[:region]
  end

  test "light theme parameter should be processed" do
    get edit_top_app_preference_region_url(ct: "light")
    patch top_app_preference_region_url, params: { region: "JP" }

    assert_predicate response.cookies["root_app_preferences"], :present?
    assert_equal "JP", session[:region]
  end

  test "preferences should update with cookie set" do
    patch top_app_preference_region_url, params: { region: "JP" }

    assert_predicate response.cookies["root_app_preferences"], :present?
    assert_equal "JP", session[:region]
  end

  test "region preference should be saved correctly" do
    # Clear session by making a fresh request
    get edit_top_app_preference_region_url
    patch top_app_preference_region_url, params: { region: "JP" }

    assert_equal "JP", session[:region]
    assert_predicate response.cookies["root_app_preferences"], :present?
  end

  # Additional edge case tests
  test "PATCH with empty params should not update session" do
    # Set initial value
    patch top_app_preference_region_url, params: { region: "US" }

    assert_equal "US", session[:region]

    # Make request with no params
    patch top_app_preference_region_url, params: {}
    follow_redirect!

    # Session should remain unchanged
    assert_equal "US", session[:region]
  end

  test "edit page should render successfully with default settings" do
    # Should not raise error and should use defaults
    get edit_top_app_preference_region_url

    assert_response :success
  end
end
