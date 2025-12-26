# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audits
#
#  id             :uuid             not null, primary key
#  subject_id     :string           not null
#  subject_type   :text             not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :text             default(""), not null
#  event_id       :string(255)      default("NONE"), not null
#  level_id       :string(255)      default("NONE"), not null
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
#  idx_on_subject_type_subject_id_occurred_at_99ec847a5c  (subject_type,subject_id,occurred_at)
#  index_com_timeline_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_com_timeline_audits_on_event_id                  (event_id)
#  index_com_timeline_audits_on_expires_at                (expires_at)
#  index_com_timeline_audits_on_level_id                  (level_id)
#  index_com_timeline_audits_on_occurred_at               (occurred_at)
#

require "test_helper"

class ComTimelineAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "com_timeline_audits", ComTimelineAudit.table_name

    refl = ComTimelineAudit.reflect_on_association(:com_timeline)

    assert_not_nil refl, "expected belongs_to :com_timeline association"
    assert_equal :belongs_to, refl.macro

    refl_level = ComTimelineAudit.reflect_on_association(:com_timeline_audit_level)
    assert_not_nil refl_level, "expected belongs_to :com_timeline_audit_level association"
    assert_equal :belongs_to, refl_level.macro
  end
end
