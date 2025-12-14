require "test_helper"

class Sign::App::ExitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get edit raises error without session" do
    skip "Integration test session management needs proper setup"
  end

  test "should destroy raises error without session" do
    skip "Integration test session management needs proper setup"
  end
end
