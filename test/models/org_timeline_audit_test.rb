require "test_helper"

class OrgTimelineAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "org_timeline_audits", OrgTimelineAudit.table_name

    refl = OrgTimelineAudit.reflect_on_association(:org_timeline)

    assert_not_nil refl, "expected belongs_to :org_timeline association"
    assert_equal :belongs_to, refl.macro

    refl_level = OrgTimelineAudit.reflect_on_association(:org_timeline_audit_level)
    assert_not_nil refl_level, "expected belongs_to :org_timeline_audit_level association"
    assert_equal :belongs_to, refl_level.macro
  end
end
