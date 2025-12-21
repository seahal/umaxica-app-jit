require "test_helper"

class AppContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    assert_equal "app_contact_histories", AppContactAudit.table_name
  end

  test "associations" do
    assert_not_nil AppContactAudit.reflect_on_association(:app_contact)
    assert_not_nil AppContactAudit.reflect_on_association(:actor)
    assert_not_nil AppContactAudit.reflect_on_association(:app_contact_audit_event)
  end
end
