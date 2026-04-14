# typed: false
# frozen_string_literal: true

require "test_helper"

class Apex::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("APEX_STAFF_URL", "org.localhost")
    @state = SecureRandom.urlsafe_base64(32)
    @code_verifier = SecureRandom.urlsafe_base64(32)
    @return_to = "/dashboard"
  end

  test "returns client_id as apex_org" do
    controller = Apex::Org::Auth::CallbacksController.new

    assert_equal "apex_org", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "apex/org/auth/callbacks", action: "show" },
    )
  end

  test "oidc_callback_url uses correct host" do
    harness = build_oidc_callback_harness(
      host: @host,
      scheme: "https",
      port: 443,
      client_id: "apex_org",
    )

    assert_equal "https://#{@host}/auth/callback", harness.send(:oidc_callback_url)
  end

  test "oidc_callback_url preserves non-default port" do
    harness = build_oidc_callback_harness(
      host: "#{@host}:3000",
      scheme: "http",
      port: 3000,
      client_id: "apex_org",
    )

    assert_equal "http://#{@host}:3000/auth/callback", harness.send(:oidc_callback_url)
  end

  test "oidc_callback_url omits default https port" do
    harness = build_oidc_callback_harness(host: @host, scheme: "https", port: 443, client_id: "apex_org")

    url = harness.send(:oidc_callback_url)

    assert_not_includes url, ":443"
  end

  test "oidc_callback_url omits default http port" do
    harness = build_oidc_callback_harness(host: @host, scheme: "http", port: 80, client_id: "apex_org")

    url = harness.send(:oidc_callback_url)

    assert_not_includes url, ":80"
  end

  test "GET show with valid state and code exchanges token and redirects to return_to" do
    result = fake_oidc_token_exchange_result(success: true)
    captured_args = {}
    harness = build_oidc_callback_harness(
      host: @host,
      scheme: "http",
      port: 80,
      params: { code: "valid_auth_code", state: @state },
      session_data: {
        oidc_code_verifier: @code_verifier,
        oidc_state: @state,
        oidc_return_to: @return_to,
      },
      client_id: "apex_org",
    )

    freeze_time do
      with_stubbed_oidc_token_exchange(result, captured_args) do
        harness.show
      end

      assert_equal @return_to, harness.redirected_to
      expected_args = {
        grant_type: "authorization_code",
        code: "valid_auth_code",
        redirect_uri: "http://#{@host}/auth/callback",
        client_id: "apex_org",
        client_secret: Oidc::ClientRegistry.find("apex_org")&.client_secret,
        code_verifier: @code_verifier,
      }

      assert_equal expected_args, captured_args.slice(*expected_args.keys)

      assert_equal({}, harness.session)

      expected_cookies = {
        access_token: "access-token",
        refresh_token: "refresh-token",
        device_id: "",
      }

      assert_equal expected_cookies, harness.cookie_args.slice(*expected_cookies.keys)
      assert_in_delta(
        (Time.current + Authentication::Base::ACCESS_TOKEN_TTL).to_i,
        harness.cookie_args[:access_expires_at].to_i,
        1,
      )
      assert_in_delta(
        (Time.current + Authentication::Base::REFRESH_TOKEN_TTL).to_i,
        harness.cookie_args[:refresh_expires_at].to_i,
        1,
      )
    end
  end

  test "GET show with valid state and code falls back to root when return_to is absent" do
    result = fake_oidc_token_exchange_result(success: true)
    harness = build_oidc_callback_harness(
      host: @host,
      scheme: "http",
      port: 80,
      params: { code: "valid_auth_code", state: @state },
      session_data: {
        oidc_code_verifier: @code_verifier,
        oidc_state: @state,
      },
      client_id: "apex_org",
    )

    with_stubbed_oidc_token_exchange(result) do
      harness.show
    end

    assert_equal "/", harness.redirected_to
    assert_equal({}, harness.session)
  end

  test "GET show with blank state accepts a blank session state" do
    result = fake_oidc_token_exchange_result(success: true)
    harness = build_oidc_callback_harness(
      host: @host,
      scheme: "http",
      port: 80,
      params: { code: "valid_auth_code" },
      session_data: {
        oidc_code_verifier: @code_verifier,
      },
      client_id: "apex_org",
    )

    with_stubbed_oidc_token_exchange(result) do
      harness.show
    end

    assert_equal "/", harness.redirected_to
    assert_equal({}, harness.session)
  end

  test "GET show with mismatched state raises InvalidCrossOriginRequest" do
    harness = build_oidc_callback_harness(
      host: @host,
      scheme: "http",
      port: 80,
      params: { code: "valid_auth_code", state: "different" },
      session_data: {
        oidc_state: @state,
        oidc_code_verifier: @code_verifier,
      },
      client_id: "apex_org",
    )

    assert_raises(ActionController::InvalidCrossOriginRequest) do
      harness.show
    end
  end

  test "GET show with token exchange failure redirects to root" do
    result = fake_oidc_token_exchange_result(
      success: false,
      error: "invalid_grant",
      error_description: "Authorization code not found",
    )
    captured_args = {}
    harness = build_oidc_callback_harness(
      host: @host,
      scheme: "http",
      port: 80,
      params: { code: "invalid_code", state: @state },
      session_data: {
        oidc_code_verifier: @code_verifier,
        oidc_state: @state,
      },
      client_id: "apex_org",
    )

    with_stubbed_oidc_token_exchange(result, captured_args) do
      harness.show
    end

    assert_equal "/", harness.redirected_to
    expected_args = {
      grant_type: "authorization_code",
      code: "invalid_code",
      redirect_uri: "http://#{@host}/auth/callback",
      client_id: "apex_org",
      client_secret: Oidc::ClientRegistry.find("apex_org")&.client_secret,
      code_verifier: @code_verifier,
    }

    assert_equal expected_args, captured_args.slice(*expected_args.keys)
    assert_equal({}, harness.session)
    assert_equal I18n.t("errors.messages.login_required"), harness.flash[:alert]
  end
end
