require "test_helper"

class OrgDocumentAuditTest < ActiveSupport::TestCase
  test "loads model and associations" do
    assert_equal "org_document_audits", OrgDocumentAudit.table_name

    refl = OrgDocumentAudit.reflect_on_association(:org_document)

    assert_not_nil refl, "expected belongs_to :org_document association"
    assert_equal :belongs_to, refl.macro

    refl_level = OrgDocumentAudit.reflect_on_association(:org_document_audit_level)
    assert_not_nil refl_level, "expected belongs_to :org_document_audit_level association"
    assert_equal :belongs_to, refl_level.macro
  end
end
