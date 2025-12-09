require "test_helper"

class AppTimelineAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "app_timeline_audits", AppTimelineAudit.table_name

    refl = AppTimelineAudit.reflect_on_association(:app_timeline)

    assert_not_nil refl, "expected belongs_to :app_timeline association"
    assert_equal :belongs_to, refl.macro
  end
end
