# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_globals
# Database name: activity
#
#  id              :bigint           not null, primary key
#  error_message   :text
#  finished_at     :datetime
#  idempotency_key :string(128)      not null
#  job_type        :string(64)       not null
#  occurred_at     :datetime
#  payload         :jsonb
#  retry_count     :integer
#  started_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  event_id        :bigint           default(0), not null
#  status_id       :bigint           default(0), not null
#
# Indexes
#
#  index_scavenger_globals_on_event_id         (event_id)
#  index_scavenger_globals_on_idempotency_key  (idempotency_key) UNIQUE
#  index_scavenger_globals_on_job_type         (job_type)
#  index_scavenger_globals_on_occurred_at      (occurred_at)
#  index_scavenger_globals_on_status_id        (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => scavenger_global_events.id)
#  fk_rails_...  (status_id => scavenger_global_statuses.id)
#
class ScavengerGlobal < ActivityRecord
  belongs_to :scavenger_global_status,
             class_name: "ScavengerGlobalStatus",
             foreign_key: "status_id",
             primary_key: "id",
             inverse_of: :scavenger_globals
  belongs_to :scavenger_global_event,
             class_name: "ScavengerGlobalEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :scavenger_globals

  validates_reference_table :event_id, association: :scavenger_global_event
  validates_reference_table :status_id, association: :scavenger_global_status
  validates :event_id, :status_id,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :job_type, presence: true, length: { maximum: 64 }
  validates :idempotency_key, presence: true, length: { maximum: 128 }, uniqueness: true
end
