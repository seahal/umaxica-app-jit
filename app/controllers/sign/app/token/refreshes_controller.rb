# frozen_string_literal: true

module Sign
  module App
    module Token
      class RefreshesController < Sign::App::ApplicationController
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
