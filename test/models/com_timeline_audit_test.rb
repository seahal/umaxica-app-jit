require "test_helper"

class ComTimelineAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "com_timeline_audits", ComTimelineAudit.table_name

    refl = ComTimelineAudit.reflect_on_association(:com_timeline)

    assert_not_nil refl, "expected belongs_to :com_timeline association"
    assert_equal :belongs_to, refl.macro
  end
end
