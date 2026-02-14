# frozen_string_literal: true

# Shared refresh-token behavior for token models.
# Keeps raw tokens out of the database by storing only digests.
# Required gem: sha3

module RefreshTokenable
  extend ActiveSupport::Concern
  include RefreshTokenShared

  REFRESH_TTL = 30.days

  included do
    before_validation :ensure_refresh_expires_at, on: :create
    before_validation :ensure_refresh_token_family_id, on: :create
    before_validation :ensure_refresh_token_generation, on: :create
    before_validation :ensure_device_id, on: :create
    validates :refresh_token_digest, uniqueness: true, allow_nil: true
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
      token, verifier = generate_refresh_token(public_id: public_id)

      self.refresh_token_digest = digest_refresh_token(verifier)
      self.refresh_expires_at = expires_at || default_refresh_expires_at
      self.last_used_at = Time.current
      self.refresh_token_generation = refresh_token_generation.to_i + 1
      save!

      # Return the combined token for the client.
      token
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
    return false unless active?

    refresh_token_digest_matches?(verifier)
  end

  def refresh_token_digest_matches?(verifier)
    return false if verifier.blank? || refresh_token_digest.blank?

    candidate = digest_refresh_token(verifier)

    secure_compare?(refresh_token_digest, candidate)
  end

  private

  def default_refresh_expires_at
    Time.current + REFRESH_TTL
  end

  def ensure_refresh_expires_at
    self.refresh_expires_at ||= default_refresh_expires_at
  end

  def ensure_refresh_token_family_id
    self.refresh_token_family_id ||= SecureRandom.uuid
  end

  def ensure_refresh_token_generation
    self.refresh_token_generation ||= 0
  end

  def ensure_device_id
    return unless has_attribute?(:device_id)

    self.device_id = SecureRandom.uuid if device_id.blank?
  end
end
