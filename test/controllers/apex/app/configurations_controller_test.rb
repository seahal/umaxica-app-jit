# frozen_string_literal: true

require "test_helper"

module Apex::App
  class ConfigurationsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get apex_app_configuration_url

      assert_response :success
    end

    test "includes link to new email configuration" do
      get apex_app_configuration_url

      assert_select "a[href*=?]", new_apex_app_configuration_email_path,
                    text: I18n.t("apex.app.configurations.email_settings")
    end
  end
end
