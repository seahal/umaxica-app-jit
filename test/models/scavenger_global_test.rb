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
require "test_helper"

class ScavengerGlobalTest < ActiveSupport::TestCase
  fixtures :scavenger_global_statuses, :scavenger_global_events, :scavenger_globals

  test "loads NOTHING fixture with id 0" do
    assert_equal 0, scavenger_global_statuses(:nothing).id
    assert_equal 0, scavenger_global_events(:nothing).id
  end

  test "persists with default lookup ids when omitted" do
    record = ScavengerGlobal.create!(
      occurred_at: Time.current,
      job_type: "scavenger:global:default",
      idempotency_key: "global-default-#{SecureRandom.hex(6)}",
    )

    assert_equal ScavengerGlobalEvent::NOTHING, record.reload.event_id
    assert_equal ScavengerGlobalStatus::NOTHING, record.status_id
  end

  test "enforces idempotency_key uniqueness" do
    key = "global-unique-#{SecureRandom.hex(6)}"

    ScavengerGlobal.create!(
      occurred_at: Time.current,
      job_type: "scavenger:global:unique",
      idempotency_key: key,
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      ScavengerGlobal.create!(
        occurred_at: Time.current,
        job_type: "scavenger:global:unique",
        idempotency_key: key,
      )
    end
  end

  test "rejects non-existent lookup ids by foreign key" do
    connection = ScavengerGlobal.connection
    now = Time.current

    assert_raises(ActiveRecord::InvalidForeignKey) do
      connection.execute(
        <<~SQL.squish,
          INSERT INTO scavenger_globals
          (occurred_at, event_id, status_id, job_type, idempotency_key, created_at, updated_at)
          VALUES
          (#{connection.quote(now)}, 999999, 999999, 'scavenger:global:fk',
           #{connection.quote("global-fk-#{SecureRandom.hex(6)}")},
           #{connection.quote(now)}, #{connection.quote(now)})
        SQL
      )
    end
  end
end
