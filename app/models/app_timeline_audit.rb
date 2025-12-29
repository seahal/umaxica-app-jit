# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audits
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
#  idx_on_subject_type_subject_id_occurred_at_c80b4e4f83  (subject_type,subject_id,occurred_at)
#  index_app_timeline_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_app_timeline_audits_on_event_id                  (event_id)
#  index_app_timeline_audits_on_expires_at                (expires_at)
#  index_app_timeline_audits_on_level_id                  (level_id)
#  index_app_timeline_audits_on_occurred_at               (occurred_at)
#  index_app_timeline_audits_on_subject_id                (subject_id)
#

class AppTimelineAudit < UniversalRecord
  self.table_name = "app_timeline_audits"

  validates :subject_id, presence: true
  validates :subject_type, presence: true

  # Virtual belongs_to for ERD - uses subject_id/subject_type instead of FK
  belongs_to :app_timeline, optional: true, foreign_key: :subject_id, inverse_of: :app_timeline_audits

  def app_timeline
    AppTimeline.find(subject_id) if subject_type == "AppTimeline"
  end

  def app_timeline=(timeline)
    self.subject_id = timeline.id.to_s
    self.subject_type = "AppTimeline"
  end

  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :app_timeline_audit_level, foreign_key: :level_id, inverse_of: :app_timeline_audits
  belongs_to :app_timeline_audit_event,
             class_name: "AppTimelineAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_timeline_audits

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }
end
