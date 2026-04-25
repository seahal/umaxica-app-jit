# typed: false
# frozen_string_literal: true

module Jit::Identity
    class Sign::Org::Edge::V0::Token::RefreshesController < Jit::Identity::Sign::Org::ApplicationController
      include Jit::Identity::Sign::EdgeV0JsonApi

      activate_edge_v0_json_api
      include ::Preference::WebCookieEndpoint

      public_strict!
      skip_before_action :set_preferences_cookie
      skip_before_action :transparent_refresh_access_token

      def create
        response.set_header("Cache-Control", "no-store")

        # Read refresh token from params or cookie
        refresh_plain = params[:refresh_token].presence || cookies[Authentication::Base::REFRESH_COOKIE_KEY]

        if refresh_plain.blank?
          render json: {
            error: I18n.t("sign.token_refresh.errors.missing_refresh_token"),
            error_code: "missing_refresh_token",
          }, status: :bad_request
          return
        end

        # refresh_access_token now automatically sets cookies (even for JSON)
        credentials = refresh_access_token(refresh_plain)

        if credentials
          sync_consented_buffer_cookie_safely!
          render json: { refreshed: true, dbsc: credentials[:dbsc] }, status: :ok
        else
          status = refresh_failure_status
          code = refresh_failure_code
          render json: {
            error: I18n.t(token_refresh_error_key(code)),
            error_code: code,
          }, status: status
        end
      end

      private

      def token_refresh_error_key(code)
        {
          "invalid_refresh_token" => "sign.token_refresh.errors.invalid_refresh_token",
          "withdrawal_required" => "sign.token_refresh.errors.withdrawal_required",
          "restricted_session" => "sign.token_refresh.errors.restricted_session",
        }.fetch(code) { "sign.token_refresh.errors.invalid_refresh_token" }
      end
    end
  end
end
