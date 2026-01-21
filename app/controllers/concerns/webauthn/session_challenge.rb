# frozen_string_literal: true

module Webauthn
  # SessionChallenge handles WebAuthn challenge storage in Rails session.
  # This concern provides methods to store, fetch, and consume challenges
  # for both registration and authentication ceremonies.
  #
  # Session structure:
  #   session[:webauthn] = {
  #     "challenge" => Base64 challenge string,
  #     "purpose" => "registration" | "authentication",
  #     "scope" => "sign/app/configuration/passkeys" | "sign/app/in/passkey" | etc,
  #     "expires_at" => Unix timestamp
  #   }
  module SessionChallenge
    extend ActiveSupport::Concern

    WEBAUTHN_SESSION_KEY = :webauthn
    DEFAULT_TTL = 10.minutes

    class ChallengeError < StandardError; end

    class ChallengeNotFoundError < ChallengeError; end

    class ChallengeExpiredError < ChallengeError; end

    class ChallengeScopeMismatchError < ChallengeError; end

    class ChallengePurposeMismatchError < ChallengeError; end

    # Store a WebAuthn challenge in session
    #
    # @param purpose [String] "registration" or "authentication"
    # @param scope [String] Controller scope identifier (e.g., "sign/app/configuration/passkeys")
    # @param challenge [String] The WebAuthn challenge (Base64 encoded)
    # @param ttl [ActiveSupport::Duration] Time-to-live for the challenge (default: 10 minutes)
    def store_webauthn_challenge!(purpose:, scope:, challenge:, ttl: DEFAULT_TTL)
      session[WEBAUTHN_SESSION_KEY] = {
        "challenge" => challenge,
        "purpose" => purpose.to_s,
        "scope" => scope.to_s,
        "expires_at" => (Time.current + ttl).to_i,
      }
    end

    # Fetch a WebAuthn challenge from session with validation
    # Does NOT consume the challenge - use consume_webauthn_challenge! after verification
    #
    # @param purpose [String] Expected purpose ("registration" or "authentication")
    # @param scope [String] Expected scope
    # @return [String] The challenge string
    # @raise [ChallengeNotFoundError] if no challenge in session
    # @raise [ChallengeExpiredError] if challenge has expired
    # @raise [ChallengePurposeMismatchError] if purpose doesn't match
    # @raise [ChallengeScopeMismatchError] if scope doesn't match
    def fetch_webauthn_challenge!(purpose:, scope:)
      webauthn_data = session[WEBAUTHN_SESSION_KEY]

      raise ChallengeNotFoundError, "No WebAuthn challenge found in session" if webauthn_data.blank?

      # Check expiry
      expires_at = webauthn_data["expires_at"].to_i
      if Time.current.to_i > expires_at
        consume_webauthn_challenge!
        raise ChallengeExpiredError, "WebAuthn challenge has expired"
      end

      # Check purpose
      stored_purpose = webauthn_data["purpose"].to_s
      if stored_purpose != purpose.to_s
        consume_webauthn_challenge!
        raise ChallengePurposeMismatchError, "Purpose mismatch: expected #{purpose}, got #{stored_purpose}"
      end

      # Check scope
      stored_scope = webauthn_data["scope"].to_s
      if stored_scope != scope.to_s
        consume_webauthn_challenge!
        raise ChallengeScopeMismatchError, "Scope mismatch: expected #{scope}, got #{stored_scope}"
      end

      webauthn_data["challenge"]
    end

    # Consume (delete) the WebAuthn challenge from session
    # Always call this after successful verification to ensure one-time use
    def consume_webauthn_challenge!
      session.delete(WEBAUTHN_SESSION_KEY)
    end

    # Check if there's a valid challenge in session without raising errors
    #
    # @return [Boolean] true if valid challenge exists
    def webauthn_challenge_present?
      webauthn_data = session[WEBAUTHN_SESSION_KEY]
      return false if webauthn_data.blank?

      expires_at = webauthn_data["expires_at"].to_i
      Time.current.to_i <= expires_at
    end

    # Helper to safely consume challenge on any error during verification
    # Yields the challenge and automatically consumes on success or failure
    #
    # @param purpose [String] Expected purpose
    # @param scope [String] Expected scope
    # @yield [challenge] Block that uses the challenge
    # @return [Object] Result of the block
    def with_webauthn_challenge(purpose:, scope:)
      challenge = fetch_webauthn_challenge!(purpose: purpose, scope: scope)
      result = yield(challenge)
      consume_webauthn_challenge!
      result
    rescue StandardError => e
      consume_webauthn_challenge!
      raise e
    end
  end
end
