# frozen_string_literal: true

module Sign
  module App
    class PasskeysController < ApplicationController
      auth_required!
      before_action :authenticate_user!

      # TODO: CSRF protection requires JS to send X-CSRF-Token.
      # For now, we skip it to ensure JSON fetch works easily as requested.
      skip_before_action :verify_authenticity_token, only: %i[options create update destroy]

      def new
        @passkey_exists = current_user.passkey.present?
        @current_host = request.host
      end

      def options
        rp_config = webauthn_rp_config
        user_name = current_user.user_emails.first&.address || current_user.public_id || "User"

        exclude_list = current_user.passkey ? [ current_user.passkey.credential_id ] : []

        options = WebAuthn::Credential.options_for_create(
          user: {
            id: current_user.id,
            name: user_name,
            display_name: user_name
          },
          exclude: exclude_list,
          authenticator_selection: { user_verification: "preferred" },
          rp: { name: WebAuthn.configuration.rp_name, id: rp_config[:rp_id] }
        )

        session[:webauthn_registration_challenge] = options.challenge

        render json: options
      end

      def create
        rp_config = webauthn_rp_config

        # Create relying party instance
        relying_party = WebAuthn::RelyingParty.new(
          allowed_origins: [ rp_config[:origin] ],
          id: rp_config[:rp_id],
          name: ENV.fetch("WEBAUTHN_RP_NAME", "Umaxica")
        )

        webauthn_credential = WebAuthn::Credential.from_create(
          params,
          relying_party: relying_party
        )

        webauthn_credential.verify(session[:webauthn_registration_challenge])

        if current_user.passkey
          return render json: { error: "Passkey already exists. Use update to replace." }, status: :conflict # rubocop:disable I18n/RailsI18n/DecorateString
        end

        Passkey.create!(
          user: current_user,
          credential_id: webauthn_credential.id,
          public_key: Base64.urlsafe_encode64(webauthn_credential.public_key),
          sign_count: webauthn_credential.sign_count
        )

        render json: { status: "created" }, status: :created
      rescue WebAuthn::Error => e
        log_failure(e, "registration_failed", rp_config)
        render json: { error: e.message }, status: :unprocessable_content
      rescue ActiveRecord::RecordInvalid => e
        log_failure(e, "registration_db_error", rp_config)
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_content
      ensure
        session.delete(:webauthn_registration_challenge)
      end

      def update
        rp_config = webauthn_rp_config

        # Create relying party instance
        relying_party = WebAuthn::RelyingParty.new(
          allowed_origins: [ rp_config[:origin] ],
          id: rp_config[:rp_id],
          name: ENV.fetch("WEBAUTHN_RP_NAME", "Umaxica")
        )

        webauthn_credential = WebAuthn::Credential.from_create(
          params,
          relying_party: relying_party
        )

        webauthn_credential.verify(session[:webauthn_registration_challenge])

        Passkey.transaction do
          current_user.passkey&.destroy!
          Passkey.create!(
            user: current_user,
            credential_id: webauthn_credential.id,
            public_key: Base64.urlsafe_encode64(webauthn_credential.public_key),
            sign_count: webauthn_credential.sign_count
          )
        end

        render json: { status: "updated" }, status: :ok
      rescue WebAuthn::Error => e
        log_failure(e, "update_failed", rp_config)
        render json: { error: e.message }, status: :unprocessable_content
      rescue ActiveRecord::RecordInvalid => e
        log_failure(e, "update_db_error", rp_config)
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_content
      ensure
        session.delete(:webauthn_registration_challenge)
      end

      def destroy
        if current_user.passkey&.destroy
          render json: { status: "destroyed" }, status: :ok
        else
          render json: { error: "No passkey found or failed to destroy" }, status: :not_found
        end
      end

      private

        def webauthn_rp_config
          map = JSON.parse(ENV.fetch("WEBAUTHN_RP_MAP", "{}"))
          cfg = map[request.host]

          # Fallback for localhost development if not in map
          if cfg.nil? && (request.host == "localhost" || request.host == "127.0.0.1")
            return { rp_id: "localhost", origin: "#{request.scheme}://#{request.host_with_port}" }
          end

          raise "WebAuthn configuration not found for host: #{request.host}" unless cfg

          # Ensure keys are symbols
          {
            rp_id: cfg["rp_id"],
            origin: cfg["origin"]
          }
        end

        def log_failure(exception, type, rp_config)
          payload = {
            type: type,
            error: exception.message,
            rp_id: rp_config&.dig(:rp_id),
            origin: rp_config&.dig(:origin),
            request_host: request.host,
            request_scheme: request.scheme,
            x_forwarded_proto: request.headers["X-Forwarded-Proto"],
            has_challenge: session[:webauthn_registration_challenge].present?
          }
          Rails.logger.error(JSON.dump(payload))
        end
    end
  end
end
