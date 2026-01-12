# frozen_string_literal: true

require "test_helper"

class Sign::Org::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_org_configuration_url(ri: "jp")

    assert_response :success
    assert_select "a[href^=?]", sign_org_configuration_sessions_path, count: 1
    assert_select "a[href^=?]", sign_org_configuration_passkeys_path
    assert_select "a[href^=?]", sign_org_configuration_secrets_path
    assert_select "a[href^=?]", sign_org_configuration_withdrawal_path
    assert_select "a[href^=?]", sign_org_root_path
  end
end
