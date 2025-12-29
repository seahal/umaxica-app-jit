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
end
