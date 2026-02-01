# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audits
# Database name: audit
#
#  id             :bigint           not null, primary key
#  actor_type     :text             default(""), not null
#  context        :jsonb            not null
#  current_value  :text             default(""), not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  occurred_at    :datetime         not null
#  previous_value :text             default(""), not null
#  subject_type   :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  event_id       :integer          default(0), not null
#  level_id       :integer          default(0), not null
#  subject_id     :string           not null
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
# Foreign Keys
#
#  fk_rails_...  (event_id => app_timeline_audit_events.id)
#  fk_rails_...  (level_id => app_timeline_audit_levels.id)
#

require "test_helper"

class AppTimelineAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "app_timeline_audits", AppTimelineAudit.table_name

    refl = AppTimelineAudit.reflect_on_association(:app_timeline)

    assert_not_nil refl, "expected belongs_to :app_timeline association"
    assert_equal :belongs_to, refl.macro

    refl_level = AppTimelineAudit.reflect_on_association(:app_timeline_audit_level)
    assert_not_nil refl_level, "expected belongs_to :app_timeline_audit_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "app_timeline helper method returns nil when subject_type is not AppTimeline" do
    audit = AppTimelineAudit.new(
      subject_id: "123",
      subject_type: "SomeOtherType",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )
    assert_nil audit.app_timeline
  end

  test "app_timeline= helper method sets subject_id and subject_type" do
    test_uuid = SecureRandom.uuid

    timeline = AppTimeline.new
    timeline.define_singleton_method(:id) { test_uuid }

    audit = AppTimelineAudit.new
    audit.app_timeline = timeline

    assert_equal test_uuid, audit.subject_id
    assert_equal test_uuid, audit.subject_id
    assert_equal "AppTimeline", audit.subject_type
  end

  test "app_timeline helper method returns timeline when subject_type is AppTimeline" do
    AppTimelineAuditEvent.find_or_create_by!(id: "NEYO")
    AppTimelineAuditLevel.find_or_create_by!(id: "NEYO")
    # Ensure status exists
    AppTimelineStatus.find_or_create_by!(id: "NEYO")

    timeline = AppTimeline.create!(
      status_id: "NEYO",
      slug_id: "tl-#{SecureRandom.hex(4)}",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )
    audit = AppTimelineAudit.create!(
      subject_id: timeline.id,
      subject_type: "AppTimeline",
      occurred_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal timeline, audit.app_timeline
  end
end
