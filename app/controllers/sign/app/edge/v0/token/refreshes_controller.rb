# typed: false
# frozen_string_literal: true

class Sign::App::Edge::V0::Token::RefreshesController < Sign::App::ApplicationController
  include Sign::EdgeV0JsonApi
  include ::Preference::WebCookieEndpoint

  public_strict!
  skip_before_action :set_preferences_cookie
  skip_before_action :transparent_refresh_access_token

  def create
    response.set_header("Cache-Control", "no-store")

    # Read refresh token from params or cookie
    refresh_plain = params[:refresh_token].presence || cookies[Auth::Base::REFRESH_COOKIE_KEY]

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
        error: (code == "restricted_session") ? "きんそくじこうです" : I18n.t("sign.token_refresh.errors.invalid_refresh_token"),
        error_code: code,
      }, status: status
    end
  end
end
