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
