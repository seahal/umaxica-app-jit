require "test_helper"

class OrgContactAuditTest < ActiveSupport::TestCase
  test "loads model and table name" do
    assert_equal "org_contact_histories", OrgContactAudit.table_name
  end

  test "associations" do
    assert_not_nil OrgContactAudit.reflect_on_association(:org_contact)
    assert_not_nil OrgContactAudit.reflect_on_association(:actor)
    assert_not_nil OrgContactAudit.reflect_on_association(:org_contact_audit_event)
  end
end
