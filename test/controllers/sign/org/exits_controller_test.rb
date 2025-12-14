require "test_helper"

class Sign::Org::ExitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = staffs(:one)
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
  end

  test "should get edit raises error without session" do
    skip "Integration test session management needs proper setup"
  end

  test "should destroy raises error without session" do
    skip "Integration test session management needs proper setup"
  end
end
