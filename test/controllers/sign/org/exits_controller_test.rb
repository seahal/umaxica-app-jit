require "test_helper"

class Sign::Org::ExitsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit raises error without session" do
    get sign_org_exit_path

    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete sign_org_exit_path

    assert_response :not_found
  end
end
