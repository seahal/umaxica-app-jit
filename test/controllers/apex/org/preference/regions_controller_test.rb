require "test_helper"

class Apex::Org::Preference::RegionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_region_url
    assert_response :success
  end

  test "should display all form sections" do
    get edit_apex_org_preference_region_url
    assert_select "h1", text: I18n.t("apex.org.preferences.regions.title")
    assert_select "select[name='region']"
    assert_select "select[name='language']"
    assert_select "select[name='timezone']"
    assert_select "main.container.mx-auto.mt-28.px-5.block" do
      assert_select "form[action='#{apex_org_preference_region_url}'][method='post']" do
        assert_select "input[name='_method'][value='patch']", count: 1

        assert_select ".region-section" do
          assert_select "h2", text: I18n.t("apex.org.preferences.regions.region_section")
          assert_select "label[for='region']", text: I18n.t("apex.org.preferences.regions.select_region")
          assert_select "select#region option[value='US']"
          assert_select "select#region option[value='JP']"
          assert_not_select "select#language option[value='KR']"
        end

        assert_select ".language-section" do
          assert_select "h2", text: I18n.t("apex.org.preferences.regions.language_section")
          assert_select ".language-selection label[for='language']", text: I18n.t("apex.org.preferences.regions.select_language")
          assert_select ".language-selection select#language option[value='JA']"
          assert_select "select#language option[value='JA']"
          assert_select "select#language option[value='EN']"
          assert_not_select "select#language option[value='KR']"
        end

        assert_select ".timezone-section" do
          assert_select "h2", text: I18n.t("apex.org.preferences.regions.timezone_section")
          assert_select ".timezone-selection label[for='timezone']", text: I18n.t("apex.org.preferences.regions.select_timezone")
          assert_select ".timezone-selection select#timezone option[value='Etc/UTC']"
          assert_select ".timezone-selection select#timezone option[value='Asia/Tokyo']"
          assert_not_select "select#language option[value='KST']"
        end

        assert_select ".form-actions" do
          assert_select "input[type='submit']", count: 1
          assert_select "a.btn.btn-secondary", text: I18n.t("apex.org.preferences.regions.cancel")
        end
      end
    end
  end

  # test "edit preselects saved preferences" do
  #   patch apex_org_preference_region_url, params: { region: "US", language: "EN", timezone: "Etc/UTC" }
  #   follow_redirect!
  #
  #   assert_select "select#region option[value='US'][selected='selected']"
  #   assert_select "select#language option[value='EN'][selected='selected']"
  #   assert_select "select#timezone option[value='Etc/UTC'][selected='selected']"
  # end

  test "should update preferences and redirect to edit" do
    patch apex_org_preference_region_url, params: { region: "US", language: "JA", timezone: "Asia/Tokyo" }

    assert_redirected_to edit_apex_org_preference_region_url
    assert_equal "US", session[:region]
    assert_equal "JA", session[:language]
    assert_equal "Asia/Tokyo", session[:timezone]
    assert_equal I18n.t("messages.region_settings_updated_successfully"), flash[:notice]
  end

  test "should reject unsupported admin language" do
    patch apex_org_preference_region_url, params: { language: "invalid" }
    assert_response :unprocessable_content
  end

  test "should reject invalid timezone" do
    patch apex_org_preference_region_url, params: { timezone: "Invalid/Timezone" }
    assert_response :unprocessable_content
  end
end
