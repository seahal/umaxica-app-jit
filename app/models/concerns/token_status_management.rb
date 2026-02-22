# frozen_string_literal: true

module TokenStatusManagement
  extend ActiveSupport::Concern

  RESTRICTED_TTL = 15.minutes

  STATUS_ACTIVE = "active"
  STATUS_RESTRICTED = "restricted"
  STATUS_REVOKED = "revoked"

  VALID_STATUSES = [STATUS_ACTIVE, STATUS_RESTRICTED, STATUS_REVOKED].freeze

  included do
    scope :active_status, -> { where(status: STATUS_ACTIVE, revoked_at: nil) }
    scope :restricted_status, -> { where(status: STATUS_RESTRICTED, revoked_at: nil) }
    scope :not_revoked, -> { where(revoked_at: nil) }

    validates :status, inclusion: { in: VALID_STATUSES }, length: { maximum: 20 }
    attribute :status, default: STATUS_ACTIVE
  end

  def restricted?
    status == STATUS_RESTRICTED
  end

  def active_status?
    status == STATUS_ACTIVE && revoked_at.nil?
  end

  def mark_restricted!
    update!(status: STATUS_RESTRICTED)
  end

  def promote_to_active!
    update!(status: STATUS_ACTIVE)
  end

  def revoke!
    update!(revoked_at: Time.current, status: STATUS_REVOKED)
  end
end
