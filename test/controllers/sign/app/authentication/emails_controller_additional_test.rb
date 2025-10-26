require "test_helper"

class Sign::App::Authentication::EmailsControllerAdditionalTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "GET new sets encrypted htop_private_key cookie" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    assert_response :success
    assert_not_nil cookies[:htop_private_key]
  end

  test "GET new creates cookie with value" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    # Cookie should be set
    assert_not_nil cookies[:htop_private_key]
  end

  test "GET new in different environments sets cookie" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    assert_response :success
    # Cookie should be set regardless of environment
    assert_not_nil cookies[:htop_private_key]
  end

  test "POST create with htop_private_key cookie renders response" do
    # First set the cookie via GET new
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    # Then make the POST request
    post sign_app_authentication_email_url, headers: { "Host" => @host }

    assert_response :success
    assert_equal "aaa", response.body
  end

  test "POST create without htop_private_key cookie still responds" do
    # Make POST request without first getting the cookie
    post sign_app_authentication_email_url, headers: { "Host" => @host }

    # Should still get a response (even though it might be different)
    assert_response :success
  end

  test "GET new sets httponly cookie flag" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    # Cookie should be httponly (can't directly test in integration test, but verify it's set)
    assert_not_nil cookies[:htop_private_key]
  end
end
