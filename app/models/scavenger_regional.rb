# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: scavenger_regionals
# Database name: behavior
#
#  id              :bigint           not null, primary key
#  error_message   :text
#  finished_at     :datetime
#  idempotency_key :string(128)
#  job_type        :string(64)
#  occurred_at     :datetime
#  payload         :jsonb
#  retry_count     :integer
#  started_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  event_id        :bigint           default(0), not null
#  region_id       :bigint
#  status_id       :bigint           default(0), not null
#
# Indexes
#
#  index_scavenger_regionals_on_event_id                       (event_id)
#  index_scavenger_regionals_on_occurred_at                    (occurred_at)
#  index_scavenger_regionals_on_region_id_and_idempotency_key  (region_id,idempotency_key) UNIQUE
#  index_scavenger_regionals_on_region_id_and_job_type         (region_id,job_type)
#  index_scavenger_regionals_on_status_id                      (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => scavenger_regional_events.id)
#  fk_rails_...  (status_id => scavenger_regional_statuses.id)
#
class ScavengerRegional < BehaviorRecord
  belongs_to :scavenger_regional_status,
             class_name: "ScavengerRegionalStatus",
             foreign_key: "status_id",
             primary_key: "id",
             inverse_of: :scavenger_regionals
  belongs_to :scavenger_regional_event,
             class_name: "ScavengerRegionalEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :scavenger_regionals

  validates :event_id, numericality: { only_integer: true }, allow_nil: true
  validates :status_id, numericality: { only_integer: true }, allow_nil: true
  validates :job_type, presence: true
  validates :idempotency_key, presence: true
  validates :region_id, presence: true
end
