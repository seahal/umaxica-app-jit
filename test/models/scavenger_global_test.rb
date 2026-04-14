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

  test "rejects unknown event_id before database foreign key enforcement" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-bad-event-#{SecureRandom.hex(6)}",
      event_id: 999_999,
      status_id: ScavengerGlobalStatus::NOTHING,
    )

    assert_not record.valid?
    assert_includes record.errors[:event_id], "must reference an existing scavenger_global_event"
  end

  test "rejects unknown status_id before database foreign key enforcement" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-bad-status-#{SecureRandom.hex(6)}",
      event_id: ScavengerGlobalEvent::NOTHING,
      status_id: 999_999,
    )

    assert_not record.valid?
    assert_includes record.errors[:status_id], "must reference an existing scavenger_global_status"
  end

  test "event_id rejects negative values" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-neg-event-#{SecureRandom.hex(6)}",
      event_id: -1,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:event_id]
  end

  test "event_id rejects decimal values" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-dec-event-#{SecureRandom.hex(6)}",
      event_id: 1.5,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:event_id]
  end

  test "status_id rejects negative values" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-neg-status-#{SecureRandom.hex(6)}",
      status_id: -1,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:status_id]
  end

  test "status_id rejects decimal values" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-dec-status-#{SecureRandom.hex(6)}",
      status_id: 1.5,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:status_id]
  end

  test "event_id accepts zero" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-zero-event-#{SecureRandom.hex(6)}",
      event_id: 0,
    )

    # Should pass numericality validation
    assert_equal 0, record.event_id
  end

  test "status_id accepts zero" do
    record = ScavengerGlobal.new(
      occurred_at: Time.current,
      job_type: "scavenger:global:test",
      idempotency_key: "global-zero-status-#{SecureRandom.hex(6)}",
      status_id: 0,
    )

    # Should pass numericality validation
    assert_equal 0, record.status_id
  end
end
