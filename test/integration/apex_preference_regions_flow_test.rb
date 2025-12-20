require "test_helper"

class ApexPreferenceRegionsFlowTest < ActionDispatch::IntegrationTest
  DOMAINS = [
    { name: "app", edit: :edit_apex_app_preference_region_url, update: :apex_app_preference_region_url, scope: "apex.app.preferences" },
    { name: "com", edit: :edit_apex_com_preference_region_url, update: :apex_com_preference_region_url, scope: "apex.com.preferences" },
    { name: "org", edit: :edit_apex_org_preference_region_url, update: :apex_org_preference_region_url, scope: "apex.org.preferences" }
  ].freeze

  DOMAINS.each do |domain|
    test "#{domain[:name]} domain updates preferences and persists cookies" do
      patch public_send(domain[:update]), params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }

      assert_redirected_to public_send(domain[:edit], lx: "ja", ri: "jp", tz: "asia/tokyo")
      assert_equal I18n.t("messages.region_settings_updated_successfully"), flash[:notice]
      assert_predicate response.cookies["root_app_preferences"], :present?
    end

    test "#{domain[:name]} domain surfaces localized timezone errors" do
      patch public_send(domain[:update]), params: { timezone: "Invalid/Zone" }

      assert_response :unprocessable_content
      assert_equal I18n.t("timezones.invalid", scope: domain[:scope].split(".")), flash[:alert]
    end
  end
end
