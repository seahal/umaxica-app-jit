# frozen_string_literal: true

require "test_helper"

class Sign::App::In::SecretsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_app_in_secret_url(ri: "jp")
    assert_response :success
  end

  test "should get create" do
    post sign_app_in_secret_url(ri: "jp")
    assert_response :success
  end
end
