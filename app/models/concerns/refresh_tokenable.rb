# frozen_string_literal: true

# Shared refresh-token behavior for token models.
# Keeps raw tokens out of the database by storing only digests.
# Required gem: sha3

module RefreshTokenable
  extend ActiveSupport::Concern

  REFRESH_TOKEN_SEPARATOR = "."
  REFRESH_VERIFIER_BYTES = 48
  REFRESH_TTL = 1.year

  included do
    before_validation :ensure_refresh_expires_at, on: :create
    validates :refresh_token_digest, uniqueness: true, allow_nil: true
  end

  class_methods do
    # Split token into public_id and verifier.
    def parse_refresh_token(token)
      return nil if token.blank?

      public_id, verifier = token.split(REFRESH_TOKEN_SEPARATOR, 2)
      return nil if public_id.blank? || verifier.blank?

      [public_id, verifier]
    end
  end

  # Whether the token is revoked.
  def revoked?
    revoked_at.present?
  end

  # Whether the refresh token has expired.
  def expired_refresh?
    refresh_expires_at <= Time.current
  end

  # Whether the token is active.
  def active?
    !revoked? && !expired_refresh?
  end

  # Rotate (refresh) the token and return the raw token for the client.
  def rotate_refresh_token!(expires_at: nil)
    # Use a transaction to keep token state consistent.
    transaction do
      verifier = SecureRandom.urlsafe_base64(REFRESH_VERIFIER_BYTES)

      self.refresh_token_digest = digest_refresh_token(verifier)
      self.refresh_expires_at = expires_at || default_refresh_expires_at
      self.rotated_at = Time.current
      self.last_used_at = Time.current
      save!

      # Return the combined token for the client.
      build_refresh_token(verifier)
    end
  end

  # Revoke the token.
  def revoke!
    update!(revoked_at: Time.current)
  end

  def refresh_token=(verifier)
    self.refresh_token_digest = verifier.blank? ? nil : digest_refresh_token(verifier)
  end

  # Authenticate the refresh token.
  def authenticate_refresh_token(verifier)
    # Ensure the token is active before doing any hash work.
    return false unless active?
    return false if verifier.blank? || refresh_token_digest.blank?

    candidate = digest_refresh_token(verifier)

    # Use a constant-time comparison to avoid timing attacks.
    ActiveSupport::SecurityUtils.secure_compare(refresh_token_digest, candidate)
  end

  private

  # Hash with SHA3-384.
  def digest_refresh_token(verifier)
    SHA3::Digest::SHA3_384.digest(verifier)
  end

  # Build the token string returned to the client (public_id.verifier).
  def build_refresh_token(verifier)
    "#{public_id}#{REFRESH_TOKEN_SEPARATOR}#{verifier}"
  end

  def default_refresh_expires_at
    Time.current + REFRESH_TTL
  end

  def ensure_refresh_expires_at
    self.refresh_expires_at ||= default_refresh_expires_at
  end
end
