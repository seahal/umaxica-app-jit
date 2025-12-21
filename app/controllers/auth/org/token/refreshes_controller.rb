# frozen_string_literal: true

module Auth
  module Org
    module Token
      class RefreshesController < ApplicationController
        def create
          refresh_token_id = params[:refresh_token] || cookies.encrypted[:refresh_staff_token]

          if refresh_token_id.blank?
            render json: {
              error: I18n.t("auth.token_refresh.errors.missing_refresh_token", default: "Refresh token is required"),
              error_code: "missing_refresh_token"
            }, status: :bad_request
            return
          end

          credentials = refresh_access_token(refresh_token_id)

          if credentials
            # Update cookies for browser clients
            unless request.format.json?
              cookies[:access_staff_token] = cookie_options.merge(
                value: credentials[:access_token],
                expires: Authentication::Base::ACCESS_TOKEN_EXPIRY.from_now
              )
              cookies.encrypted[:refresh_staff_token] = cookie_options.merge(
                value: credentials[:refresh_token],
                expires: 1.year.from_now
              )
            end

            render json: credentials, status: :ok
          else
            render json: {
              error: I18n.t("auth.token_refresh.errors.invalid_refresh_token",
                            default: "Invalid or expired refresh token"),
              error_code: "invalid_refresh_token"
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
