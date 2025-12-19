# frozen_string_literal: true

module Sign
  module App
    module Token
      class RefreshesController < Sign::App::ApplicationController
        skip_forgery_protection only: :create

        # POST /sign/app/token/refresh
        # Refresh access token using refresh token
        #
        # Request (JSON):
        #   { "refresh_token": "token_id" }
        #
        # Response (JSON):
        #   {
        #     "access_token": "jwt_token",
        #     "refresh_token": "new_token_id",
        #     "token_type": "Bearer",
        #     "expires_in": 900
        #   }
        def create
          refresh_token_id = params[:refresh_token]

          if refresh_token_id.blank?
            Rails.event.notify("user.token.refresh.validation_failed",
              reason: "missing_refresh_token",
              ip_address: request.remote_ip
            )

            render json: {
              error: I18n.t("sign.token_refresh.errors.missing_refresh_token"),
              error_code: "missing_refresh_token"
            }, status: :bad_request
            return
          end

          result = refresh_access_token(refresh_token_id)

          if result
            render json: result, status: :ok
          else
            render json: {
              error: I18n.t("sign.token_refresh.errors.invalid_refresh_token"),
              error_code: "invalid_refresh_token"
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
