# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Token
      class RefreshesController < ApplicationController
        skip_before_action :set_preferences_cookie

        def create
          refresh_token = params[:refresh_token].presence || cookies[::Auth::Base::REFRESH_COOKIE_KEY]

          if refresh_token.blank?
            render json: {
              error: I18n.t("sign.token_refresh.errors.missing_refresh_token"),
              error_code: "missing_refresh_token",
            }, status: :bad_request
            return
          end

          response.set_header("Cache-Control", "no-store")
          credentials = refresh_access_token(refresh_token)

          if credentials
            render json: credentials, status: :ok
          else
            render json: {
              error: I18n.t(
                "sign.token_refresh.errors.invalid_refresh_token",
              ),
              error_code: "invalid_refresh_token",
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
