# frozen_string_literal: true

module Sign
  module Webauthn
    extend ActiveSupport::Concern

    CHALLENGE_SESSION_KEY = :passkey_challenges
    CHALLENGE_TTL = 10.minutes
    MAX_CHALLENGES_PER_SESSION = 5

    class ChallengeError < StandardError; end

    class ChallengeNotFoundError < ChallengeError; end

    class ChallengeExpiredError < ChallengeError; end

    class ChallengePurposeMismatchError < ChallengeError; end

    class OriginValidationError < StandardError; end

    # Returns the Relying Party ID for WebAuthn.
    # This is the host portion of the current request (no scheme, no port).
    # Examples: "sign.app.localhost", "sign.org.localhost"
    def webauthn_rp_id
      request.host
    end

    # Returns the expected origin for WebAuthn verification.
    # This is request.base_url (scheme + host + port).
    # Examples: "http://sign.app.localhost:3000", "https://sign.app.example.com"
    def webauthn_origin
      request.base_url
    end

    # Validates that the current request origin is in TRUSTED_ORIGINS.
    # Raises OriginValidationError if not trusted.
    def validate_webauthn_origin!
      origin = webauthn_origin
      unless ::Webauthn.trusted_origins.include?(origin)
        raise OriginValidationError, I18n.t("errors.webauthn.origin_not_trusted", origin: origin)
      end

      origin
    end

    # Creates a WebAuthn registration challenge for the given user/staff.
    #
    # @param resource [User, Staff] The user or staff to create credential for
    # @param exclude_credentials [Array<Hash>] Existing credentials to exclude
    # @return [Array<String, WebAuthn::PublicKeyCredential::CreationOptions>]
    #   Returns [challenge_id, options]
    def create_registration_challenge(resource:, exclude_credentials: [])
      validate_webauthn_origin!

      # Build exclude list from existing passkeys
      exclude_list =
        exclude_credentials.pluck(:id)

      options = WebAuthn::Credential.options_for_create(
        user: {
          id: resource.id,
          name: resource_display_name(resource),
          display_name: resource_display_name(resource),
        },
        exclude: exclude_list,
        authenticator_selection: {
          resident_key: "discouraged",
          user_verification: "preferred",
        },
        attestation: "none",
        rp: { id: webauthn_rp_id },
      )

      challenge_id = store_challenge!(
        challenge: options.challenge,
        purpose: :registration,
      )

      [challenge_id, options]
    end

    # Creates a WebAuthn authentication challenge.
    #
    # @param allow_credentials [Array<Hash>] Credentials to allow (with :id key as Base64URL)
    # @return [Array<String, WebAuthn::PublicKeyCredential::RequestOptions>]
    #   Returns [challenge_id, options]
    def create_authentication_challenge(allow_credentials:)
      validate_webauthn_origin!

      allow_list =
        allow_credentials.pluck(:id)

      options = WebAuthn::Credential.options_for_get(
        allow: allow_list,
        user_verification: "preferred",
        rp_id: webauthn_rp_id,
      )

      challenge_id = store_challenge!(
        challenge: options.challenge,
        purpose: :authentication,
      )

      [challenge_id, options]
    end

    # Executes a block with the challenge, then deletes it.
    # This ensures one-time use of challenges.
    #
    # @param challenge_id [String] The challenge ID from options response
    # @param purpose [Symbol] Expected purpose (:registration or :authentication)
    # @yield [challenge] Block that receives the challenge string
    # @return [Object] Result of the block
    def with_challenge(challenge_id, purpose:)
      challenge = fetch_and_delete_challenge!(challenge_id, purpose: purpose)
      yield(challenge)
    end

    # Fetches challenge without deleting (for inspection)
    def peek_challenge(challenge_id)
      challenges = session[CHALLENGE_SESSION_KEY] || {}
      challenges[challenge_id]
    end

    private

    # Stores a challenge in session and returns its ID.
    #
    # @param challenge [String] The WebAuthn challenge (Base64URL encoded)
    # @param purpose [Symbol] :registration or :authentication
    # @return [String] The generated challenge ID
    def store_challenge!(challenge:, purpose:)
      session[CHALLENGE_SESSION_KEY] ||= {}
      challenges = session[CHALLENGE_SESSION_KEY]

      # Cleanup expired challenges and enforce limit
      cleanup_expired_challenges!(challenges)
      enforce_challenge_limit!(challenges)

      challenge_id = SecureRandom.urlsafe_base64(16)

      challenges[challenge_id] = {
        "challenge" => challenge,
        "purpose" => purpose.to_s,
        "expires_at" => (Time.current + CHALLENGE_TTL).to_i,
      }

      session[CHALLENGE_SESSION_KEY] = challenges
      challenge_id
    end

    # Fetches and deletes a challenge from session.
    #
    # @param challenge_id [String] The challenge ID
    # @param purpose [Symbol] Expected purpose
    # @return [String] The challenge string
    # @raise [ChallengeNotFoundError] if challenge not found
    # @raise [ChallengeExpiredError] if challenge expired
    # @raise [ChallengePurposeMismatchError] if purpose doesn't match
    def fetch_and_delete_challenge!(challenge_id, purpose:)
      challenges = session[CHALLENGE_SESSION_KEY] || {}
      data = challenges.delete(challenge_id)
      session[CHALLENGE_SESSION_KEY] = challenges

      raise ChallengeNotFoundError, "Challenge not found" unless data

      if Time.current.to_i > data["expires_at"].to_i
        raise ChallengeExpiredError, "Challenge has expired"
      end

      if data["purpose"] != purpose.to_s
        raise ChallengePurposeMismatchError,
              "Purpose mismatch: expected #{purpose}, got #{data["purpose"]}"
      end

      data["challenge"]
    end

    # Removes expired challenges from the hash.
    def cleanup_expired_challenges!(challenges)
      now = Time.current.to_i
      challenges.delete_if { |_, data| data["expires_at"].to_i < now }
    end

    # Removes oldest challenges if limit exceeded.
    def enforce_challenge_limit!(challenges)
      return if challenges.size < MAX_CHALLENGES_PER_SESSION

      # Sort by expires_at and remove oldest
      sorted = challenges.sort_by { |_, data| data["expires_at"].to_i }
      oldest_id, = sorted.first
      challenges.delete(oldest_id)
    end

    # Returns a display name for the resource.
    def resource_display_name(resource)
      if resource.respond_to?(:user_emails) && resource.user_emails.any?
        resource.user_emails.first.address
      elsif resource.respond_to?(:staff_emails) && resource.staff_emails.any?
        resource.staff_emails.first.address
      elsif resource.respond_to?(:public_id)
        resource.public_id
      else
        resource.id.to_s
      end
    end
  end
end
