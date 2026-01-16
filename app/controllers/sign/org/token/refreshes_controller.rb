# frozen_string_literal: true

module Sign
  module Org
    module Token
      class RefreshesController < ApplicationController
        skip_before_action :set_preferences_cookie

        def create
          refresh_token_id = params[:refresh_token] || cookies.encrypted[::Auth::Staff::REFRESH_COOKIE_KEY]

          if refresh_token_id.blank?
            render json: {
              error: I18n.t("sign.token_refresh.errors.missing_refresh_token", default: "Refresh token is required"),
              error_code: "missing_refresh_token",
            }, status: :bad_request
            return
          end

          credentials = refresh_access_token(refresh_token_id)

          if credentials
            # Update cookies for browser clients
            unless request.format.json?
              cookies[::Auth::Staff::ACCESS_COOKIE_KEY] = cookie_options.merge(
                value: credentials[:access_token],
                expires: ::Auth::Base::Token::ACCESS_TOKEN_TTL.from_now,
              )
              cookies.encrypted[::Auth::Staff::REFRESH_COOKIE_KEY] = cookie_options.merge(
                value: credentials[:refresh_token],
                expires: 1.year.from_now,
              )
            end

            render json: credentials, status: :ok
          else
            render json: {
              error: I18n.t(
                "sign.token_refresh.errors.invalid_refresh_token",
                default: "Invalid or expired refresh token",
              ),
              error_code: "invalid_refresh_token",
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
