# typed: false
# frozen_string_literal: true

module Sign
  module App
    class AuthorizesController < ApplicationController
      auth_required!
      before_action :authenticate!

      def show
        result = Oidc::AuthorizeService.call(
          params: authorize_params,
          resource: current_user,
          auth_method: resolved_auth_method,
          acr: resolved_acr,
        )

        if result.success?
          redirect_to(result.redirect_url, allow_other_host: true)
        else
          render json: { error: result.error, error_description: result.error_description },
                 status: :bad_request
        end
      end

      private

      def authorize_params
        params.permit(
          :response_type, :client_id, :redirect_uri, :state,
          :code_challenge, :code_challenge_method, :scope, :nonce,
        )
      end

      def resolved_auth_method
        return Current.token["amr"] if Current.token.is_a?(Hash) && Current.token["amr"].present?
        return session[:pending_mfa]["auth_method"] if session[:pending_mfa].is_a?(Hash) &&
          session[:pending_mfa]["auth_method"].present?

        nil
      end

      def resolved_acr
        return Current.token["acr"] if Current.token.is_a?(Hash) && Current.token["acr"].present?

        "aal1"
      end
    end
  end
end
