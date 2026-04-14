# typed: false
# frozen_string_literal: true

module Sign
  class TokenEndpointController < ActionController::API
    def create
      # Ensure request format is JSON
      return head :not_acceptable unless request.format.json?

      result = Oidc::TokenExchangeService.new(
        grant_type: params[:grant_type],
        code: params[:code],
        redirect_uri: params[:redirect_uri],
        client_id: params[:client_id],
        client_secret: params[:client_secret],
        code_verifier: params[:code_verifier],
      ).call

      if result.success?
        response.headers["Cache-Control"] = "no-store"
        render json: result.token_response
      else
        render json: {
          error: result.error,
          error_description: result.error_description,
        }, status: :bad_request
      end
    end
  end
end
