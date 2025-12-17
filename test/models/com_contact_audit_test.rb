require "test_helper"

class ComContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    assert_equal "com_contact_audits", ComContactAudit.table_name
  end

  test "associations" do
    assert_not_nil ComContactAudit.reflect_on_association(:com_contact)
    assert_not_nil ComContactAudit.reflect_on_association(:actor)
    assert_not_nil ComContactAudit.reflect_on_association(:com_contact_audit_event)
  end
end
