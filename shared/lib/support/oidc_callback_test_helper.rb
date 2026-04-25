# typed: false
# frozen_string_literal: true

module OidcCallbackTestHelper
  class Harness
    include Oidc::Callback

    attr_reader :redirected_to, :redirect_options, :cookie_args, :request

    def initialize(host:, scheme:, port:, params:, session_data:, client_id:)
      @request = ActionDispatch::TestRequest.create(
        "HTTP_HOST" => host,
        "rack.url_scheme" => scheme,
        "SERVER_PORT" => port.to_s,
      )
      @params = ActionController::Parameters.new(params)
      @session = session_data.to_h.dup
      @flash = {}
      @client_id = client_id
      @cookie_args = nil
      @redirected_to = nil
      @redirect_options = nil
    end

    def params
      @params
    end

    def session
      @session
    end

    def flash
      @flash
    end

    def oidc_client_id
      @client_id
    end

    def oidc_client_secret
      Oidc::ClientRegistry.find(@client_id)&.client_secret
    end

    def set_auth_cookies(access_token:, refresh_token:, device_id:, access_expires_at:, refresh_expires_at:)
      @cookie_args = {
        access_token: access_token,
        refresh_token: refresh_token,
        device_id: device_id,
        access_expires_at: access_expires_at,
        refresh_expires_at: refresh_expires_at,
      }
    end

    def redirect_to(location, allow_other_host: false, alert: nil)
      @redirected_to = location
      @redirect_options = {
        allow_other_host: allow_other_host,
        alert: alert,
      }
      @flash[:alert] = alert if alert
    end
  end

  FakeTokenExchangeResult =
    Struct.new(:success, :token_response, :error, :error_description) do
      def success?
        success
      end
    end

  def fake_oidc_token_exchange_result(
    success:,
    access_token: "access-token",
    refresh_token: "refresh-token",
    error: nil,
    error_description: nil
  )
    FakeTokenExchangeResult.new(
      success,
      success ? { access_token: access_token, refresh_token: refresh_token } : nil,
      error,
      error_description,
    )
  end

  def with_stubbed_oidc_token_exchange(result, captured_args = {})
    original = Oidc::TokenExchangeService.method(:call)
    Oidc::TokenExchangeService.define_singleton_method(:call) do |**kwargs|
      captured_args.replace(kwargs)
      result
    end

    yield
  ensure
    Oidc::TokenExchangeService.define_singleton_method(:call, &original)
  end

  def build_oidc_callback_harness(host:, scheme:, port:, params: {}, session_data: {}, client_id:)
    Harness.new(
      host: host,
      scheme: scheme,
      port: port,
      params: params,
      session_data: session_data,
      client_id: client_id,
    )
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include OidcCallbackTestHelper
end
