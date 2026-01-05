# frozen_string_literal: true

require "test_helper"

class Apex::Org::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_org_configuration_url

    assert_response :success
  end

  test "includes link to new email configuration" do
    get apex_org_configuration_url

    assert_select "a[href*=?]", new_apex_org_configuration_email_path,
                  text: I18n.t("apex.org.configurations.email_settings")
  end
end
