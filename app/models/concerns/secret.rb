# frozen_string_literal: true

module Secret
  extend ActiveSupport::Concern

  SECRET_PASSWORD_LENGTH = 32

  included do
    has_secure_password algorithm: :argon2, validations: false
    validates :name, presence: true
    validates :password,
              length: {
                is: SECRET_PASSWORD_LENGTH,
                message: "must be #{SECRET_PASSWORD_LENGTH} characters",
              },
              allow_nil: true
  end

  class_methods do
    def issue!(name:, length: SECRET_PASSWORD_LENGTH, expires_at: nil, uses: 1, status: :active, **attributes)
      raw_secret = SecureRandom.base58(length)
      record_attributes = attributes.merge(name: name, uses_remaining: uses)
      record_attributes[:expires_at] = expires_at if expires_at
      record = new(record_attributes)
      record[identity_secret_status_id_column] = status_id_for(status)
      record.password = raw_secret
      record.save!
      [record, raw_secret]
    end

    def identity_secret_status_class
      raise NotImplementedError, "define identity_secret_status_class in the including model"
    end

    def identity_secret_status_id_column
      raise NotImplementedError, "define identity_secret_status_id_column in the including model"
    end

    def status_id_for(status)
      status_key = status.to_s.upcase
      identity_secret_status_class.find(status_key).id
    end
  end

  def verify_and_consume!(raw_secret, now: Time.current)
    with_lock do
      reload

      # Perform authentication first to maintain constant-time comparison
      auth_result = authenticate(raw_secret)

      # Then check other conditions
      return false unless active?
      return false if expire_if_needed!(now: now)
      return false unless uses_remaining.to_i.positive?
      return false unless auth_result

      self.uses_remaining -= 1
      self.last_used_at = now

      if uses_remaining.zero?
        self[self.class.identity_secret_status_id_column] = self.class.status_id_for(:used)
      end

      save!
    end

    true
  end

  def expire_if_needed!(now: Time.current)
    return false unless active?
    return false unless expired_by_time?(now)

    self[self.class.identity_secret_status_id_column] = self.class.status_id_for(:expired)
    save!
    true
  end

  def active?
    secret_status_id == "ACTIVE"
  end

  def used?
    secret_status_id == "USED"
  end

  def revoked?
    secret_status_id == "REVOKED"
  end

  def expired?
    secret_status_id == "EXPIRED"
  end

  def deleted?
    secret_status_id == "DELETED"
  end

  private

  def secret_status_id
    self[self.class.identity_secret_status_id_column]
  end

  def expired_by_time?(now)
    return false if expires_at.nil?

    # PostgreSQL infinity/-infinity are used as sentinels for "never expires"
    # When read from DB, they may be converted to Float::INFINITY/-Float::INFINITY
    return false if expires_at.is_a?(Float) && expires_at.infinite?

    # Convert to comparable type if needed (unix timestamp to Time)
    comparable_time = expires_at.is_a?(Float) ? Time.zone.at(expires_at) : expires_at
    comparable_time <= now
  end
end
