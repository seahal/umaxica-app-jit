# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_activities
# Database name: activity
#
#  id              :bigint           not null, primary key
#  actor_type      :text             default(""), not null
#  context         :jsonb            not null
#  current_value   :text             default(""), not null
#  expires_at      :datetime         not null
#  ip_address      :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  occurred_at     :datetime         not null
#  previous_digest :string
#  previous_value  :text             default(""), not null
#  record_digest   :string
#  sequence_number :bigint
#  subject_type    :text             not null
#  tsa_at          :datetime
#  tsa_token       :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  actor_id        :bigint           default(0), not null
#  event_id        :bigint           default(0), not null
#  level_id        :bigint           default(1), not null
#  subject_id      :bigint           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_2e96c29236  (subject_type,subject_id,occurred_at)
#  index_staff_activities_on_actor                        (actor_type,actor_id)
#  index_staff_activities_on_actor_id_and_occurred_at     (actor_id,occurred_at)
#  index_staff_activities_on_chain_validation             (sequence_number,record_digest)
#  index_staff_activities_on_event_id                     (event_id)
#  index_staff_activities_on_expires_at                   (expires_at)
#  index_staff_activities_on_level_id                     (level_id)
#  index_staff_activities_on_occurred_at                  (occurred_at)
#  index_staff_activities_on_record_digest                (record_digest) UNIQUE
#  index_staff_activities_on_sequence_number              (sequence_number) UNIQUE
#  index_staff_activities_on_subject_id                   (subject_id)
#  index_staff_activities_on_tsa_at                       (tsa_at)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => staff_activity_events.id)
#  fk_rails_...  (level_id => staff_activity_levels.id)
#

class StaffActivity < ActivityRecord
  belongs_to :staff_activity_event, foreign_key: :event_id, inverse_of: :staff_activities
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_activity_level, foreign_key: :level_id, inverse_of: :staff_activities
  has_one :audit_timestamp, as: :audit_record, dependent: :destroy

  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  attribute :level_id, default: StaffActivityLevel::NOTHING

  validates_reference_table :event_id, association: :staff_activity_event
  validates_reference_table :level_id, association: :staff_activity_level
  validates :event_id, :level_id,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # Helper methods for compatibility with existing code
  before_create :set_timestamp

  def set_timestamp
    self.timestamp ||= Time.current
  end

  def staff
    Staff.find(subject_id) if subject_type == "Staff"
  end

  def staff=(staff)
    self.subject_id = staff.id.to_s
    self.subject_type = "Staff"
  end

  # Alias for backward compatibility
  alias_attribute :timestamp, :occurred_at

  encrypts :previous_value

  # Tamper-evident audit support
  before_create :assign_sequence_number_and_digest

  # Verify chain integrity for this record
  def chain_valid?
    return true if sequence_number.nil? || sequence_number == 1
    return false if previous_digest.blank?

    previous_record = self.class.find_by(sequence_number: sequence_number - 1)
    return false if previous_record.nil?

    previous_record.record_digest == previous_digest
  end

  # Generate cryptographic digest for this record
  def compute_digest
    data = [
      sequence_number.to_s,
      actor_type,
      actor_id.to_s,
      subject_type,
      subject_id.to_s,
      event_id.to_s,
      occurred_at&.iso8601,
      previous_digest.to_s,
      context.to_json,
    ].join("|")

    Digest::SHA256.hexdigest(data)
  end

  # Verify this record's own digest
  def digest_valid?
    return true if record_digest.blank?

    compute_digest == record_digest
  end

  # Full verification: both chain and own digest
  def tamper_evident_valid?
    chain_valid? && digest_valid?
  end

  # Class method to verify entire chain up to given sequence number
  def self.verify_chain(up_to_sequence: nil)
    scope = up_to_sequence ? where(sequence_number: ..up_to_sequence) : all
    scope = scope.order(:sequence_number)

    scope.each do |record|
      return { valid: false, failed_at: record.sequence_number, reason: :chain_broken } unless record.chain_valid?
      return { valid: false, failed_at: record.sequence_number, reason: :digest_mismatch } unless record.digest_valid?
    end

    { valid: true, count: scope.count }
  end

  private

  def assign_sequence_number_and_digest
    last_record = self.class.order(:sequence_number).last
    self.sequence_number = last_record ? last_record.sequence_number + 1 : 1
    self.previous_digest = last_record&.record_digest
    self.record_digest = compute_digest
  end
end
