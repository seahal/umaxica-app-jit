# == Schema Information
#
# Table name: app_preference_audits
#
#  id             :uuid             not null, primary key
#  subject_id     :string           not null
#  subject_type   :text             not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :text             default(""), not null
#  event_id       :string(255)      default("NEYO"), not null
#  level_id       :string(255)      default("NEYO"), not null
#  occurred_at    :datetime         not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default("0.0.0.0"), not null
#  context        :jsonb            default("{}"), not null
#  previous_value :text             default(""), not null
#  current_value  :text             default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_app_pref      (subject_type,subject_id,occurred_at)
#  index_app_preference_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_app_preference_audits_on_event_id                  (event_id)
#  index_app_preference_audits_on_expires_at                (expires_at)
#  index_app_preference_audits_on_level_id                  (level_id)
#  index_app_preference_audits_on_occurred_at               (occurred_at)
#  index_app_preference_audits_on_subject_id                (subject_id)
#

# frozen_string_literal: true

class AppPreferenceAudit < AuditRecord
  self.table_name = "app_preference_audits"

  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  # Helper methods for compatibility
  def app_preference
    AppPreference.find(subject_id) if subject_type == "AppPreference"
  end

  def app_preference=(pref)
    self.subject_id = pref.id.to_s
    self.subject_type = "AppPreference"
  end

  belongs_to :app_preference,
             -> { where(subject_type: "AppPreference") },
             class_name: "AppPreference",
             foreign_key: :subject_id,
             primary_key: :id,
             optional: true,
             inverse_of: :app_preference_audits

  belongs_to :app_preference_audit_level, foreign_key: :level_id, inverse_of: :app_preference_audits
  # event_id references AppPreferenceAuditEvent.id (string)
  belongs_to :app_preference_audit_event,
             class_name: "AppPreferenceAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_preference_audits

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }
end
