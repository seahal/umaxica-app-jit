require "test_helper"

class Sign::Org::ExitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = staffs(:one)
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
  end

  test "should get edit raises error without session" do
    get "/sign/exit/edit", env: { "HTTP_HOST" => @host }

    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete "/sign/exit", env: { "HTTP_HOST" => @host }

    assert_response :not_found
  end

  test "should destroy with staff session" do
    get "/sign/exit/edit", env: { "HTTP_HOST" => @host }

    assert_response :not_found
  end
end
