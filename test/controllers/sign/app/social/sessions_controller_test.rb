# frozen_string_literal: true

require "test_helper"

class Sign::App::Social::SessionsControllerTest < ActionDispatch::IntegrationTest
  SOCIAL_INTENT_SESSION_KEY = :social_auth_intent
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "google-uid-123",
        info: { email: "social@example.com" },
        credentials: { token: "test", refresh_token: "refresh" },
        extra: { raw_info: { sub: "google-uid-123" } },
      )
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "social signup start is guarded by SignUpGuard" do
    user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")

    post sign_app_social_start_url(provider: "google_oauth2", intent: "signup", ri: "jp"),
         headers: default_headers.merge({ "X-TEST-CURRENT-USER" => user.id })

    assert_response :conflict
  end

  test "rd is preserved from social start to callback and used for redirect" do
    encoded_rd = Base64.urlsafe_encode64("/dashboard")

    post sign_app_social_start_url(ri: "jp"),
         params: { provider: "google_oauth2", intent: "login", rd: encoded_rd },
         headers: default_headers

    assert_response :temporary_redirect
    assert_includes @response.headers["Location"], "/auth/google_oauth2"
    assert_includes @response.headers["Location"], "state="
    assert_equal encoded_rd, session[:user_email_authentication_rd]

    state = session[SOCIAL_INTENT_SESSION_KEY]["state"]

    get "/auth/google_oauth2/callback",
        params: { state: state },
        headers: default_headers

    assert_redirected_to "/dashboard"
  end

  private

    def default_headers
      { "Host" => host, "HTTPS" => "on" }
    end

    def host
      ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    end
end
