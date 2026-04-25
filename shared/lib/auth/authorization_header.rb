# typed: false
# frozen_string_literal: true

module Auth
  module AuthorizationHeader
    module_function

    def bearer_token(request)
      token_and_options(request)&.first.presence
    end

    def token_and_options(request)
      header = authorization_value_for(request)
      return nil if header.blank?

      ActionController::HttpAuthentication::Token.token_and_options(
        Struct.new(:authorization).new(normalize_scheme(header)),
      )
    end

    def authorization_value_for(request)
      if request.respond_to?(:authorization) && request.authorization.present?
        return request.authorization
      end

      return nil unless request.respond_to?(:headers)

      request.headers[Auth::IoKeys::Headers::AUTHORIZATION]
    end

    def normalize_scheme(header)
      header.sub(/\A(token|bearer)\b/i) { |scheme| scheme.capitalize }
    end
    private_class_method :authorization_value_for, :normalize_scheme
  end
end
