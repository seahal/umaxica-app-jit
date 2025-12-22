module Auth
  module App
    module Token
      class RefreshesController < Auth::App::ApplicationController
        def create
          refresh_token_id = params[:refresh_token]

          if refresh_token_id.blank?
            Rails.event.notify("user.token.refresh.validation_failed",
                               reason: "missing_refresh_token",
                               ip_address: request.remote_ip)

            render json: {
              error: I18n.t("auth.token_refresh.errors.missing_refresh_token"),
              error_code: "missing_refresh_token"
            }, status: :bad_request
            return
          end

          # UUID format validation
          unless refresh_token_id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
            Rails.event.notify("user.token.refresh.validation_failed",
                               reason: "invalid_format",
                               refresh_token_id: refresh_token_id,
                               ip_address: request.remote_ip)

            render json: {
              error: I18n.t("auth.token_refresh.errors.invalid_refresh_token"),
              error_code: "invalid_refresh_token_format"
            }, status: :bad_request
            return
          end

          result = refresh_access_token(refresh_token_id)

          if result
            render json: result, status: :ok
          else
            render json: {
              error: I18n.t("auth.token_refresh.errors.invalid_refresh_token"),
              error_code: "invalid_refresh_token"
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
