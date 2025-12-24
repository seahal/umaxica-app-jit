# == Schema Information
#
# Table name: com_timeline_audits
#
#  id              :uuid             not null, primary key
#  actor_id        :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type      :string           default(""), not null
#  com_timeline_id :uuid             not null
#  created_at      :datetime         not null
#  current_value   :text             default(""), not null
#  event_id        :string(255)      default(""), not null
#  ip_address      :string           default(""), not null
#  level_id        :string           default("NONE"), not null
#  previous_value  :text             default(""), not null
#  timestamp       :datetime         default("-infinity"), not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_com_timeline_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_com_timeline_audits_on_com_timeline_id          (com_timeline_id)
#  index_com_timeline_audits_on_level_id                 (level_id)
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
