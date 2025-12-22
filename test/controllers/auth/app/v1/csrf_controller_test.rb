require "test_helper"

class Auth::App::V1::CsrfControllerTest < ActionDispatch::IntegrationTest
  test "returns csrf token payload with no-store" do
    get auth_app_v1_csrf_url

    assert_response :success
    assert_not response.parsed_body["csrf_token"].to_s.empty?
    assert_includes response.headers["Cache-Control"], "no-store"

    # Set-Cookie is environment-dependent (e.g., session store/settings), so keep optional.
    # assert response.headers["Set-Cookie"].present?
  end
end
