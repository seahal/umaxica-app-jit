# frozen_string_literal: true

module Sign
  module App
    module Token
      class RefreshesController < Sign::App::ApplicationController
        skip_before_action :set_preferences_cookie

        def create
          response.set_header("Cache-Control", "no-store")
          refresh_token = params[:refresh_token].presence || cookies[::Auth::Base::REFRESH_COOKIE_KEY]

          if refresh_token.blank?
            Rails.event.notify(
              "user.token.refresh.validation_failed",
              reason: "missing_refresh_token",
              ip_address: request.remote_ip,
            )

            render json: {
              error: I18n.t("sign.token_refresh.errors.missing_refresh_token"),
              error_code: "missing_refresh_token",
            }, status: :bad_request
            return
          end

          result = refresh_access_token(refresh_token)

          if result
            render json: result, status: :ok
          else
            status = refresh_failure_status
            code = refresh_failure_code
            render json: {
              error: if code == "restricted_session"
                       "きんそくじこうです"
                     else
                       I18n.t("sign.token_refresh.errors.invalid_refresh_token")
                     end,
              error_code: code,
            }, status: status
          end
        end
      end
    end
  end
end
