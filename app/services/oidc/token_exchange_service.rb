# typed: false
# frozen_string_literal: true

require "json"

module Oidc
  class TokenExchangeService < ApplicationService
    Result =
      Data.define(:success, :token_response, :error, :error_description) do
        def success? = success
      end

    def initialize(grant_type:, code:, redirect_uri:, client_id:, client_secret:, code_verifier:)
      super()
      @grant_type = grant_type
      @code = code
      @redirect_uri = redirect_uri
      @client_id = client_id
      @client_secret = client_secret
      @code_verifier = code_verifier
    end

    def call
      validate_grant_type!
      authenticate_client!
      authorization_code = find_and_validate_code!
      verify_pkce!(authorization_code)
      consume_and_issue_tokens!(authorization_code)
    rescue ArgumentError => e
      failure("invalid_request", e.message)
    rescue ActiveRecord::RecordNotFound
      failure("invalid_grant", "Authorization code not found")
    rescue RuntimeError => e
      failure("invalid_grant", e.message)
    end

    private

    attr_reader :grant_type, :code, :redirect_uri, :client_id, :client_secret, :code_verifier

    def validate_grant_type!
      raise ArgumentError, "grant_type must be 'authorization_code'" unless grant_type == "authorization_code"
    end

    def authenticate_client!
      return if Oidc::ClientRegistry.authenticate(client_id, client_secret)

      raise ArgumentError, "Client authentication failed"

    end

    def find_and_validate_code!
      authorization_code =
        TokenRecord.connected_to(role: :writing) do
          AuthorizationCode.lock.find_by!(code: code)
        end

      raise RuntimeError, "Authorization code expired" if authorization_code.expired?
      raise RuntimeError, "Authorization code already consumed" if authorization_code.consumed?
      raise RuntimeError, "Authorization code revoked" if authorization_code.revoked?
      raise ArgumentError, "redirect_uri mismatch" unless authorization_code.redirect_uri == redirect_uri
      raise ArgumentError, "client_id mismatch" unless authorization_code.client_id == client_id

      authorization_code
    end

    def verify_pkce!(authorization_code)
      raise ArgumentError, "code_verifier is required" if code_verifier.blank?

      return if authorization_code.verify_pkce(code_verifier)

      raise ArgumentError, "PKCE verification failed"

    end

    def consume_and_issue_tokens!(authorization_code)
      client = Oidc::ClientRegistry.find!(client_id)
      resource = authorization_code.resource

      TokenRecord.connected_to(role: :writing) do
        authorization_code.consume!

        token_record = create_token_record!(client, resource)
        refresh_plain = token_record.rotate_refresh_token!
        now = Time.current
        access_expires_at = now + Authentication::Base::ACCESS_TOKEN_TTL

        sign_host = resolve_sign_host(client)

        auth_method = authorization_code.auth_method.presence
        acr = authorization_code.acr.presence || "aal1"
        amr = build_amr_from_auth_method(auth_method)

        access_token = Auth::TokenService.encode(
          resource,
          host: sign_host,
          session_public_id: token_record.public_id,
          resource_type: client.resource_type,
          expires_at: access_expires_at,
          acr: acr,
          amr: amr,
        )

        id_token = build_id_token(
          resource: resource,
          resource_type: client.resource_type,
          host: sign_host,
          session_public_id: token_record.public_id,
          nonce: authorization_code.nonce,
          acr: acr,
          amr: amr,
          auth_time: authorization_code.created_at,
        )

        Result.new(
          success: true,
          token_response: {
            access_token: access_token,
            token_type: "Bearer",
            expires_in: Integer(Authentication::Base::ACCESS_TOKEN_TTL.to_s, 10),
            refresh_token: refresh_plain,
            id_token: id_token,
          },
          error: nil,
          error_description: nil,
        )
      end
    end

    def create_token_record!(client, resource)
      case client.resource_type
      when "staff"
        StaffToken.create!(
          staff: resource,
          public_id: SecureRandom.alphanumeric(21),
          refresh_expires_at: Authentication::Base::REFRESH_TOKEN_TTL.from_now,
          status: "active",
        )
      when "customer"
        CustomerToken.create!(
          customer: resource,
          public_id: SecureRandom.alphanumeric(21),
          refresh_expires_at: Authentication::Base::REFRESH_TOKEN_TTL.from_now,
          status: "active",
        )
      else
        UserToken.create!(
          user: resource,
          public_id: SecureRandom.alphanumeric(21),
          refresh_expires_at: Authentication::Base::REFRESH_TOKEN_TTL.from_now,
          status: "active",
        )
      end
    end

    def resolve_sign_host(client)
      case client.resource_type
      when "staff"
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      when "customer"
        ENV.fetch("SIGN_COM_URL", "sign.com.localhost")
      else
        ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      end
    end

    def build_amr_from_auth_method(auth_method)
      return [] if auth_method.blank?

      methods =
        case auth_method
        when Array
          auth_method
        when String
          stripped = auth_method.strip
          if stripped.start_with?("[")
            JSON.parse(stripped)
          else
            [stripped]
          end
        else
          [auth_method.to_s]
        end

      methods.filter_map do |method|
        case method.to_s
        when "email", "email_otp"
          "email_otp"
        when "passkey"
          "passkey"
        when "google"
          "google"
        when "apple"
          "apple"
        when "recovery_code", "secret"
          "recovery_code"
        when "totp"
          "totp"
        end
      end.uniq
    rescue JSON::ParserError
      []
    end

    def build_id_token(resource:, resource_type:, host:, session_public_id:, nonce:, acr:, amr:, auth_time:)
      subject_type = resource_type.to_s
      auth_time_seconds = Integer(auth_time.to_i)

      payload = {
        "iss" => Authentication::Base::JwtConfiguration.issuer(resource_type),
        "sub" => resource.id,
        "subject_type" => subject_type,
        "aud" => client_id,
        "exp" => (Time.current + Authentication::Base::ACCESS_TOKEN_TTL).to_i,
        "iat" => Time.current.to_i,
        "auth_time" => auth_time_seconds,
        "sid" => session_public_id,
        "acr" => acr,
        "amr" => amr,
        "jti" => Jit::Security::Jwt::JtiGenerator.generate,
      }

      if nonce.present?
        payload["nonce"] = nonce
      end

      JWT.encode(
        payload,
        Jit::Security::Jwt::Keyring.private_key_for_active,
        Auth::TokenService::JWT_ALGORITHM,
        { kid: Jit::Security::Jwt::Keyring.active_kid, typ: "JWT" },
      )
    end

    def failure(error, description)
      Result.new(success: false, token_response: nil, error: error, error_description: description)
    end
  end
end
