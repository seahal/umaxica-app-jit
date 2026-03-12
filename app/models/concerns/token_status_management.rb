# typed: false
# frozen_string_literal: true

module TokenStatusManagement
  extend ActiveSupport::Concern

  RESTRICTED_TTL = 15.minutes

  STATUS_ACTIVE = "active"
  STATUS_RESTRICTED = "restricted"
  STATUS_REVOKED = "revoked"

  VALID_STATUSES = [STATUS_ACTIVE, STATUS_RESTRICTED, STATUS_REVOKED].freeze

  included do
    scope :active_status, ->(now = Time.current) { currently_valid_at(now).where(status: STATUS_ACTIVE) }
    scope :restricted_status, ->(now = Time.current) { currently_valid_at(now).where(status: STATUS_RESTRICTED) }
    scope :not_revoked, ->(now = Time.current) { currently_valid_at(now) }

    validates :status, inclusion: { in: VALID_STATUSES }, length: { maximum: 20 }
    attribute :status, default: STATUS_ACTIVE
  end

  def restricted?
    status == STATUS_RESTRICTED
  end

  def active_status? = status == STATUS_ACTIVE && !expired?

  def mark_restricted!
    update!(status: STATUS_RESTRICTED)
  end

  def promote_to_active!
    update!(status: STATUS_ACTIVE)
  end

  def revoke!
    now = Time.current
    attrs = { status: STATUS_REVOKED }
    attrs[:expired_at] = now if has_attribute?(:expired_at)
    attrs[:revoked_at] = now if has_attribute?(:revoked_at)
    update!(attrs)
  end

  def expired?
    return true if respond_to?(:expired_at) && has_attribute?(:expired_at) && expired_at.present?
    return true if scheduled_revocation_due?

    false
  end

  def scheduled_revocation_due?(now = Time.current)
    has_attribute?(:revoked_at) && revoked_at.present? && revoked_at <= now
  end

  module ClassMethods
    def currently_valid_at(now = Time.current)
      scope = where(expiry_column => nil)
      return scope unless column_names.include?("revoked_at")

      scope.where(arel_table[:revoked_at].eq(nil).or(arel_table[:revoked_at].gt(now)))
    end

    def expiry_column
      return :expired_at if column_names.include?("expired_at")
      return :revoked_at if column_names.include?("revoked_at")

      raise "#{name} does not have expired_at/revoked_at column"
    end
  end
end
