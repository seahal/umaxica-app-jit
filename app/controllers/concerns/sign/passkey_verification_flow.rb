# typed: false
# frozen_string_literal: true

module Sign
  module PasskeyVerificationFlow
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/AbcSize
    def verification
      challenge_id = params[:challenge_id]
      return render_error("errors.webauthn.challenge_id_required", :bad_request) if challenge_id.blank?

      challenge_data = peek_challenge(challenge_id)
      return render_error("errors.webauthn.challenge_invalid", :bad_request) unless challenge_data

      actor_id = challenge_data[passkey_challenge_actor_id_key]

      with_challenge(challenge_id, purpose: :authentication) do |challenge|
        verify_and_login(challenge, actor_id)
      end
    rescue Sign::Webauthn::ChallengeNotFoundError, Sign::Webauthn::ChallengeExpiredError => e
      Rails.logger.warn("WebAuthn challenge error: #{e.message}")
      render_error("errors.webauthn.challenge_invalid", :bad_request)
    rescue Sign::Webauthn::ChallengePurposeMismatchError => e
      Rails.logger.warn("WebAuthn challenge purpose mismatch: #{e.message}")
      render_error("errors.webauthn.challenge_invalid", :bad_request)
    rescue WebAuthn::SignCountVerificationError => e
      Rails.logger.warn("WebAuthn sign count verification failed: #{e.message}")
      render_error("errors.webauthn.sign_count_mismatch", :unauthorized)
    rescue WebAuthn::Error => e
      Rails.logger.warn("WebAuthn authentication failed: #{e.message}")
      render_error("errors.webauthn.verification_failed", :unauthorized)
    end
    # rubocop:enable Metrics/AbcSize

    private

    def passkey_challenge_actor_id_key
      raise NotImplementedError, "#{self.class} must define #passkey_challenge_actor_id_key"
    end
  end
end
