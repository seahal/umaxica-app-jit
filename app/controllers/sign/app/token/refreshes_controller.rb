# frozen_string_literal: true

module Sign
  module App
    module Token
      class RefreshesController < ApplicationController
        skip_forgery_protection only: :create
        before_action :validate_refresh_token, only: :create

        # POST /sign/app/token/refresh
        # Request body: { refresh_token: "uuid..." }
        # Response: { access_token: "jwt...", token_type: "Bearer", expires_in: 900 }
        def create
          user_token = UserToken.find_by(id: @refresh_token_id)

          if user_token.nil?
            render json: { error: "Invalid refresh token" }, status: :unauthorized
            return
          end

          user = User.find_by(id: user_token.user_id)

          if user.nil? || (user.respond_to?(:withdrawn?) && user.withdrawn?)
            user_token.destroy
            render json: { error: "User not found or withdrawn" }, status: :unauthorized
            return
          end

          # Generate new access token
          access_token = generate_access_token(user)

          render json: {
            access_token: access_token,
            token_type: "Bearer",
            expires_in: ::Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i
          }, status: :ok
        rescue StandardError => e
          Rails.logger.error "Token refresh failed: #{e.class}: #{e.message}"
          render json: { error: "Token refresh failed" }, status: :internal_server_error
        end

        private

        def validate_refresh_token
          @refresh_token_id = params[:refresh_token]

          if @refresh_token_id.blank?
            render json: { error: "refresh_token is required" }, status: :bad_request
          end
        end
      end
    end
  end
end
