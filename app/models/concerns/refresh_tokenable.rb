# Shared refresh-token behavior for token models.
# Keeps raw tokens out of the database by storing only digests.
module RefreshTokenable
  extend ActiveSupport::Concern

  REFRESH_TOKEN_SEPARATOR = "."
  REFRESH_VERIFIER_BYTES = 32
  REFRESH_TTL = 1.year

  included do
    has_secure_password :refresh_token, validations: false
    before_validation :ensure_refresh_expires_at, on: :create
  end

  class_methods do
    def parse_refresh_token(token)
      return nil if token.blank?

      public_id, verifier = token.split(REFRESH_TOKEN_SEPARATOR, 2)
      return nil if public_id.blank? || verifier.blank?

      [ public_id, verifier ]
    end
  end

  def revoked?
    revoked_at.present?
  end

  def expired_refresh?
    refresh_expires_at <= Time.current
  end

  def active?
    !revoked? && !expired_refresh?
  end

  def rotate_refresh_token!(expires_at: nil)
    verifier = SecureRandom.urlsafe_base64(REFRESH_VERIFIER_BYTES)
    self.refresh_token = verifier
    self.refresh_expires_at = expires_at || default_refresh_expires_at
    self.rotated_at = Time.current
    self.last_used_at = Time.current
    save!

    build_refresh_token(verifier)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  private

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
