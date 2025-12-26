# frozen_string_literal: true

require "test_helper"

class Auth::App::ExitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
  end

  test "should get edit raises error without session" do
    get edit_auth_app_exit_url, headers: { "Host" => @host }
    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete auth_app_exit_url, headers: { "Host" => @host }
    assert_response :not_found
  end
end
