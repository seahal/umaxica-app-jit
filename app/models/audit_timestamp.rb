# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: audit_timestamps
# Database name: activity
#
#  id                  :uuid             not null, primary key
#  audit_record_type   :string           not null
#  error_code          :integer
#  hash_algorithm      :string           default("SHA256"), not null
#  issued_at           :datetime         not null
#  nonce               :binary
#  policy_oid          :string
#  serial_number       :string           not null
#  tsa_certificate     :binary
#  tsa_request         :binary           not null
#  tsa_response        :binary           not null
#  tsa_token           :binary           not null
#  verification_status :boolean
#  verified_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  audit_record_id     :bigint           not null
#  status_id           :integer          default(0), not null
#
# Indexes
#
#  index_audit_timestamps_on_audit_record         (audit_record_type,audit_record_id) UNIQUE
#  index_audit_timestamps_on_issued_at            (issued_at)
#  index_audit_timestamps_on_record_and_status    (audit_record_type,audit_record_id,status_id)
#  index_audit_timestamps_on_serial_number        (serial_number) UNIQUE
#  index_audit_timestamps_on_status_id            (status_id)
#  index_audit_timestamps_on_verification_status  (verification_status) WHERE (verification_status IS NOT NULL)
#

class AuditTimestamp < ActivityRecord
  self.implicit_order_column = :created_at

  belongs_to :audit_record, polymorphic: true

  # RFC 3161 PKIStatus values
  module Status
    GRANTED = 0
    GRANTED_WITH_MODS = 1
    REJECTION = 2
    WAITING = 3
    REVOCATION_WARNING = 4
    REVOCATION_NOTIFICATION = 5

    NAMES = {
      GRANTED => "granted",
      GRANTED_WITH_MODS => "granted_with_modifications",
      REJECTION => "rejection",
      WAITING => "waiting",
      REVOCATION_WARNING => "revocation_warning",
      REVOCATION_NOTIFICATION => "revocation_notification",
    }.freeze
  end

  validates :audit_record_type, presence: true
  validates :tsa_token, presence: true
  validates :tsa_request, presence: true
  validates :tsa_response, presence: true
  validates :serial_number, presence: true, uniqueness: true
  validates :issued_at, presence: true
  validates :status_id, presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hash_algorithm, presence: true

  validate :valid_audit_record_type

  attribute :status_id, default: Status::GRANTED

  scope :granted, -> { where(status_id: Status::GRANTED) }
  scope :rejected, -> { where(status_id: Status::REJECTION) }
  scope :verified, -> { where(verification_status: true) }
  scope :unverified, -> { where(verification_status: [nil, false]) }
  scope :pending_verification, -> { where(verification_status: nil).where.not(verified_at: nil) }

  # Check if this timestamp was successfully granted
  def granted?
    status_id == Status::GRANTED
  end

  # Check if this timestamp was rejected
  def rejected?
    status_id == Status::REJECTION
  end

  # Get human-readable status name
  def status_name
    Status::NAMES[status_id] || "unknown"
  end

  # Mark this timestamp as verified
  def mark_verified!(success: true)
    update!(
      verification_status: success,
      verified_at: Time.current,
    )
  end

  # Update the associated audit record with TSA information
  def link_to_audit_record!
    return unless audit_record.respond_to?(:update!)

    audit_record.update!(
      tsa_token: tsa_token,
      tsa_at: issued_at,
    )
  end

  private

  def valid_audit_record_type
    return if audit_record_type.blank?

    allowed_types = %w(UserActivity StaffActivity)
    return if allowed_types.include?(audit_record_type)

    errors.add(:audit_record_type, :invalid, message: "must be one of: #{allowed_types.join(", ")}")

  end
end
