require "test_helper"

class Apex::App::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "GET edit renders form with region language and timezone selects" do
    get edit_apex_app_preference_region_url
    assert_response :success
    assert_select "h1", text: I18n.t("apex.app.preferences.regions.title")
    assert_select "select[name='region']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
  end

  test "edit form contains region language and timezone sections with proper structure" do
    get edit_apex_app_preference_region_url
    assert_select "h1", text: I18n.t("apex.app.preferences.regions.title")
    assert_select "main.container.mx-auto.mt-28.px-5.block" do
      expected_action = apex_app_preference_region_url(ri: "jp", tz: "jst", lx: "ja")
      assert_select "form[action=?][method='post']", expected_action do
        assert_select "input[name='_method'][value='patch']", count: 1

        assert_select ".region-section" do
          assert_select "h2", text: I18n.t("apex.app.preferences.regions.region_section")
          assert_select "label[for='region']", text: I18n.t("apex.app.preferences.regions.select_region")
          assert_select "select#region option[value='US']"
          assert_select "select#region option[value='JP']"
        end

        assert_select ".language-section" do
          assert_select "h2", text: I18n.t("apex.app.preferences.regions.language_section")
          assert_select ".language-selection label[for='language']", text: I18n.t("apex.app.preferences.regions.select_language")
          assert_select "select#language option[value='JA']"
          assert_select "select#language option[value='EN']"
        end

        assert_select ".timezone-section" do
          assert_select "h2", text: I18n.t("apex.app.preferences.regions.timezone_section")
          assert_select ".timezone-selection label[for='timezone']", text: I18n.t("apex.app.preferences.regions.select_timezone")
          assert_select "select#timezone option[value='Etc/UTC']"
          assert_select "select#timezone option[value='Asia/Tokyo']"
        end

        assert_select ".form-actions" do
          assert_select "input[type='submit']", count: 1
        end
      end
    end
  end

  test "edit form preselects options matching session values" do
    patch apex_app_preference_region_url, params: { region: "US", language: "EN", timezone: "Asia/Tokyo" }
    follow_redirect!

    assert_select "select#region option[value='US'][selected='selected']"
    assert_select "select#language option[value='EN'][selected='selected']"
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  test "PATCH with multiple params updates session and redirects with success notice" do
    patch apex_app_preference_region_url, params: { region: "US", country: "US", language: "EN", timezone: "Asia/Tokyo" }

    assert_redirected_to edit_apex_app_preference_region_url(lx: "ja", ri: "us", tz: "asia/tokyo")
    assert_equal "US", session[:region]
    assert_equal "US", session[:country]
    assert_equal "EN", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
    assert_equal I18n.t("messages.region_settings_updated_successfully"), flash[:notice]
  end

  test "PATCH with language normalizes to uppercase and stores in session" do
    patch apex_app_preference_region_url, params: { language: "ja" }

    assert_redirected_to edit_apex_app_preference_region_url(lx: "ja", ri: "jp", tz: "jst")
    assert_equal "JA", session[:language]
  end

  test "PATCH with unsupported language returns unprocessable entity" do
    patch apex_app_preference_region_url, params: { language: "invalid" }
    assert_response :unprocessable_content
  end

  test "PATCH with timezone stores timezone identifier in session" do
    patch apex_app_preference_region_url, params: { timezone: "Asia/Tokyo" }

    assert_redirected_to edit_apex_app_preference_region_url(lx: "ja", ri: "jp", tz: "asia/tokyo")
    assert_equal "Asia/Tokyo", session[:timezone]
  end

  test "PATCH with invalid timezone returns unprocessable entity" do
    patch apex_app_preference_region_url, params: { timezone: "Invalid/Timezone" }
    assert_response :unprocessable_content
  end
end
