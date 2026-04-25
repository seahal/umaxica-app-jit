# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Up::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
  end

  test "base controller exists and includes expected concerns" do
    controller = Sign::Org::Up::BaseController.new

    assert_includes controller.private_methods, :after_login_path
  end

  test "main_app.after_identity.login_path returns sign_org_configuration_path" do
    controller = Sign::Org::Up::BaseController.new
    request = ActionDispatch::TestRequest.create
    controller.request = request

    result = controller.send(:after_login_path)

    assert_equal "/configuration", result
  end
end
