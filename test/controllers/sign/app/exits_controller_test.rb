require "test_helper"

class Sign::App::ExitsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit with session raises error without session" do
    get sign_app_exit_path

    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete sign_app_exit_path

    assert_response :not_found
  end
end
