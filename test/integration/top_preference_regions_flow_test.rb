require "test_helper"

class TopPreferenceRegionsFlowTest < ActionDispatch::IntegrationTest
  DOMAINS = [
    { name: "app", edit: :edit_top_app_preference_region_url, update: :top_app_preference_region_url, scope: "top.app.preferences" },
    { name: "com", edit: :edit_top_com_preference_region_url, update: :top_com_preference_region_url, scope: "top.com.preferences" },
    { name: "org", edit: :edit_top_org_preference_region_url, update: :top_org_preference_region_url, scope: "top.org.preferences" }
  ].freeze

  DOMAINS.each do |domain|
    test "#{domain[:name]} domain updates preferences and persists cookies" do
      patch public_send(domain[:update]), params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }

      assert_redirected_to public_send(domain[:edit])
      assert_equal I18n.t("messages.region_settings_updated_successfully"), flash[:notice]
      assert_predicate response.cookies["root_app_preferences"], :present?
    end

    test "#{domain[:name]} domain surfaces localized timezone errors" do
      patch public_send(domain[:update]), params: { timezone: "Invalid/Zone" }

      assert_response :unprocessable_content
      assert_equal I18n.t("#{domain[:scope]}.timezones.invalid"), flash[:alert]
    end
  end
end
